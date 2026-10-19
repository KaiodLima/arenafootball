import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_cache_first_usecase.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_stats_ranking_cache_first_usecase.dart';
import 'package:arena_soccer/features/stats/presentation/bloc/stats_ranking_state.dart';

/// Artilharia / líderes de assistência de uma região na temporada, no geral ou
/// de uma competição (chips). O quesito e a competição podem ser trocados na
/// mesma tela; cada combinação é lida uma vez e guardada, então voltar para a
/// anterior é instantâneo.
class StatsRankingCubit extends Cubit<StatsRankingState> {
  final GetStatsRankingCacheFirstUseCase getStatsRankingCacheFirstUseCase;
  final GetRegionChampionshipsCacheFirstUseCase? getRegionChampionshipsCacheFirstUseCase;
  String _region = '';
  String _season = '';

  /// Descarta respostas antigas quando o usuário troca de quesito rápido.
  int _request = 0;
  final Map<String, StatsRanking> _cache = {};

  StatsRankingCubit(this.getStatsRankingCacheFirstUseCase, [this.getRegionChampionshipsCacheFirstUseCase])
      : super(const LoadingStatsRankingState());

  static String _key(StatsRankingType type, int? championshipId) => '${type.name}_${championshipId ?? ''}';

  /// [force] (puxar para atualizar / tentar de novo): ignora a validade do
  /// cache local e a lista já lida nesta tela.
  Future<void> load({
    required StatsRankingType type,
    required String region,
    required String season,
    int? championshipId,
    bool force = false,
  }) async {
    final regionChanged = region != _region || season != _season;
    if (force || regionChanged) _cache.clear();
    _region = region;
    _season = season;
    if (regionChanged) unawaited(_loadChampionships(region: region, season: season));
    final request = ++_request;
    final championships = state.championships;
    final cached = _cache[_key(type, championshipId)];
    if (cached != null) {
      emit(SuccessStatsRankingState(
        type: type,
        entries: cached.entries,
        crests: cached.crests,
        championships: championships,
        championshipId: championshipId,
      ));
      return;
    }
    // Lista do outro quesito não serve enquanto carrega (os números mudariam
    // de sentido); os escudos, sim.
    emit(LoadingStatsRankingState(
      type: type,
      crests: state.crests,
      championships: championships,
      championshipId: championshipId,
    ));
    final stream = getStatsRankingCacheFirstUseCase(
      type: type,
      region: region,
      season: season,
      championshipId: championshipId,
      force: force,
    );
    await for (final response in stream) {
      if (isClosed || request != _request) return;
      response.fold(
        (failure) => emit(ErrorStatsRankingState(
          errorMessage: failure.toString(),
          type: type,
          crests: state.crests,
          championships: state.championships,
          championshipId: championshipId,
        )),
        (ranking) {
          _cache[_key(type, championshipId)] = ranking;
          emit(SuccessStatsRankingState(
            type: type,
            entries: ranking.entries,
            crests: ranking.crests,
            championships: state.championships,
            championshipId: championshipId,
          ));
        },
      );
    }
  }

  /// Competições da região para as chips (sem elas, só o ranking geral).
  Future<void> _loadChampionships({required String region, required String season}) async {
    final useCase = getRegionChampionshipsCacheFirstUseCase;
    if (useCase == null) return;
    await for (final response in useCase(region: region, season: season)) {
      if (isClosed || response.isLeft) return;
      final championships = [...response.right]..sort((a, b) => a.championshipId.compareTo(b.championshipId));
      emit(_withChampionships(championships));
    }
  }

  StatsRankingState _withChampionships(List<ChampionshipDTO> championships) {
    final s = state;
    if (s is ErrorStatsRankingState) {
      return ErrorStatsRankingState(
        errorMessage: s.errorMessage,
        type: s.type,
        entries: s.entries,
        crests: s.crests,
        championships: championships,
        championshipId: s.championshipId,
      );
    }
    if (s is SuccessStatsRankingState) {
      return SuccessStatsRankingState(
        type: s.type,
        entries: s.entries,
        crests: s.crests,
        championships: championships,
        championshipId: s.championshipId,
      );
    }
    return LoadingStatsRankingState(
      type: s.type,
      entries: s.entries,
      crests: s.crests,
      championships: championships,
      championshipId: s.championshipId,
    );
  }

  void setType(StatsRankingType type) {
    if (type == state.type && state is! ErrorStatsRankingState) return;
    load(type: type, region: _region, season: _season, championshipId: state.championshipId);
  }

  /// Ranking da competição (nula = geral).
  void setChampionship(int? championshipId) {
    if (championshipId == state.championshipId && state is! ErrorStatsRankingState) return;
    load(type: state.type, region: _region, season: _season, championshipId: championshipId);
  }
}
