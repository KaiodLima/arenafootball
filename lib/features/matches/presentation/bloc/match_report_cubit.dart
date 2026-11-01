import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/match_report.dart';
import 'package:arena_soccer/features/matches/domain/match_squads.dart';
import 'package:arena_soccer/features/matches/domain/usecases/save_match_report_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/set_match_phase_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/toggle_match_voting_usecase.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/players/domain/usecases/create_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';

/// Situação do atleta na escalação.
enum LineupRole { none, starter, sub }

/// Aviso de ação concluída na súmula.
enum MatchReportNotice { saved, playerAdded, phaseChanged, eventAdded }

class MatchReportState extends Equatable {
  /// A partida como está gravada (base do "tem mudança") e a em edição.
  final MatchDTO? original;
  final MatchDTO? match;

  /// Gols de quando abriu (base da diferença nos números dos atletas).
  final List<MatchGoal> goalsBefore;
  final List<PlayerDTO> homeSquad;
  final List<PlayerDTO> awaySquad;
  final bool loadingSquads;
  final bool saving;

  /// Ação imediata em andamento (fase do jogo, votação, atleta novo).
  final bool busy;
  final bool publishCards;
  final MatchReportNotice? notice;

  /// Cards de gol publicados no último salvar (−1 = falhou).
  final int publishedCards;
  final String? errorMessage;

  /// Último lance lançado (o "Desfazer" do aviso).
  final ReportEvent? lastEvent;

  const MatchReportState({
    this.original,
    this.match,
    this.goalsBefore = const [],
    this.homeSquad = const [],
    this.awaySquad = const [],
    this.loadingSquads = true,
    this.saving = false,
    this.busy = false,
    this.publishCards = true,
    this.notice,
    this.publishedCards = 0,
    this.errorMessage,
    this.lastEvent,
  });

  List<PlayerDTO> squadOf(MatchSide side) => side == MatchSide.home ? homeSquad : awaySquad;

  /// Atletas para os lances: os relacionados do lado (se lançou escalação),
  /// senão o elenco da competição.
  List<PlayerDTO> pickableOf(MatchSide side) {
    final squad = squadOf(side);
    final lineup = match?.lineup.of(side) ?? const [];
    if (lineup.isEmpty) return squad;
    final ids = {for (final e in lineup) e.playerId};
    return squad.where((p) => ids.contains(p.id)).toList();
  }

  List<ReportEvent> get timeline => match == null ? const [] : MatchReport.timeline(match!.goals, match!.bookings);

  LineupRole roleOf(MatchSide side, String playerId) {
    final entry = match?.lineup.of(side).where((e) => e.playerId == playerId).firstOrNull;
    if (entry == null) return LineupRole.none;
    return entry.starter ? LineupRole.starter : LineupRole.sub;
  }

  /// Algo da súmula mudou desde que abriu (a fase e a votação gravam na hora).
  bool get dirty {
    final a = original;
    final b = match;
    if (a == null || b == null) return false;
    final goalsSame = goalsBefore.length == b.goals.length &&
        ![for (var i = 0; i < b.goals.length; i++) goalsBefore[i] == b.goals[i]].contains(false);
    return !goalsSame ||
        a.bookings.length != b.bookings.length ||
        [for (var i = 0; i < b.bookings.length; i++) a.bookings[i] == b.bookings[i]].contains(false) ||
        a.lineup != b.lineup ||
        a.referee != b.referee ||
        a.notes != b.notes ||
        a.date != b.date ||
        a.time != b.time ||
        a.venue != b.venue ||
        a.durationMinutes != b.durationMinutes;
  }

  /// Quantas mudanças a súmula tem desde que abriu (a barra de salvar).
  int get changeCount {
    final a = original;
    final b = match;
    if (a == null || b == null) return 0;
    int diff<T>(List<T> before, List<T> after, String Function(T) id) {
      final old = {for (final x in before) id(x): x};
      final now = {for (final x in after) id(x): x};
      final ids = {...old.keys, ...now.keys};
      return ids.where((k) => old[k] != now[k]).length;
    }

    var count = diff<MatchGoal>(goalsBefore, b.goals, (g) => g.id) +
        diff<MatchBooking>(a.bookings, b.bookings, (c) => c.id);
    for (final side in MatchSide.values) {
      count += diff<LineupEntry>(a.lineup.of(side), b.lineup.of(side), (e) => e.playerId);
    }
    count += [
      a.referee != b.referee,
      a.notes != b.notes,
      a.date != b.date,
      a.time != b.time,
      a.venue != b.venue,
      a.durationMinutes != b.durationMinutes,
    ].where((changed) => changed).length;
    return count;
  }

  /// Gols novos desde que abriu (os que viram card).
  int get newGoals {
    final ids = {for (final g in goalsBefore) g.id};
    return (match?.goals ?? const []).where((g) => !ids.contains(g.id)).length;
  }

  MatchReportState copyWith({
    MatchDTO? original,
    MatchDTO? match,
    List<MatchGoal>? goalsBefore,
    List<PlayerDTO>? homeSquad,
    List<PlayerDTO>? awaySquad,
    bool? loadingSquads,
    bool? saving,
    bool? busy,
    bool? publishCards,
    MatchReportNotice? Function()? notice,
    int? publishedCards,
    String? Function()? errorMessage,
    ReportEvent? Function()? lastEvent,
  }) {
    return MatchReportState(
      original: original ?? this.original,
      match: match ?? this.match,
      goalsBefore: goalsBefore ?? this.goalsBefore,
      homeSquad: homeSquad ?? this.homeSquad,
      awaySquad: awaySquad ?? this.awaySquad,
      loadingSquads: loadingSquads ?? this.loadingSquads,
      saving: saving ?? this.saving,
      busy: busy ?? this.busy,
      publishCards: publishCards ?? this.publishCards,
      notice: notice != null ? notice() : null,
      publishedCards: publishedCards ?? this.publishedCards,
      errorMessage: errorMessage != null ? errorMessage() : null,
      lastEvent: lastEvent != null ? lastEvent() : this.lastEvent,
    );
  }

  @override
  List<Object?> get props => [
        original,
        match,
        goalsBefore,
        homeSquad,
        awaySquad,
        loadingSquads,
        saving,
        busy,
        publishCards,
        notice,
        publishedCards,
        errorMessage,
        lastEvent,
      ];
}

/// Súmula da partida (admin): lances (gols e cartões com minuto), escalação,
/// dados do jogo, fases e votação. Lances, escalação e dados ficam em edição
/// até "Salvar súmula"; fase, votação e atleta novo gravam na hora.
class MatchReportCubit extends Cubit<MatchReportState> {
  final WatchTeamPlayersUseCase watchTeamPlayersUseCase;
  final SaveMatchReportUseCase saveMatchReportUseCase;
  final SetMatchPhaseUseCase setMatchPhaseUseCase;
  final ToggleMatchVotingUseCase toggleMatchVotingUseCase;
  final CreatePlayerUseCase createPlayerUseCase;
  String? _season;

  MatchReportCubit(
    this.watchTeamPlayersUseCase,
    this.saveMatchReportUseCase,
    this.setMatchPhaseUseCase,
    this.toggleMatchVotingUseCase,
    this.createPlayerUseCase,
  ) : super(const MatchReportState());

  Future<void> load({required MatchDTO match, String? season, String Function()? newId}) async {
    _season = season;
    final goals = MatchGoal.forEditing(
      saved: match.goals,
      homeGoals: match.homeGoals,
      awayGoals: match.awayGoals,
      newId: newId ?? MatchGoal.newId,
    );
    final opened = match.copyWith(goals: goals);
    emit(MatchReportState(original: opened, match: opened, goalsBefore: goals));
    final home = watchTeamPlayersUseCase(teamId: match.homeTeamId, teamName: match.homeTeam, season: season).first;
    final away = watchTeamPlayersUseCase(teamId: match.awayTeamId, teamName: match.awayTeam, season: season).first;
    final homeResponse = await home;
    final awayResponse = await away;
    if (isClosed) return;
    emit(state.copyWith(
      homeSquad: homeResponse.fold((_) => const [], (list) => matchSquad(list, match, MatchSide.home)),
      awaySquad: awayResponse.fold((_) => const [], (list) => matchSquad(list, match, MatchSide.away)),
      loadingSquads: false,
    ));
  }

  void _edit(MatchDTO match) => emit(state.copyWith(match: match));

  // ------------------------------------------------------------------ lances

  void addGoal(MatchSide side, {PlayerDTO? scorer, PlayerDTO? assistant, int? minute, String Function()? newId}) {
    final match = state.match;
    if (match == null) return;
    final validAssist = assistant != null && assistant.id != scorer?.id ? assistant : null;
    final goal = MatchGoal(
      id: (newId ?? MatchGoal.newId)(),
      side: side,
      scorerId: scorer?.id ?? '',
      scorerName: scorer?.name ?? '',
      assistantId: validAssist?.id ?? '',
      assistantName: validAssist?.name ?? '',
      minute: minute,
    );
    emit(state.copyWith(
      match: match.copyWith(goals: [...match.goals, goal]),
      lastEvent: () => ReportEvent.goal(goal),
      notice: () => MatchReportNotice.eventAdded,
    ));
  }

  void updateGoal(String id, {PlayerDTO? scorer, PlayerDTO? assistant, int? minute}) {
    final match = state.match;
    if (match == null) return;
    final validAssist = assistant != null && assistant.id != scorer?.id ? assistant : null;
    _edit(match.copyWith(goals: [
      for (final g in match.goals)
        if (g.id != id)
          g
        else
          MatchGoal(
            id: g.id,
            side: g.side,
            scorerId: scorer?.id ?? '',
            scorerName: scorer?.name ?? '',
            assistantId: validAssist?.id ?? '',
            assistantName: validAssist?.name ?? '',
            minute: minute,
          ),
    ]));
  }

  void removeGoal(String id) {
    final match = state.match;
    if (match == null) return;
    _edit(match.copyWith(goals: match.goals.where((g) => g.id != id).toList()));
  }

  void addBooking(MatchSide side, {required PlayerDTO player, required BookingType type, int? minute}) {
    final match = state.match;
    if (match == null) return;
    final booking = MatchBooking(
      id: MatchBooking.newId(),
      side: side,
      type: type,
      playerId: player.id,
      playerName: player.name,
      minute: minute,
    );
    emit(state.copyWith(
      match: match.copyWith(bookings: MatchReport.addBooking(match.bookings, booking)),
      lastEvent: () => ReportEvent.booking(booking),
      notice: () => MatchReportNotice.eventAdded,
    ));
  }

  /// "Desfazer" do aviso: tira o último lance lançado (o vermelho de 2º
  /// amarelo sai junto com o amarelo).
  void undoLast() {
    final event = state.lastEvent;
    if (event == null) return;
    event.isGoal ? removeGoal(event.id) : removeBooking(event.id);
    emit(state.copyWith(lastEvent: () => null));
  }

  void removeBooking(String id) {
    final match = state.match;
    if (match == null) return;
    _edit(match.copyWith(bookings: MatchReport.removeBooking(match.bookings, id)));
  }

  // --------------------------------------------------------------- escalação

  void setRole(MatchSide side, PlayerDTO player, LineupRole role) {
    final match = state.match;
    if (match == null) return;
    final current = match.lineup.of(side);
    final existing = current.where((e) => e.playerId == player.id).firstOrNull;
    final rest = current.where((e) => e.playerId != player.id).toList();
    final entries = role == LineupRole.none
        ? rest
        : [
            ...rest,
            (existing ?? LineupEntry(playerId: player.id, playerName: player.name))
                .copyWith(starter: role == LineupRole.starter),
          ];
    _edit(match.copyWith(lineup: match.lineup.withSide(side, entries)));
  }

  void setNumber(MatchSide side, String playerId, int? number) {
    final match = state.match;
    if (match == null) return;
    final entries = [
      for (final e in match.lineup.of(side)) e.playerId == playerId ? e.copyWith(number: () => number) : e,
    ];
    _edit(match.copyWith(lineup: match.lineup.withSide(side, entries)));
  }

  /// Cadastro rápido: o atleta entra no time e na competição da partida e
  /// na escalação (titular até completar 11; depois, reserva).
  Future<void> addPlayer(MatchSide side, {required String name, String position = '', File? photo}) async {
    final match = state.match;
    if (match == null || state.busy) return;
    emit(state.copyWith(busy: true));
    final home = side == MatchSide.home;
    final teamId = home ? match.homeTeamId : match.awayTeamId;
    final team = home ? match.homeTeam : match.awayTeam;
    final player = PlayerDTO(
      id: MatchReport.newDocId(),
      name: name.trim(),
      team: team,
      teamId: teamId,
      position: position,
      enrollments: [
        if (match.championshipId > 0)
          PlayerEnrollment(championshipId: match.championshipId, teamId: teamId, team: team),
      ],
      hasEnrollmentField: match.championshipId > 0,
    );
    final response = await createPlayerUseCase(player, photo: photo);
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(busy: false, errorMessage: () => failure.toString())),
      (created) {
        final squad = [...state.squadOf(side), created]
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        emit(state.copyWith(
          busy: false,
          homeSquad: home ? squad : null,
          awaySquad: home ? null : squad,
          notice: () => MatchReportNotice.playerAdded,
        ));
        final starters = MatchReport.lineupCount(state.match!.lineup.of(side)).starters;
        setRole(side, created, starters < 11 ? LineupRole.starter : LineupRole.sub);
      },
    );
  }

  // ------------------------------------------------------------ dados do jogo

  void setInfo({String? date, String? time, int? durationMinutes, String? venue, String? referee, String? notes}) {
    final match = state.match;
    if (match == null) return;
    _edit(match.copyWith(
      date: date,
      time: time,
      durationMinutes: durationMinutes,
      venue: venue,
      referee: referee,
      notes: notes,
    ));
  }

  void togglePublishCards(bool value) => emit(state.copyWith(publishCards: value));

  // ------------------------------------------------------ ações que gravam já

  Future<void> setPhase(MatchPhase phase) async {
    final match = state.match;
    if (match == null || state.busy) return;
    emit(state.copyWith(busy: true));
    final response = await setMatchPhaseUseCase(match: match, phase: phase, season: _season);
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(busy: false, errorMessage: () => failure.toString())),
      (updated) => emit(state.copyWith(busy: false, match: updated, notice: () => MatchReportNotice.phaseChanged)),
    );
  }

  Future<void> toggleVoting() async {
    final match = state.match;
    if (match == null || state.busy) return;
    emit(state.copyWith(busy: true));
    final response = await toggleMatchVotingUseCase(match: match, season: _season);
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(busy: false, errorMessage: () => failure.toString())),
      (updated) => emit(state.copyWith(
        busy: false,
        match: match.copyWith(isVotingOpen: updated.isVotingOpen),
        original: state.original?.copyWith(isVotingOpen: updated.isVotingOpen),
      )),
    );
  }

  Future<void> save() async {
    final original = state.original;
    final match = state.match;
    if (original == null || match == null || state.saving || !state.dirty) return;
    emit(state.copyWith(saving: true));
    final response = await saveMatchReportUseCase(
      original: original,
      goalsBefore: state.goalsBefore,
      edited: match,
      publishCards: state.publishCards,
      season: _season,
    );
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(saving: false, errorMessage: () => failure.toString())),
      (saved) => emit(state.copyWith(
        saving: false,
        original: saved.match,
        match: saved.match,
        goalsBefore: saved.match.goals,
        publishedCards: saved.publishedCards,
        notice: () => MatchReportNotice.saved,
      )),
    );
  }
}
