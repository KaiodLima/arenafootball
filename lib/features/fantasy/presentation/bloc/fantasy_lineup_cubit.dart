import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_athlete_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_config_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_lineup_usecases.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_by_ids_usecase.dart';

/// Resultado da última ação (para o snackbar).
enum FantasyLineupEvent { none, joined, saved, failed }

class FantasyLineupState extends Equatable {
  final String uid;
  final FantasyConfigDTO? config;

  /// Rodada atual (nula = nenhuma rodada aberta ou ainda carregando).
  final FantasyRoundDTO? round;
  final bool participantLoaded;
  final FantasyParticipantDTO? participant;

  /// Escalação gravada na rodada (nula = ainda não montou).
  final FantasyLineupDTO? saved;
  final FantasyLineup draft;
  final List<FantasyAthleteDTO> athletes;
  final bool athletesLoaded;

  /// Times do campeonato por id (cores e escudo das figurinhas).
  final Map<String, TeamDTO> teams;
  final bool busy;
  final FantasyLineupEvent event;
  final String? failure;
  final DateTime now;

  const FantasyLineupState({
    this.uid = '',
    this.config,
    this.round,
    this.participantLoaded = false,
    this.participant,
    this.saved,
    this.draft = const FantasyLineup(),
    this.athletes = const [],
    this.athletesLoaded = false,
    this.teams = const {},
    this.busy = false,
    this.event = FantasyLineupEvent.none,
    this.failure,
    required this.now,
  });

  bool get loading => config == null || (uid.isNotEmpty && !participantLoaded);

  bool get isGuest => uid.isEmpty;

  bool get joined => participant != null;

  /// Rodada aberta e dentro do prazo: dá para montar/trocar.
  bool get roundOpen => round != null && round!.isOpenAt(now);

  bool get editable => joined && roundOpen && config?.active == true;

  Map<String, FantasyAthleteDTO> get athleteById => {for (final a in athletes) a.id: a};

  FantasyLineupError? get error => draft.validate((id) => athleteById[id]?.position ?? '');

  bool get dirty => draft != (saved?.lineup ?? const FantasyLineup());

  bool get canSave => editable && !busy && error == null && (dirty || (saved?.copied ?? false));

  FantasyLineupState copyWith({
    String? uid,
    FantasyConfigDTO? config,
    FantasyRoundDTO? Function()? round,
    bool? participantLoaded,
    FantasyParticipantDTO? Function()? participant,
    FantasyLineupDTO? Function()? saved,
    FantasyLineup? draft,
    List<FantasyAthleteDTO>? athletes,
    bool? athletesLoaded,
    Map<String, TeamDTO>? teams,
    bool? busy,
    FantasyLineupEvent? event,
    String? failure,
    DateTime? now,
  }) =>
      FantasyLineupState(
        uid: uid ?? this.uid,
        config: config ?? this.config,
        round: round != null ? round() : this.round,
        participantLoaded: participantLoaded ?? this.participantLoaded,
        participant: participant != null ? participant() : this.participant,
        saved: saved != null ? saved() : this.saved,
        draft: draft ?? this.draft,
        athletes: athletes ?? this.athletes,
        athletesLoaded: athletesLoaded ?? this.athletesLoaded,
        teams: teams ?? this.teams,
        busy: busy ?? this.busy,
        event: event ?? FantasyLineupEvent.none,
        failure: failure,
        now: now ?? this.now,
      );

  @override
  List<Object?> get props => [
        uid,
        config,
        round,
        participantLoaded,
        participant,
        saved,
        draft,
        athletes,
        athletesLoaded,
        teams,
        busy,
        event,
        failure,
        now,
      ];
}

/// "Montar meu time" no Arena Fantasy do campeonato: entra, escolhe os 5
/// atletas e o capitão da rodada aberta e confirma até o prazo.
class FantasyLineupCubit extends Cubit<FantasyLineupState> {
  final WatchFantasyConfigUseCase _watchConfig;
  final WatchFantasyRoundUseCase _watchRound;
  final WatchFantasyParticipantUseCase _watchParticipant;
  final WatchFantasyLineupUseCase _watchLineup;
  final JoinFantasyUseCase _join;
  final SaveFantasyLineupUseCase _save;
  final GetFantasyAthletesCacheFirstUseCase _athletes;
  final DateTime Function() _clock;

  /// Times do campeonato (cores das figurinhas); nulo = sem as cores (testes).
  final GetTeamsByIdsUseCase? _teams;

  /// Intervalo do relógio da tela (o prazo passa com ela aberta); nulo = sem relógio (testes).
  final Duration? _tick;

  FantasyLineupCubit(
    this._watchConfig,
    this._watchRound,
    this._watchParticipant,
    this._watchLineup,
    this._join,
    this._save,
    this._athletes, {
    DateTime Function()? clock,
    Duration? tick = const Duration(seconds: 30),
    GetTeamsByIdsUseCase? teams,
  })  : _clock = clock ?? DateTime.now,
        _tick = tick,
        _teams = teams,
        super(FantasyLineupState(now: (clock ?? DateTime.now)()));

  StreamSubscription<Object?>? _configSub;
  StreamSubscription<Object?>? _roundSub;
  StreamSubscription<Object?>? _participantSub;
  StreamSubscription<Object?>? _lineupSub;
  StreamSubscription<Object?>? _athletesSub;
  Timer? _ticker;
  int? _watchedRound;
  String _name = '';
  String _photoUrl = '';

  /// [uid]/[name]/[photoUrl]: a conta da sessão (vazio = convidado).
  void load(ChampionshipDTO championship, {required String uid, String name = '', String photoUrl = ''}) {
    _name = name;
    _photoUrl = photoUrl;
    emit(state.copyWith(uid: uid, participantLoaded: uid.isEmpty));
    _loadTeams(championship);
    _configSub?.cancel();
    _configSub = _watchConfig(championship).listen((response) {
      if (isClosed) return;
      response.fold((failure) => emit(state.copyWith(failure: failure.toString())), _onConfig);
    });
    // O prazo passa com a tela aberta: o relógio da tela anda a cada 30 s.
    _ticker?.cancel();
    final tick = _tick;
    if (tick != null) {
      _ticker = Timer.periodic(tick, (_) {
        if (!isClosed) emit(state.copyWith(now: _clock()));
      });
    }
  }

  /// Uma leitura dos times inscritos (cache do Firestore); falha = sem cores.
  Future<void> _loadTeams(ChampionshipDTO championship) async {
    final ids = championship.teamIds.where((id) => id.isNotEmpty).toList();
    final teams = _teams;
    if (teams == null || ids.isEmpty) return;
    final response = await teams(ids: ids, season: championship.season.isEmpty ? null : championship.season);
    if (isClosed) return;
    response.fold((_) {}, (list) => emit(state.copyWith(teams: {for (final t in list) t.id: t})));
  }

  void _onConfig(FantasyConfigDTO config) {
    final first = state.config == null;
    emit(state.copyWith(config: config));
    if (first) {
      _loadAthletes(config);
      if (state.uid.isNotEmpty) {
        _participantSub = _watchParticipant(config.championshipDocId, state.uid).listen((response) {
          if (isClosed) return;
          response.fold(
            (failure) => emit(state.copyWith(participantLoaded: true, failure: failure.toString())),
            (participant) => emit(state.copyWith(participantLoaded: true, participant: () => participant)),
          );
        });
      }
    }
    if (_watchedRound != config.currentRound) _followRound(config);
  }

  void _followRound(FantasyConfigDTO config) {
    _watchedRound = config.currentRound;
    _roundSub?.cancel();
    _lineupSub?.cancel();
    emit(state.copyWith(round: () => null, saved: () => null, draft: const FantasyLineup()));
    if (config.currentRound <= 0) return;
    _roundSub = _watchRound(config.championshipDocId, config.currentRound).listen((response) {
      if (isClosed) return;
      response.fold((failure) => emit(state.copyWith(failure: failure.toString())), (round) {
        emit(state.copyWith(round: () => round, now: _clock()));
      });
    });
    if (state.uid.isEmpty) return;
    _lineupSub = _watchLineup(config.championshipDocId, config.currentRound, state.uid).listen((response) {
      if (isClosed) return;
      response.fold((failure) => emit(state.copyWith(failure: failure.toString())), (lineup) {
        // Edição em andamento não é atropelada pelo servidor.
        final keep = state.dirty && state.saved != null;
        emit(
            state.copyWith(saved: () => lineup, draft: keep ? state.draft : (lineup?.lineup ?? const FantasyLineup())));
      });
    });
  }

  void _loadAthletes(FantasyConfigDTO config, {bool force = false}) {
    _athletesSub?.cancel();
    _athletesSub = _athletes(config, force: force).listen((response) {
      if (isClosed) return;
      response.fold(
        (failure) => emit(state.copyWith(athletesLoaded: true, failure: failure.toString())),
        (athletes) => emit(state.copyWith(athletes: athletes, athletesLoaded: true)),
      );
    });
  }

  void refreshAthletes() {
    final config = state.config;
    if (config != null) _loadAthletes(config, force: true);
  }

  Future<void> join() async {
    final config = state.config;
    if (config == null || state.isGuest || state.joined || state.busy || !config.active) return;
    emit(state.copyWith(busy: true));
    final response = await _join(config, uid: state.uid, name: _name, photoUrl: _photoUrl);
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(busy: false, event: FantasyLineupEvent.failed, failure: failure.toString())),
      (_) => emit(state.copyWith(busy: false, event: FantasyLineupEvent.joined)),
    );
  }

  void place(FantasySlot slot, String athleteId) {
    if (!state.editable) return;
    emit(state.copyWith(draft: state.draft.place(slot, athleteId)));
  }

  void remove(FantasySlot slot) {
    if (!state.editable) return;
    emit(state.copyWith(draft: state.draft.remove(slot)));
  }

  void setCaptain(String athleteId) {
    if (!state.editable) return;
    emit(state.copyWith(draft: state.draft.withCaptain(athleteId)));
  }

  /// Volta para a escalação gravada.
  void discard() => emit(state.copyWith(draft: state.saved?.lineup ?? const FantasyLineup()));

  Future<void> save() async {
    final config = state.config;
    final round = state.round;
    emit(state.copyWith(now: _clock()));
    if (config == null || round == null || !state.canSave) return;
    emit(state.copyWith(busy: true));
    final lineup = FantasyLineupDTO(
      uid: state.uid,
      name: state.participant?.name.isNotEmpty == true ? state.participant!.name : _name,
      photoUrl: state.participant?.photoUrl ?? _photoUrl,
      lineup: state.draft,
    );
    final response = await _save(config.championshipDocId, round.number, lineup);
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(busy: false, event: FantasyLineupEvent.failed, failure: failure.toString())),
      (_) => emit(state.copyWith(
        busy: false,
        event: FantasyLineupEvent.saved,
        saved: () =>
            FantasyLineupDTO(uid: lineup.uid, name: lineup.name, photoUrl: lineup.photoUrl, lineup: lineup.lineup),
      )),
    );
  }

  @override
  Future<void> close() async {
    _ticker?.cancel();
    await Future.wait([
      for (final sub in [_configSub, _roundSub, _participantSub, _lineupSub, _athletesSub])
        if (sub != null) sub.cancel(),
    ]);
    return super.close();
  }
}
