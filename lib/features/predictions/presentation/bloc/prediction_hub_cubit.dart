import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_region_matches_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/domain/prediction_hub.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/get_my_predictions_usecase.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/get_prediction_ranking_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Central do bolão da região: o ranking (top 50 + a conta), os próximos
/// jogos abertos para palpite, os últimos palpites da conta já jogados e os
/// times (escudos e cores, do cache).
class PredictionHubState extends Equatable {
  final String region;
  final bool loading;
  final String? errorMessage;

  final List<PredictionRankingEntry> entries;
  final PredictionRankingEntry? mine;
  final int? myPosition;

  /// Próximas partidas abertas para palpite e as já começadas que ainda não
  /// terminaram (travadas), as mais cedo primeiro.
  final List<MatchDTO> upcoming;

  /// Partidas encerradas em que a conta palpitou (as mais recentes primeiro).
  final List<MatchDTO> recent;

  /// Palpites da conta, por id da partida.
  final Map<String, PredictionDTO> predictions;

  /// Times da região (escudos e cores); nulo até o cache responder.
  final TeamDirectory? teamDirectory;

  TeamDirectory get teams => teamDirectory ?? TeamDirectory.empty;

  const PredictionHubState({
    this.region = '',
    this.loading = true,
    this.errorMessage,
    this.entries = const [],
    this.mine,
    this.myPosition,
    this.upcoming = const [],
    this.recent = const [],
    this.predictions = const {},
    this.teamDirectory,
  });

  /// Posição de quem está no índice [index] (empate em pontos e exatos divide).
  int positionAt(int index) {
    final entry = entries[index];
    return entries.indexWhere((e) => e.points == entry.points && e.exact == entry.exact) + 1;
  }

  PredictionHubState copyWith({
    bool? loading,
    String? Function()? errorMessage,
    List<PredictionRankingEntry>? entries,
    PredictionRankingEntry? Function()? mine,
    int? Function()? myPosition,
    List<MatchDTO>? upcoming,
    List<MatchDTO>? recent,
    Map<String, PredictionDTO>? predictions,
    TeamDirectory? teams,
  }) =>
      PredictionHubState(
        region: region,
        loading: loading ?? this.loading,
        errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
        entries: entries ?? this.entries,
        mine: mine != null ? mine() : this.mine,
        myPosition: myPosition != null ? myPosition() : this.myPosition,
        upcoming: upcoming ?? this.upcoming,
        recent: recent ?? this.recent,
        predictions: predictions ?? this.predictions,
        teamDirectory: teams ?? teamDirectory,
      );

  @override
  List<Object?> get props =>
      [region, loading, errorMessage, entries, mine, myPosition, upcoming, recent, predictions, teamDirectory];
}

class PredictionHubCubit extends Cubit<PredictionHubState> {
  final GetPredictionRankingUseCase getPredictionRankingUseCase;
  final GetRegionMatchesUseCase getRegionMatchesUseCase;
  final GetMyPredictionsUseCase getMyPredictionsUseCase;
  final GetTeamsCacheFirstUseCase? getTeamsCacheFirstUseCase;

  /// Relógio (teste).
  final DateTime Function() now;

  PredictionHubCubit(
    this.getPredictionRankingUseCase,
    this.getRegionMatchesUseCase,
    this.getMyPredictionsUseCase, [
    this.getTeamsCacheFirstUseCase,
    DateTime Function()? now,
  ])  : now = now ?? DateTime.now,
        super(const PredictionHubState());

  String _uid = '';
  String? _season;

  Future<void> load({required String region, String uid = '', String? season}) async {
    _uid = uid;
    _season = season;
    emit(PredictionHubState(region: region));
    final regionId = RegionRegistry.idOf(region);
    if (regionId.isEmpty) {
      emit(PredictionHubState(region: region, loading: false));
      return;
    }
    await Future.wait([_loadRanking(region, regionId), _loadMatches(region), _loadTeams(region)]);
    if (isClosed || state.region != region) return;
    emit(state.copyWith(loading: false));
  }

  Future<void> _loadRanking(String region, String regionId) async {
    final response = await getPredictionRankingUseCase(regionId: regionId, uid: _uid, season: _season);
    if (isClosed || state.region != region) return;
    response.fold(
      (failure) => emit(state.copyWith(errorMessage: () => failure.toString())),
      (ranking) => emit(state.copyWith(
        entries: ranking.top,
        mine: () => ranking.mine,
        myPosition: () => ranking.myPosition,
      )),
    );
  }

  /// Próximos abertos e os em andamento (até 6) e os encerrados mais recentes (até 8 candidatos,
  /// ficam até 5 com palpite); os palpites da conta numa leitura por partida.
  Future<void> _loadMatches(String region) async {
    final response = await getRegionMatchesUseCase(region: region, season: _season);
    if (isClosed || state.region != region || response.isLeft) return;
    final clock = now();
    final matches = response.right;
    final upcoming = PredictionHub.byKickoff(
      matches.where((m) => hubPhaseOf(m, clock) != null && PredictionHub.kickoffOf(m, clock) != null),
      clock,
    ).take(PredictionHub.upcomingLimit).toList();
    final finished = PredictionHub.byKickoff(
      matches.where((m) => MatchCardStatus.of(m, clock).finished),
      clock,
      descending: true,
    ).take(PredictionHub.recentCandidates).toList();
    emit(state.copyWith(upcoming: upcoming));
    final mine = await getMyPredictionsUseCase(
      matchIds: [...upcoming, ...finished].map((m) => m.id).toList(),
      uid: _uid,
      season: _season,
    );
    if (isClosed || state.region != region) return;
    final predictions = mine.fold((_) => const <String, PredictionDTO>{}, (value) => value);
    emit(state.copyWith(
      predictions: predictions,
      recent: finished.where((m) => predictions.containsKey(m.id)).take(PredictionHub.recentLimit).toList(),
    ));
  }

  Future<void> _loadTeams(String region) async {
    final useCase = getTeamsCacheFirstUseCase;
    if (useCase == null) return;
    await for (final response in useCase(region: region, season: _season)) {
      if (isClosed || state.region != region) return;
      response.fold((_) {}, (teams) => emit(state.copyWith(teams: TeamDirectory(teams))));
    }
  }

  /// Depois da folha de palpite: relê o palpite daquela partida (1 leitura).
  Future<void> refreshPrediction(String matchId) async {
    final region = state.region;
    final response = await getMyPredictionsUseCase(matchIds: [matchId], uid: _uid, season: _season);
    if (isClosed || state.region != region) return;
    response.fold((_) {}, (found) {
      final predictions = {...state.predictions}..remove(matchId);
      predictions.addAll(found);
      emit(state.copyWith(predictions: predictions));
    });
  }
}

/// Fase do jogo na aba Palpitar pelo status do card (nulo = fora da lista).
HubMatchPhase? hubPhaseOf(MatchDTO match, DateTime now) {
  final status = MatchCardStatus.of(match, now);
  return PredictionHub.phaseOf(
    upcoming: status.upcoming,
    live: status.live,
    halfTime: status.halfTime,
    waiting: status.waiting,
  );
}
