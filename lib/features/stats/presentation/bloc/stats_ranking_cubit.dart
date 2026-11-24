import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/services/preferences_service.dart';
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

  /// Guarda o último filtro de competição (o mesmo da aba Tabelas); nulo = não guarda.
  final PreferencesService? preferences;

  /// A competição veio do filtro guardado: se não existir mais, volta ao geral.
  bool _fromSaved = false;

  StatsRankingCubit(this.getStatsRankingCacheFirstUseCase,
      [this.getRegionChampionshipsCacheFirstUseCase, this.preferences])
      : super(const LoadingStatsRankingState());

  /// Abre a tela: sem [championshipId], a competição do último filtro guardado.
  Future<void> open({
    required StatsRankingType type,
    required String region,
    required String season,
    int? championshipId,
  }) async {
    var id = championshipId;
    if (id == null) {
      id = await preferences?.getChampionshipFilter(region, season);
      _fromSaved = id != null;
      if (isClosed) return;
    }
    await load(type: type, region: region, season: season, championshipId: id);
  }

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
      // Filtro guardado de uma competição que não está mais na lista: geral.
      final saved = state.championshipId;
      if (_fromSaved && saved != null && !championships.any((c) => c.championshipId == saved)) {
        _fromSaved = false;
        unawaited(load(type: state.type, region: _region, season: _season));
      }
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
    _fromSaved = false;
    unawaited(preferences?.setChampionshipFilter(_region, _season, championshipId));
    load(type: state.type, region: _region, season: _season, championshipId: championshipId);
  }
}
