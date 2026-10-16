import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_region_preferences_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_cache_first_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/save_region_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/save_season_usecase.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_state.dart';
import 'package:arena_soccer/features/seasons/data/dtos/seasons_config_dto.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/get_seasons_config_cache_first_usecase.dart';

class RegionCubit extends Cubit<RegionState> {
  final GetRegionsCacheFirstUseCase getRegionsCacheFirstUseCase;
  final GetRegionPreferencesUseCase getRegionPreferencesUseCase;
  final SaveRegionUseCase saveRegionUseCase;
  final SaveSeasonUseCase saveSeasonUseCase;
  final GetSeasonsConfigCacheFirstUseCase getSeasonsConfigCacheFirstUseCase;

  RegionCubit(
    this.getRegionsCacheFirstUseCase,
    this.getRegionPreferencesUseCase,
    this.saveRegionUseCase,
    this.saveSeasonUseCase,
    this.getSeasonsConfigCacheFirstUseCase,
  ) : super(const RegionState());

  /// Temporadas e regiões pelo cache local: dentro da validade, nenhuma
  /// leitura no Firestore (e o app abre sem rede, com o vínculo id ↔ nome
  /// carregado do cache); vencido, mostra o cache e atualiza se mudou.
  /// [force] ignora a validade (admin acabou de mudar as regiões).
  Future<void> load({bool force = false}) async {
    final seasonsIt = StreamIterator(getSeasonsConfigCacheFirstUseCase(force: force));
    final regionsIt = StreamIterator(getRegionsCacheFirstUseCase(force: force));
    try {
      // Primeiro valor de cada um: o cache (na hora) ou, sem cache, o remoto.
      final first = await Future.wait([seasonsIt.moveNext(), regionsIt.moveNext()]);
      var seasons = first[0]
          ? seasonsIt.current
          : SeasonsConfigDTO(current: SeasonCollection.currentSeason, seasons: SeasonCollection.seasons);
      var regions = (first[1] ? _names(regionsIt.current) : null) ?? const <String>[];
      await _publish(seasons, regions);

      // Cache vencido: o remoto chega depois e só vem se mudou.
      var changed = false;
      await Future.wait([
        () async {
          while (await seasonsIt.moveNext()) {
            seasons = seasonsIt.current;
            changed = true;
          }
        }(),
        () async {
          while (await regionsIt.moveNext()) {
            final next = _names(regionsIt.current);
            if (next == null) continue;
            regions = next;
            changed = true;
          }
        }(),
      ]);
      if (changed) await _publish(seasons, regions);
    } finally {
      await seasonsIt.cancel();
      await regionsIt.cancel();
    }
  }

  /// Nomes das regiões; nulo na falha (sem cache e sem rede).
  List<String>? _names(Either<Failure, List<RegionRef>> response) =>
      response.isRight ? response.right.map((region) => region.name).toList() : null;

  Future<void> _publish(SeasonsConfigDTO seasons, List<String> regions) async {
    // Regiões antes da escolha salva: carregam o vínculo id ↔ nome, que
    // resolve a região salva pelo id (mesmo renomeada) e as consultas.
    final preferences = await getRegionPreferencesUseCase();
    // A temporada salva pelo usuário pode não existir mais na lista.
    final season = seasons.seasons.contains(preferences.season) ? preferences.season : seasons.current;

    // Região salva que não existe mais (excluída): a primeira da lista.
    var region = preferences.region;
    if (regions.isNotEmpty && !regions.contains(region)) region = regions.first;
    // Grava de novo: completa o id para quem só tinha o nome salvo.
    if (regions.contains(region)) await saveRegionUseCase(region);
    if (isClosed) return;
    emit(state.copyWith(
      selectedRegion: region,
      selectedSeason: season,
      seasons: seasons.seasons,
      // Sem a lista, o seletor mostra só a região salva; não bloqueia o app.
      regions: regions.isEmpty ? [region] : regions,
    ));
  }

  Future<void> selectRegion(String region) async {
    emit(state.copyWith(selectedRegion: region));
    await saveRegionUseCase(region);
  }

  /// Depois que o admin inicia uma temporada: lista nova e a atual selecionada.
  Future<void> reloadSeasons() async {
    final seasons = await getSeasonsConfigCacheFirstUseCase(force: true).last;
    await selectSeason(seasons.current);
    emit(state.copyWith(seasons: seasons.seasons));
  }

  Future<void> selectSeason(String season) async {
    emit(state.copyWith(selectedSeason: season));
    await saveSeasonUseCase(season);
  }
}
