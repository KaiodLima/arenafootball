import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/services/preferences_service.dart';
import 'package:arena_soccer/features/regions/data/datasources/regions_datasource.dart';
import 'package:arena_soccer/features/regions/data/repositories/regions_repository_impl.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_cached_regions_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_region_preferences_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_cache_first_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/save_region_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/save_regions_cache_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/save_season_usecase.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/seasons/data/datasources/seasons_datasource.dart';
import 'package:arena_soccer/features/seasons/data/dtos/seasons_config_dto.dart';
import 'package:arena_soccer/features/seasons/data/repositories/seasons_repository_impl.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/get_cached_seasons_config_usecase.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/get_seasons_config_cache_first_usecase.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/save_seasons_config_cache_usecase.dart';

/// `competicao` sem Firestore: devolve as regiões (e carrega o registry, como
/// o real) ou falha quando [offline].
class _FakeRegionsDataSource implements RegionsDataSource {
  bool offline = false;
  int calls = 0;
  List<RegionRef> regions = const [RegionRef(id: 'si', name: 'Santo inacio'), RegionRef(id: 'fl', name: 'Floresta')];

  @override
  Future<Either<Failure, List<RegionRef>>> getRegionRefs() async {
    calls++;
    if (offline) return Left(ErrorWithMessage('offline'));
    RegionRegistry.configure(regions);
    return Right(regions);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSeasonsDataSource implements SeasonsDataSource {
  bool offline = false;
  int calls = 0;

  @override
  Future<Either<Failure, SeasonsConfigDTO?>> getConfig() async {
    calls++;
    if (offline) return Left(ErrorWithMessage('offline'));
    return const Right(SeasonsConfigDTO(current: '2024', seasons: ['2023', '2024']));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory dir;
  late Box<String> box;
  late _FakeRegionsDataSource regionsSource;
  late _FakeSeasonsDataSource seasonsSource;
  var boxes = 0;

  setUpAll(() {
    dir = Directory.systemTemp.createTempSync('arena_region_cache_test');
    Hive.init(dir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    box = await Hive.openBox<String>('region_cache_${boxes++}');
    regionsSource = _FakeRegionsDataSource();
    seasonsSource = _FakeSeasonsDataSource();
  });

  tearDown(() async {
    RegionRegistry.reset();
    SeasonCollection.reset();
    await box.deleteFromDisk();
  });

  /// Cubit com os repositórios reais (cache no Hive); [savedAt] = relógio do
  /// cache ao gravar.
  RegionCubit buildCubit({DateTime Function()? savedAt}) {
    final cache = CacheStore(box, now: savedAt);
    final regions = RegionsRepositoryImpl(regionsSource, PreferencesService(), cache);
    final seasons = SeasonsRepositoryImpl(seasonsSource, cache);
    return RegionCubit(
      GetRegionsCacheFirstUseCase(regions, GetCachedRegionsUseCase(regions), SaveRegionsCacheUseCase(regions)),
      GetRegionPreferencesUseCase(regions),
      SaveRegionUseCase(regions),
      SaveSeasonUseCase(regions),
      GetSeasonsConfigCacheFirstUseCase(
        seasons,
        GetCachedSeasonsConfigUseCase(seasons),
        SaveSeasonsConfigCacheUseCase(seasons),
      ),
    );
  }

  test('online: carrega do Firestore e salva o cache', () async {
    final cubit = buildCubit();
    await cubit.load();
    expect(cubit.state.regions, ['Santo inacio', 'Floresta']);
    expect(cubit.state.seasons, ['2023', '2024']);
    expect(box.keys, containsAll(['regions_cache', 'seasons_config_cache']));
    await cubit.close();
  });

  test('cache dentro da validade: nenhuma leitura e o registry vem do cache (offline)', () async {
    await buildCubit().load();
    regionsSource
      ..offline = true
      ..calls = 0;
    seasonsSource
      ..offline = true
      ..calls = 0;
    // App reaberto: nada em memória.
    RegionRegistry.reset();
    SeasonCollection.reset();

    final cubit = buildCubit();
    await cubit.load();
    expect(regionsSource.calls, 0);
    expect(seasonsSource.calls, 0);
    expect(cubit.state.regions, ['Santo inacio', 'Floresta']);
    expect(RegionRegistry.idOf('Floresta'), 'fl');
    expect(SeasonCollection.currentSeason, '2024');
    expect(cubit.state.selectedRegion, 'Floresta');
    await cubit.close();
  });

  test('cache vencido e sem rede: mantém o cache', () async {
    // Gravado há dois dias (validade de 24h).
    await buildCubit(savedAt: () => DateTime.now().subtract(const Duration(days: 2))).load();
    regionsSource
      ..offline = true
      ..calls = 0;
    RegionRegistry.reset();

    final cubit = buildCubit();
    await cubit.load();
    expect(regionsSource.calls, 1);
    expect(cubit.state.regions, ['Santo inacio', 'Floresta']);
    expect(RegionRegistry.idOf('Santo inacio'), 'si');
    await cubit.close();
  });

  test('force (admin mudou as regiões): busca de novo e mostra a lista nova', () async {
    final cubit = buildCubit();
    await cubit.load();
    regionsSource.regions = const [RegionRef(id: 'fl', name: 'Floresta Sul')];
    await cubit.load(force: true);
    expect(cubit.state.regions, ['Floresta Sul']);
    // Região salva pelo id: renomeada, continua selecionada.
    expect(cubit.state.selectedRegion, 'Floresta Sul');
    await cubit.close();
  });

  test('sem cache e sem rede: segue com o padrão (não trava)', () async {
    regionsSource.offline = true;
    seasonsSource.offline = true;
    final cubit = buildCubit();
    await cubit.load();
    expect(cubit.state.regions, [GetRegionPreferencesUseCase.defaultRegion]);
    expect(cubit.state.selectedSeason, SeasonCollection.fallbackSeason);
    await cubit.close();
  });
}
