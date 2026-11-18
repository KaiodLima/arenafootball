import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_athlete_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_config_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_lineup_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_ranking_usecases.dart';

/// Posição da conta num ranking: os pontos e a colocação (nulos = não jogou).
class FantasyMyPosition extends Equatable {
  final double? points;
  final int? position;

  const FantasyMyPosition({this.points, this.position});

  @override
  List<Object?> get props => [points, position];
}

class FantasyRankingState extends Equatable {
  final String uid;
  final FantasyConfigDTO? config;

  /// Rodadas fechadas, a mais recente primeiro.
  final List<FantasyRoundDTO> rounds;
  final bool roundsLoaded;
  final int? selectedRound;
  final List<FantasyRankingEntry> roundEntries;
  final bool roundLoading;
  final FantasyMyPosition myRound;
  final List<FantasyRankingEntry> overallEntries;
  final bool overallLoading;
  final FantasyMyPosition myOverall;
  final List<FantasyHistoryItem> history;
  final bool historyLoading;
  final bool historyLoaded;
  final Map<String, FantasyAthleteDTO> athletes;
  final String? failure;

  const FantasyRankingState({
    this.uid = '',
    this.config,
    this.rounds = const [],
    this.roundsLoaded = false,
    this.selectedRound,
    this.roundEntries = const [],
    this.roundLoading = false,
    this.myRound = const FantasyMyPosition(),
    this.overallEntries = const [],
    this.overallLoading = true,
    this.myOverall = const FantasyMyPosition(),
    this.history = const [],
    this.historyLoading = false,
    this.historyLoaded = false,
    this.athletes = const {},
    this.failure,
  });

  FantasyRoundDTO? get round => rounds.where((r) => r.number == selectedRound).firstOrNull;

  /// Índice da rodada escolhida na lista (0 = a mais recente).
  int get _index => rounds.indexWhere((r) => r.number == selectedRound);

  /// Há rodada mais antiga / mais nova para as setas.
  bool get hasOlder => _index >= 0 && _index < rounds.length - 1;

  bool get hasNewer => _index > 0;

  FantasyRankingState copyWith({
    String? uid,
    FantasyConfigDTO? config,
    List<FantasyRoundDTO>? rounds,
    bool? roundsLoaded,
    int? Function()? selectedRound,
    List<FantasyRankingEntry>? roundEntries,
    bool? roundLoading,
    FantasyMyPosition? myRound,
    List<FantasyRankingEntry>? overallEntries,
    bool? overallLoading,
    FantasyMyPosition? myOverall,
    List<FantasyHistoryItem>? history,
    bool? historyLoading,
    bool? historyLoaded,
    Map<String, FantasyAthleteDTO>? athletes,
    String? failure,
  }) =>
      FantasyRankingState(
        uid: uid ?? this.uid,
        config: config ?? this.config,
        rounds: rounds ?? this.rounds,
        roundsLoaded: roundsLoaded ?? this.roundsLoaded,
        selectedRound: selectedRound != null ? selectedRound() : this.selectedRound,
        roundEntries: roundEntries ?? this.roundEntries,
        roundLoading: roundLoading ?? this.roundLoading,
        myRound: myRound ?? this.myRound,
        overallEntries: overallEntries ?? this.overallEntries,
        overallLoading: overallLoading ?? this.overallLoading,
        myOverall: myOverall ?? this.myOverall,
        history: history ?? this.history,
        historyLoading: historyLoading ?? this.historyLoading,
        historyLoaded: historyLoaded ?? this.historyLoaded,
        athletes: athletes ?? this.athletes,
        failure: failure,
      );

  @override
  List<Object?> get props => [
        uid,
        config,
        rounds,
        roundsLoaded,
        selectedRound,
        roundEntries,
        roundLoading,
        myRound,
        overallEntries,
        overallLoading,
        myOverall,
        history,
        historyLoading,
        historyLoaded,
        athletes,
        failure,
      ];
}

/// Rankings do Arena Fantasy (rodada e geral) e o histórico da conta.
class FantasyRankingCubit extends Cubit<FantasyRankingState> {
  final WatchFantasyConfigUseCase _watchConfig;
  final GetFantasyRankingCacheFirstUseCase _ranking;
  final GetFantasyPositionUseCase _position;
  final GetFantasyRoundsUseCase _rounds;
  final GetFantasyLineupUseCase _lineup;
  final WatchFantasyParticipantUseCase _participant;
  final GetFantasyAthletesCacheFirstUseCase _athletes;

  FantasyRankingCubit(
    this._watchConfig,
    this._ranking,
    this._position,
    this._rounds,
    this._lineup,
    this._participant,
    this._athletes,
  ) : super(const FantasyRankingState());

  StreamSubscription<Object?>? _configSub;
  StreamSubscription<Object?>? _roundSub;
  StreamSubscription<Object?>? _overallSub;
  StreamSubscription<Object?>? _athletesSub;
  String _fantasyId = '';

  Future<void> load(ChampionshipDTO championship, {required String uid}) async {
    _fantasyId = championship.id;
    emit(state.copyWith(uid: uid));
    _configSub = _watchConfig(championship).listen((response) {
      if (isClosed) return;
      response.fold((_) {}, (config) {
        final first = state.config == null;
        emit(state.copyWith(config: config));
        if (first) _loadAthletes(config);
      });
    });
    _loadOverall();
    final rounds = await _rounds(_fantasyId);
    if (isClosed) return;
    final closed = rounds.fold((_) => const <FantasyRoundDTO>[], (list) => list.where((r) => r.closed).toList())
      ..sort((a, b) => b.number.compareTo(a.number));
    emit(state.copyWith(rounds: closed, roundsLoaded: true, failure: rounds.isLeft ? rounds.left.toString() : null));
    if (closed.isNotEmpty) selectRound(closed.first.number);
  }

  void _loadAthletes(FantasyConfigDTO config) {
    _athletesSub = _athletes(config).listen((response) {
      if (isClosed) return;
      response.fold((_) {}, (list) => emit(state.copyWith(athletes: {for (final a in list) a.id: a})));
    });
  }

  void _loadOverall({bool force = false}) {
    _overallSub?.cancel();
    emit(state.copyWith(overallLoading: true));
    _overallSub = _ranking(_fantasyId, force: force).listen((response) async {
      if (isClosed) return;
      final entries = sortFantasyRanking(response.fold((_) => const [], (list) => list));
      emit(state.copyWith(overallEntries: entries, overallLoading: false));
      final mine = await _myOverall(entries);
      if (!isClosed) emit(state.copyWith(myOverall: mine));
    });
  }

  Future<FantasyMyPosition> _myOverall(List<FantasyRankingEntry> entries) async {
    if (state.uid.isEmpty) return const FantasyMyPosition();
    final index = entries.indexWhere((e) => e.uid == state.uid);
    if (index >= 0) return FantasyMyPosition(points: entries[index].points, position: fantasyPositions(entries)[index]);
    final participant = await _participant(_fantasyId, state.uid).first;
    final points = participant.fold((_) => null, (p) => p?.points);
    if (points == null) return const FantasyMyPosition();
    final position = await _position(_fantasyId, points);
    return FantasyMyPosition(points: points, position: position.fold((_) => null, (p) => p));
  }

  /// Mostra o ranking da rodada [round].
  void selectRound(int round, {bool force = false}) {
    _roundSub?.cancel();
    emit(state.copyWith(selectedRound: () => round, roundLoading: true, myRound: const FantasyMyPosition()));
    _roundSub = _ranking(_fantasyId, round: round, force: force).listen((response) async {
      if (isClosed || state.selectedRound != round) return;
      final entries = sortFantasyRanking(response.fold((_) => const [], (list) => list));
      emit(state.copyWith(roundEntries: entries, roundLoading: false));
      final mine = await _myRound(round, entries);
      if (!isClosed && state.selectedRound == round) emit(state.copyWith(myRound: mine));
    });
  }

  Future<FantasyMyPosition> _myRound(int round, List<FantasyRankingEntry> entries) async {
    if (state.uid.isEmpty) return const FantasyMyPosition();
    final index = entries.indexWhere((e) => e.uid == state.uid);
    if (index >= 0) return FantasyMyPosition(points: entries[index].points, position: fantasyPositions(entries)[index]);
    final lineup = await _lineup(_fantasyId, round, state.uid);
    final points = lineup.fold((_) => null, (l) => l?.points);
    if (points == null) return const FantasyMyPosition();
    final position = await _position(_fantasyId, points, round: round);
    return FantasyMyPosition(points: points, position: position.fold((_) => null, (p) => p));
  }

  /// Setas: rodada mais antiga / mais nova.
  void olderRound() {
    if (!state.hasOlder) return;
    selectRound(state.rounds[state.rounds.indexWhere((r) => r.number == state.selectedRound) + 1].number);
  }

  void newerRound() {
    if (!state.hasNewer) return;
    selectRound(state.rounds[state.rounds.indexWhere((r) => r.number == state.selectedRound) - 1].number);
  }

  /// Puxar para atualizar (ignora a validade do cache).
  void refresh() {
    _loadOverall(force: true);
    final round = state.selectedRound;
    if (round != null) selectRound(round, force: true);
  }

  /// Histórico da conta: a escalação de cada rodada fechada e a posição nela
  /// (uma leitura por rodada; carregado ao abrir a aba).
  Future<void> loadHistory({bool force = false}) async {
    if (state.uid.isEmpty || state.historyLoading || (state.historyLoaded && !force)) return;
    emit(state.copyWith(historyLoading: true));
    final items = <FantasyHistoryItem>[];
    for (final round in state.rounds) {
      final response = await _lineup(_fantasyId, round.number, state.uid);
      if (isClosed) return;
      final lineup = response.fold((_) => null, (l) => l);
      if (lineup == null) continue;
      int? position;
      if (lineup.points != null) {
        final result = await _position(_fantasyId, lineup.points!, round: round.number);
        position = result.fold((_) => null, (p) => p);
      }
      items.add(FantasyHistoryItem(round: round, lineup: lineup, position: position));
    }
    if (!isClosed) emit(state.copyWith(history: items, historyLoading: false, historyLoaded: true));
  }

  @override
  Future<void> close() async {
    await Future.wait([
      for (final sub in [_configSub, _roundSub, _overallSub, _athletesSub])
        if (sub != null) sub.cancel(),
    ]);
    return super.close();
  }
}
