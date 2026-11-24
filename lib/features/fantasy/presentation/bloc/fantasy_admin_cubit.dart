import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_athlete_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_admin_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_lineup_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_ranking_usecases.dart';

/// Resultado do "Reapurar rodadas" (snackbar).
enum FantasyRescoreResult { none, requested, failed }

/// Resultado do "Fechar agora"/"Reabrir" da rodada (snackbar).
enum FantasyRoundActionResult { none, closeRequested, openRequested, failed }

/// Resultado do "Zerar pontuações (testes)" (snackbar).
enum FantasyResetResult { none, requested, failed }

class FantasyAdminState extends Equatable {
  /// Rodadas, a mais recente primeiro.
  final List<FantasyRoundDTO> rounds;
  final bool roundsLoaded;
  final List<FantasyParticipantDTO> participants;
  final bool participantsLoading;

  /// Ainda pode haver participantes (a última página veio cheia).
  final bool hasMore;

  /// Histórico do participante aberto na folha.
  final String? openUid;
  final List<FantasyHistoryItem> history;
  final bool historyLoading;
  final Map<String, FantasyAthleteDTO> athletes;
  final bool rescoring;
  final FantasyRescoreResult rescore;
  final bool resetting;
  final FantasyResetResult reset;
  final FantasyRoundActionResult roundAction;
  final String? failure;

  const FantasyAdminState({
    this.rounds = const [],
    this.roundsLoaded = false,
    this.participants = const [],
    this.participantsLoading = false,
    this.hasMore = true,
    this.openUid,
    this.history = const [],
    this.historyLoading = false,
    this.athletes = const {},
    this.rescoring = false,
    this.rescore = FantasyRescoreResult.none,
    this.resetting = false,
    this.reset = FantasyResetResult.none,
    this.roundAction = FantasyRoundActionResult.none,
    this.failure,
  });

  FantasyAdminState copyWith({
    List<FantasyRoundDTO>? rounds,
    bool? roundsLoaded,
    List<FantasyParticipantDTO>? participants,
    bool? participantsLoading,
    bool? hasMore,
    String? Function()? openUid,
    List<FantasyHistoryItem>? history,
    bool? historyLoading,
    Map<String, FantasyAthleteDTO>? athletes,
    bool? rescoring,
    FantasyRescoreResult? rescore,
    bool? resetting,
    FantasyResetResult? reset,
    FantasyRoundActionResult? roundAction,
    String? failure,
  }) =>
      FantasyAdminState(
        rounds: rounds ?? this.rounds,
        roundsLoaded: roundsLoaded ?? this.roundsLoaded,
        participants: participants ?? this.participants,
        participantsLoading: participantsLoading ?? this.participantsLoading,
        hasMore: hasMore ?? this.hasMore,
        openUid: openUid != null ? openUid() : this.openUid,
        history: history ?? this.history,
        historyLoading: historyLoading ?? this.historyLoading,
        athletes: athletes ?? this.athletes,
        rescoring: rescoring ?? this.rescoring,
        rescore: rescore ?? FantasyRescoreResult.none,
        resetting: resetting ?? this.resetting,
        reset: reset ?? FantasyResetResult.none,
        roundAction: roundAction ?? FantasyRoundActionResult.none,
        failure: failure,
      );

  @override
  List<Object?> get props => [
        rounds,
        roundsLoaded,
        participants,
        participantsLoading,
        hasMore,
        openUid,
        history,
        historyLoading,
        athletes,
        rescoring,
        rescore,
        resetting,
        reset,
        roundAction,
        failure,
      ];
}

/// Painel do admin do Arena Fantasy: rodadas e apuração (ao vivo),
/// participantes (paginados) com o histórico de cada um e o "Reapurar".
class FantasyAdminCubit extends Cubit<FantasyAdminState> {
  final WatchFantasyRoundsUseCase _watchRounds;
  final GetFantasyParticipantsUseCase _participants;
  final RequestFantasyRescoreUseCase _rescore;
  final GetFantasyLineupUseCase _lineup;
  final GetFantasyPositionUseCase _position;
  final GetFantasyAthletesCacheFirstUseCase _athletes;

  /// "Zerar pontuações (testes)"; nulo = sem a ação (testes antigos).
  final RequestFantasyResetUseCase? _reset;

  /// "Fechar agora"/"Reabrir" a rodada; nulo = sem a ação (testes antigos).
  final RequestFantasyRoundActionUseCase? _roundAction;

  /// "Zerar pontos de times"; nulo = sem a ação (testes antigos).
  final RequestFantasyTeamsResetUseCase? _teamsReset;

  FantasyAdminCubit(
    this._watchRounds,
    this._participants,
    this._rescore,
    this._lineup,
    this._position,
    this._athletes, {
    RequestFantasyResetUseCase? reset,
    RequestFantasyRoundActionUseCase? roundAction,
    RequestFantasyTeamsResetUseCase? teamsReset,
  })  : _reset = reset,
        _roundAction = roundAction,
        _teamsReset = teamsReset,
        super(const FantasyAdminState());

  StreamSubscription<Object?>? _roundsSub;
  StreamSubscription<Object?>? _athletesSub;
  String _fantasyId = '';

  void load(ChampionshipDTO championship) {
    _fantasyId = championship.id;
    _roundsSub = _watchRounds(_fantasyId).listen((response) {
      if (isClosed) return;
      response.fold(
        (failure) => emit(state.copyWith(roundsLoaded: true, failure: failure.toString())),
        (rounds) => emit(state.copyWith(rounds: rounds, roundsLoaded: true)),
      );
    });
    // Nomes dos atletas para o histórico (o cache dos elegíveis).
    _athletesSub = _athletes(FantasyConfigDTO.forChampionship(championship)).listen((response) {
      if (isClosed) return;
      response.fold((_) {}, (list) => emit(state.copyWith(athletes: {for (final a in list) a.id: a})));
    });
    loadMore();
  }

  /// Próxima página de participantes.
  Future<void> loadMore() async {
    if (state.participantsLoading || !state.hasMore) return;
    emit(state.copyWith(participantsLoading: true));
    final last = state.participants.isEmpty ? null : state.participants.last.joinedAt;
    final response = await _participants(_fantasyId, before: last);
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(participantsLoading: false, hasMore: false, failure: failure.toString())),
      (page) => emit(state.copyWith(
        participants: [...state.participants, ...page],
        participantsLoading: false,
        hasMore: page.length >= 30 && page.last.joinedAt != null,
      )),
    );
  }

  /// Histórico do participante [uid]: a escalação em cada rodada fechada.
  Future<void> openParticipant(String uid) async {
    emit(state.copyWith(openUid: () => uid, history: const [], historyLoading: true));
    final items = <FantasyHistoryItem>[];
    for (final round in state.rounds.where((r) => r.closed)) {
      final response = await _lineup(_fantasyId, round.number, uid);
      if (isClosed || state.openUid != uid) return;
      final lineup = response.fold((_) => null, (l) => l);
      if (lineup == null) continue;
      int? position;
      if (lineup.points != null) {
        final result = await _position(_fantasyId, lineup.points!, round: round.number);
        position = result.fold((_) => null, (p) => p);
      }
      items.add(FantasyHistoryItem(round: round, lineup: lineup, position: position));
    }
    if (!isClosed && state.openUid == uid) emit(state.copyWith(history: items, historyLoading: false));
  }

  void closeParticipant() => emit(state.copyWith(openUid: () => null, history: const []));

  /// "Reapurar rodadas": as functions apuram de novo as rodadas fechadas.
  Future<void> rescore() async {
    if (state.rescoring) return;
    emit(state.copyWith(rescoring: true));
    final response = await _rescore(_fantasyId);
    if (isClosed) return;
    response.fold(
      (failure) =>
          emit(state.copyWith(rescoring: false, rescore: FantasyRescoreResult.failed, failure: failure.toString())),
      (_) => emit(state.copyWith(rescoring: false, rescore: FantasyRescoreResult.requested)),
    );
  }

  /// "Zerar pontuações (testes)": as functions zeram os pontos do Fantasy
  /// (participantes, escalações, auditoria, campeão e os cards do feed).
  Future<void> resetScores() async {
    final reset = _reset;
    if (reset == null || state.resetting) return;
    emit(state.copyWith(resetting: true));
    final response = await reset(_fantasyId);
    if (isClosed) return;
    response.fold(
      (failure) =>
          emit(state.copyWith(resetting: false, reset: FantasyResetResult.failed, failure: failure.toString())),
      (_) => emit(state.copyWith(resetting: false, reset: FantasyResetResult.requested)),
    );
  }

  /// "Zerar pontos de times": os atletas dos times [teamIds] perdem os pontos
  /// em todas as rodadas (o snackbar usa o mesmo aviso do "Zerar pontuações").
  Future<void> resetTeams(List<String> teamIds) async {
    final reset = _teamsReset;
    if (reset == null || teamIds.isEmpty || state.resetting) return;
    emit(state.copyWith(resetting: true));
    final response = await reset(_fantasyId, teamIds);
    if (isClosed) return;
    response.fold(
      (failure) =>
          emit(state.copyWith(resetting: false, reset: FantasyResetResult.failed, failure: failure.toString())),
      (_) => emit(state.copyWith(resetting: false, reset: FantasyResetResult.requested)),
    );
  }

  /// "Fechar agora" ([open] falso) ou "Reabrir" até [deadline] a rodada [round].
  Future<void> setRoundOpen(int round, {required bool open, DateTime? deadline}) async {
    final action = _roundAction;
    if (action == null) return;
    final response = await action(_fantasyId, round, open: open, deadline: deadline);
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(roundAction: FantasyRoundActionResult.failed, failure: failure.toString())),
      (_) => emit(state.copyWith(
          roundAction: open ? FantasyRoundActionResult.openRequested : FantasyRoundActionResult.closeRequested)),
    );
  }

  @override
  Future<void> close() async {
    await _roundsSub?.cancel();
    await _athletesSub?.cancel();
    return super.close();
  }
}
