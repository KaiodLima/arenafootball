import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/features/regions/domain/region_usage.dart';
import 'package:arena_soccer/features/regions/domain/repositories/regions_repository_interface.dart';
import 'package:arena_soccer/features/regions/domain/usecases/create_region_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/manage_region_usecases.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/manage_regions_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/manage_regions_state.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

/// Fake com o comportamento do datasource: lista em `competicao` (id → nome)
/// e o [RegionRegistry] carregado a cada leitura.
class _FakeRepository implements IRegionsRepository {
  final regions = <String, String>{'si': 'Santo inacio', 'fl': 'Floresta'};
  var usage = const RegionUsage({});
  var nextId = 0;
  bool linked = false;

  @override
  Future<Either<Failure, List<String>>> getRegions() async {
    RegionRegistry.configure([for (final e in regions.entries) RegionRef(id: e.key, name: e.value)]);
    return Right(regions.values.toList());
  }

  @override
  Future<Either<Failure, void>> createRegion(String name) async {
    regions['new${nextId++}'] = name;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> renameRegion({required String id, required String name}) async {
    regions[id] = name;
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteRegion(String id) async {
    regions.remove(id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, RegionUsage>> regionUsage({required String id, required String name}) async =>
      Right(usage);

  @override
  Future<Either<Failure, RegionLinkReport>> linkRegions() async {
    linked = true;
    return const Right(RegionLinkReport(updated: {'noticias': 3}, unmatched: ['Florest']));
  }

  @override
  Future<String?> getSavedRegion() async => null;

  @override
  Future<void> saveRegion(String region) async {}

  @override
  Future<String?> getSavedSeason() async => null;

  @override
  Future<void> saveSeason(String season) async {}
}

class _FakeTeams implements GetTeamsUseCase {
  @override
  Future<Either<Failure, List<TeamDTO>>> call({String? region, String? season}) async => const Right([
        TeamDTO(id: '1', name: 'Lava Jato', region: 'Floresta'),
        TeamDTO(id: '2', name: 'Volta', region: 'Floresta'),
        TeamDTO(id: '3', name: 'Riacho', region: 'Santo inacio'),
      ]);
}

void main() {
  tearDown(RegionRegistry.reset);

  group('RegionRegistry', () {
    setUp(() => RegionRegistry.configure(const [RegionRef(id: 'fl', name: 'Floresta')]));

    test('id pelo nome (sem acento/caixa) e nome atual pelo id', () {
      expect(RegionRegistry.idOf(' floresta '), 'fl');
      expect(RegionRegistry.idOf('Caxingó'), '');
      expect(RegionRegistry.nameOf('fl', fallback: 'Velho'), 'Floresta');
      expect(RegionRegistry.nameOf('??', fallback: 'Velho'), 'Velho');
    });

    test('doc renomeado mostra o nome atual; doc antigo, o nome gravado', () {
      expect(RegionRegistry.nameFromDoc({'idRegiao': 'fl', 'fk_competicao': 'Nome antigo'}), 'Floresta');
      expect(RegionRegistry.nameFromDoc({'fk_competicao': 'Santo inacio'}), 'Santo inacio');
      expect(RegionRegistry.nameFromDoc({'idRegiao': 'fl', 'regiao': 'x'}, nameKey: 'regiao'), 'Floresta');
    });

    test('gravar leva o nome e o id (quando a região é conhecida)', () {
      expect(RegionRegistry.fieldsFor('Floresta'), {'fk_competicao': 'Floresta', 'idRegiao': 'fl'});
      expect(RegionRegistry.fieldsFor('Floresta', nameKey: 'regiao'), {'regiao': 'Floresta', 'idRegiao': 'fl'});
      expect(RegionRegistry.fieldsFor('Desconhecida'), {'fk_competicao': 'Desconhecida'});
    });
  });

  group('CreateRegionUseCase', () {
    test('valida: curto e repetido (ignora acento, caixa e espaços)', () {
      const existing = ['Santo inacio', 'Floresta'];
      expect(CreateRegionUseCase.validate('Ab', existing), RegionNameError.tooShort);
      expect(CreateRegionUseCase.validate('  santo INÁCIO ', existing), RegionNameError.duplicate);
      expect(CreateRegionUseCase.validate('Caxingó', existing), isNull);
    });

    test('grava o nome limpo e recusa repetido', () async {
      final repository = _FakeRepository();
      final useCase = CreateRegionUseCase(repository);
      expect((await useCase('  Caxingó   Norte ')).right, 'Caxingó Norte');
      final duplicated = await useCase('floresta');
      expect((duplicated.left as RegionNameFailure).error, RegionNameError.duplicate);
      expect(repository.regions.length, 3);
    });
  });

  group('RenameRegionUseCase', () {
    test('troca só o nome no doc da região (pelo id)', () async {
      final repository = _FakeRepository();
      final useCase = RenameRegionUseCase(repository);
      expect((await useCase(current: 'Floresta', name: ' Floresta do Piauí ')).right, 'Floresta do Piauí');
      expect(repository.regions['fl'], 'Floresta do Piauí');
    });

    test('recusa nome de outra região; o próprio nome não conta como repetido', () async {
      final repository = _FakeRepository();
      final useCase = RenameRegionUseCase(repository);
      final taken = await useCase(current: 'Floresta', name: 'santo inácio');
      expect((taken.left as RegionNameFailure).error, RegionNameError.duplicate);
      expect((await useCase(current: 'Floresta', name: 'FLORESTA')).isRight, isTrue);
    });
  });

  group('DeleteRegionUseCase', () {
    test('com conteúdo não exclui', () async {
      final repository = _FakeRepository()..usage = const RegionUsage({RegionUsageKind.teams: 2});
      final response = await DeleteRegionUseCase(repository)('Floresta');
      expect(response.left, isA<RegionInUseFailure>());
      expect(repository.regions.containsKey('fl'), isTrue);
    });

    test('vazia exclui; a última não', () async {
      final repository = _FakeRepository();
      final useCase = DeleteRegionUseCase(repository);
      expect((await useCase('Floresta')).isRight, isTrue);
      expect(repository.regions.keys, ['si']);
      expect((await useCase('Santo inacio')).left, isA<LastRegionFailure>());
    });
  });

  group('ManageRegionsCubit', () {
    late _FakeRepository repository;
    late ManageRegionsCubit cubit;

    setUp(() async {
      repository = _FakeRepository();
      cubit = ManageRegionsCubit(
        GetRegionsUseCase(repository),
        _FakeTeams(),
        CreateRegionUseCase(repository),
        RenameRegionUseCase(repository),
        DeleteRegionUseCase(repository),
        LinkRegionsByIdUseCase(repository),
      );
      await cubit.load();
    });

    test('lista em ordem alfabética com os times de cada região', () {
      expect(cubit.state.regions, ['Floresta', 'Santo inacio']);
      expect(cubit.state.teamsIn('Floresta'), 2);
      expect(cubit.state.teamsIn('Santo inacio'), 1);
    });

    test('criar e renomear recarregam a lista', () async {
      await cubit.create('Caxingó');
      expect(cubit.state, isA<CreatedManageRegionsState>());
      await cubit.rename('Caxingó', 'Caxingó Sul');
      expect(cubit.state, isA<RenamedManageRegionsState>());
      expect(cubit.state.regions, ['Caxingó Sul', 'Floresta', 'Santo inacio']);
    });

    test('excluir: confere o conteúdo antes', () async {
      repository.usage = const RegionUsage({RegionUsageKind.news: 4});
      await cubit.checkDelete('Floresta');
      final checked = cubit.state as DeleteCheckedManageRegionsState;
      expect(checked.usage.isEmpty, isFalse);

      repository.usage = const RegionUsage({});
      await cubit.delete('Floresta');
      expect(cubit.state, isA<DeletedManageRegionsState>());
      expect(cubit.state.regions, ['Santo inacio']);
      await cubit.checkDelete('Santo inacio');
      expect(cubit.state, isA<LastRegionManageRegionsState>());
    });

    test('vincular por id devolve o relatório', () async {
      await cubit.linkRegions();
      final linked = cubit.state as LinkedManageRegionsState;
      expect(repository.linked, isTrue);
      expect(linked.report.total, 3);
      expect(linked.report.unmatched, ['Florest']);
    });
  });
}
