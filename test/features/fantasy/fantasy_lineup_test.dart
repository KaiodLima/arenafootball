import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_athlete_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_score_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_ranking_usecases.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_top_athletes.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';
import 'package:arena_soccer/features/fantasy/domain/repositories/fantasy_repository_interface.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_config_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_lineup_usecases.dart';
import 'package:arena_soccer/features/fantasy/presentation/bloc/fantasy_lineup_cubit.dart';
import 'package:arena_soccer/features/fantasy/presentation/page/fantasy_lineup_page.dart';
import 'package:arena_soccer/features/fantasy/presentation/page/fantasy_rules_page.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/features/album/presentation/widgets/sticker_card.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_athlete_picker.dart';
import 'package:arena_soccer/features/fantasy/presentation/widgets/fantasy_pitch.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

const _copa = ChampionshipDTO(id: 'doc1', championshipId: 8, title: 'Copa Verde', region: 'Floresta', season: '2026');

const _athletes = [
  FantasyAthleteDTO(id: 'gk', name: 'Rafael Goleiro', position: 'goleiro', teamId: 't1', team: 'Leões', goals: 0),
  FantasyAthleteDTO(id: 'lb', name: 'Lucas Lateral', position: 'lateral', teamId: 't1', team: 'Leões'),
  FantasyAthleteDTO(id: 'mf', name: 'Mateus Meia', position: 'meia', teamId: 't2', team: 'Tigres', goals: 3),
  FantasyAthleteDTO(id: 'fw', name: 'Ângelo Atacante', position: 'atacante', teamId: 't2', team: 'Tigres', goals: 7),
  FantasyAthleteDTO(id: 'dm', name: 'Davi Volante', position: 'volante', teamId: 't1', team: 'Leões'),
];

class _Repo implements IFantasyRepository {
  final config = StreamController<Either<Failure, FantasyConfigDTO>>.broadcast();
  final round = StreamController<Either<Failure, FantasyRoundDTO?>>.broadcast();
  final participant = StreamController<Either<Failure, FantasyParticipantDTO?>>.broadcast();
  final lineup = StreamController<Either<Failure, FantasyLineupDTO?>>.broadcast();
  final joined = <String>[];
  final saved = <(int, FantasyLineupDTO)>[];

  @override
  Future<Either<Failure, List<FantasyRoundDTO>>> getRounds(String fantasyId) async => Right([
        FantasyRoundDTO.fromMap('1', {'status': 'fechada'}),
        FantasyRoundDTO.fromMap('3', {'status': 'fechada'}),
        FantasyRoundDTO.fromMap('4', {'status': 'aberta'}),
      ]);

  final top = <int, List<FantasyAthleteScoreDTO>>{
    1: [
      FantasyAthleteScoreDTO.fromMap(
          'fw', {'nome': 'Ângelo Atacante', 'time': 'Tigres', 'total': 22, 'posicao': 'ata'}),
      FantasyAthleteScoreDTO.fromMap('mf', {'nome': 'Mateus Meia', 'total': 15, 'posicao': 'mei'}),
    ],
    3: [
      FantasyAthleteScoreDTO.fromMap('gk', {'nome': 'Rafael Goleiro', 'time': 'Leões', 'total': 18, 'posicao': 'gol'}),
      FantasyAthleteScoreDTO.fromMap('cb', {'nome': 'Caio Zagueiro', 'total': 18, 'posicao': 'zag'}),
      FantasyAthleteScoreDTO.fromMap('dm', {'nome': 'Davi Volante', 'total': 9, 'posicao': 'mei'}),
    ],
  };

  @override
  Future<Either<Failure, List<FantasyAthleteScoreDTO>>> getTopAthletes(String fantasyId, int round) async =>
      Right(top[round] ?? const []);

  @override
  Future<Either<Failure, CachedValue<List<FantasyAthleteScoreDTO>>?>> getCachedTopAthletes(
          String fantasyId, int round) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> saveTopAthletesCache(
          String fantasyId, int round, List<FantasyAthleteScoreDTO> list) async =>
      const Right(null);

  @override
  Stream<Either<Failure, FantasyConfigDTO>> watchConfig(ChampionshipDTO championship) => config.stream;

  @override
  Stream<Either<Failure, FantasyRoundDTO?>> watchRound(String fantasyId, int round) => this.round.stream;

  @override
  Stream<Either<Failure, FantasyParticipantDTO?>> watchParticipant(String fantasyId, String uid) => participant.stream;

  @override
  Stream<Either<Failure, FantasyLineupDTO?>> watchLineup(String fantasyId, int round, String uid) => lineup.stream;

  @override
  Future<Either<Failure, void>> join(String fantasyId,
      {required String uid, required String name, required String photoUrl, required int currentRound}) async {
    joined.add('$uid@$currentRound');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> saveLineup(String fantasyId, int round, FantasyLineupDTO lineup) async {
    saved.add((round, lineup));
    return const Right(null);
  }

  @override
  Future<Either<Failure, CachedValue<List<FantasyAthleteDTO>>?>> getCachedAthletes(FantasyConfigDTO config) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<FantasyAthleteDTO>>> getEligibleAthletes(FantasyConfigDTO config) async =>
      const Right(_athletes);

  @override
  Future<Either<Failure, void>> saveAthletesCache(FantasyConfigDTO config, List<FantasyAthleteDTO> athletes) async =>
      const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Com a rodada 1 encerrada (resultado) e a 2 aberta.
class _PastRepo extends _Repo {
  final DateTime processedAt;

  _PastRepo(this.processedAt);

  @override
  Stream<Either<Failure, FantasyRoundDTO?>> watchRound(String fantasyId, int round) => round == 1
      ? Stream.value(Right(FantasyRoundDTO.fromMap('1', {
          'status': 'fechada',
          'fechaEm': Timestamp.fromDate(DateTime(2026, 11, 17, 16)),
          'idsPartidas': ['m1'],
          'finalizada': true,
          'apuracao': {'partidas': 1, 'encerradas': 1, 'processadoEm': Timestamp.fromDate(processedAt)},
        })))
      : super.watchRound(fantasyId, round);

  @override
  Stream<Either<Failure, FantasyLineupDTO?>> watchLineup(String fantasyId, int round, String uid) => round == 1
      ? Stream.value(Right(FantasyLineupDTO(
          uid: 'u1',
          lineup: _full,
          points: 20,
          athletePoints: {'fw': 22.5, 'gk': -2.5, 'lb': 0, 'mf': 0, 'dm': 0},
          playedIds: ['fw', 'gk'],
        )))
      : super.watchLineup(fantasyId, round, uid);

  @override
  Future<Either<Failure, List<FantasyRoundDTO>>> getRounds(String fantasyId) async => Right([
        FantasyRoundDTO.fromMap('1', {'status': 'fechada'}),
        FantasyRoundDTO.fromMap('2', {'status': 'aberta'}),
      ]);
}

class _Session extends Cubit<SessionState> implements SessionCubit {
  _Session() : super(const SessionState(user: UserDTO(id: 'u1', name: 'Ana', email: 'a@x.com', isAdmin: false)));

  /// Convidado (sem conta): ex. quem chegou pelo link `/fantasy/<id>`.
  _Session.guest() : super(const SessionState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _now = DateTime(2026, 11, 18, 12);

FantasyLineupCubit _cubit(_Repo repo) => FantasyLineupCubit(
      WatchFantasyConfigUseCase(repo),
      WatchFantasyRoundUseCase(repo),
      WatchFantasyParticipantUseCase(repo),
      WatchFantasyLineupUseCase(repo),
      JoinFantasyUseCase(repo),
      SaveFantasyLineupUseCase(repo),
      GetFantasyAthletesCacheFirstUseCase(repo),
      clock: () => _now,
      tick: null,
    );

final _config = FantasyConfigDTO.fromMap('doc1', {'ativo': true, 'rodadaAtual': 2}, championship: _copa);
final _openRound = FantasyRoundDTO(number: 2, status: 'aberta', closesAt: DateTime(2026, 11, 20, 18));

Future<void> _tick() => Future<void>.delayed(Duration.zero);

final _full = FantasyLineup(
  athletes: {
    FantasySpot(FantasySlot.goalkeeper): 'gk',
    FantasySpot(FantasySlot.defender): 'lb',
    FantasySpot(FantasySlot.midfielder): 'mf',
    FantasySpot(FantasySlot.forward): 'fw',
    FantasySpot(FantasySlot.flex): 'dm',
  },
  captainId: 'fw',
);

void main() {
  test('posições: lateral → ZAG, volante → MEI; sem posição fica de fora', () {
    expect(fantasySlotOf('goleiro'), FantasySlot.goalkeeper);
    expect(fantasySlotOf('zagueiro'), FantasySlot.defender);
    expect(fantasySlotOf('lateral'), FantasySlot.defender);
    expect(fantasySlotOf('volante'), FantasySlot.midfielder);
    expect(fantasySlotOf('Meia'), FantasySlot.midfielder);
    expect(fantasySlotOf('atacante'), FantasySlot.forward);
    expect(fantasySlotOf(''), isNull);
    expect(FantasySlot.flex.accepts('goleiro'), isTrue);
  });

  test('escalação: vagas, troca de vaga, capitão e validação', () {
    String position(String id) => _athletes.firstWhere((a) => a.id == id).position;
    var lineup = const FantasyLineup().place(const FantasySpot(FantasySlot.goalkeeper), 'gk');
    expect(lineup.validate(position), FantasyLineupError.incomplete);
    lineup = _full.withCaptain('mf');
    expect(lineup.validate(position), isNull);
    // O mesmo atleta em outra vaga sai da anterior (não repete).
    final moved = lineup.place(const FantasySpot(FantasySlot.flex), 'mf');
    expect(moved.idAt(const FantasySpot(FantasySlot.midfielder)), isNull);
    expect(moved.captainId, 'mf');
    // Tirar o capitão tira a braçadeira.
    expect(lineup.remove(const FantasySpot(FantasySlot.midfielder)).captainId, '');
    expect(_full.withCaptain('zz').captainId, 'fw');
    expect(
        FantasyLineup(athletes: const {})
            .place(const FantasySpot(FantasySlot.goalkeeper), 'fw')
            .place(const FantasySpot(FantasySlot.defender), 'lb')
            .ids
            .length,
        5);
    final wrong =
        _full.place(const FantasySpot(FantasySlot.goalkeeper), 'dm').place(const FantasySpot(FantasySlot.flex), 'gk');
    expect(wrong.validate(position), FantasyLineupError.position);
    expect(_full.withCaptain('').copyWithNoCaptain().validate(position), FantasyLineupError.noCaptain);
  });

  test('DTOs: escalação vai e volta; salvar tira a marca de cópia; atleta pela inscrição', () {
    final dto = FantasyLineupDTO.fromMap('u1', {
      'nome': 'Ana',
      'atletas': {'gol': 'gk', 'zag': 'lb', 'mei': 'mf', 'ata': 'fw', 'livre': 'dm'},
      'capitao': 'fw',
      'copiada': true,
    });
    expect(dto.lineup, _full);
    expect(dto.copied, isTrue);
    final map = dto.toOwnerMap();
    expect(map['idsAtletas'], ['gk', 'lb', 'mf', 'fw', 'dm']);
    expect(map['copiada'], isFalse);
    expect(map.containsKey('pontos'), isFalse);

    const player = PlayerDTO(
      id: 'p1',
      name: 'Rafa',
      team: 'Leões',
      position: 'lateral',
      enrollments: [PlayerEnrollment(championshipId: 8, teamId: 't1', team: 'Leões', goals: 2, assists: 1)],
    );
    final athlete = FantasyAthleteDTO.of(player, 8)!;
    expect((athlete.teamId, athlete.goals, athlete.slot), ('t1', 2, FantasySlot.defender));
    expect(FantasyAthleteDTO.of(player, 9), isNull);
    expect(
        FantasyAthleteDTO.of(
            const PlayerDTO(name: 'X', team: '', enrollments: [
              PlayerEnrollment(championshipId: 8, teamId: 't1', team: 'L'),
            ]),
            8),
        isNull);
    expect(FantasyAthleteDTO.fromCache(athlete.toCache()), athlete);
  });

  test('filtro da folha: vaga, posição na livre, time e busca sem acento', () {
    expect(filterFantasyAthletes(_athletes, slot: FantasySlot.defender).map((a) => a.id), ['lb']);
    expect(filterFantasyAthletes(_athletes, slot: FantasySlot.flex).length, 5);
    expect(filterFantasyAthletes(_athletes, slot: FantasySlot.flex, position: 'volante').map((a) => a.id), ['dm']);
    expect(filterFantasyAthletes(_athletes, slot: FantasySlot.flex, teamId: 't2').map((a) => a.id), ['mf', 'fw']);
    expect(filterFantasyAthletes(_athletes, slot: FantasySlot.flex, query: 'angelo').map((a) => a.id), ['fw']);
  });

  group('cubit', () {
    test('entra na rodada atual, escala, escolhe o capitão e confirma', () async {
      final repo = _Repo();
      final cubit = _cubit(repo);
      addTearDown(cubit.close);
      cubit.load(_copa, uid: 'u1', name: 'Ana');
      repo.config.add(Right(_config));
      await _tick();
      repo.participant.add(const Right(null));
      repo.round.add(Right(_openRound));
      repo.lineup.add(const Right(null));
      await _tick();
      expect(cubit.state.joined, isFalse);
      await cubit.join();
      expect(repo.joined, ['u1@2']);
      repo.participant.add(const Right(FantasyParticipantDTO(uid: 'u1', name: 'Ana', firstRound: 2)));
      await _tick();
      expect(cubit.state.editable, isTrue);
      for (final entry in _full.athletes.entries) {
        cubit.place(entry.key, entry.value);
      }
      expect(cubit.state.error, FantasyLineupError.noCaptain);
      cubit.setCaptain('fw');
      expect(cubit.state.canSave, isTrue);
      await cubit.save();
      expect(repo.saved.single.$1, 2);
      expect(repo.saved.single.$2.lineup, _full);
      expect(cubit.state.event, FantasyLineupEvent.saved);
    });

    test('prazo vencido: só leitura; cópia da rodada anterior pode ser confirmada/alterada', () async {
      final repo = _Repo();
      final cubit = _cubit(repo);
      addTearDown(cubit.close);
      cubit.load(_copa, uid: 'u1');
      repo.config.add(Right(_config));
      await _tick();
      repo.participant.add(const Right(FantasyParticipantDTO(uid: 'u1')));
      repo.round.add(Right(_openRound));
      repo.lineup.add(Right(FantasyLineupDTO(uid: 'u1', lineup: _full, copied: true)));
      await _tick();
      expect(cubit.state.dirty, isFalse);
      expect(cubit.state.canSave, isTrue);
      cubit.setCaptain('gk');
      expect(cubit.state.draft.captainId, 'gk');

      repo.round.add(Right(FantasyRoundDTO(number: 2, status: 'aberta', closesAt: DateTime(2026, 11, 18, 11))));
      await _tick();
      expect(cubit.state.editable, isFalse);
      cubit.place(const FantasySpot(FantasySlot.flex), 'mf');
      expect(cubit.state.draft.idAt(const FantasySpot(FantasySlot.flex)), 'dm');
      await cubit.save();
      expect(repo.saved, isEmpty);
    });

    test('admin muda o formato com a rodada aberta: a escalação gravada fica; o rascunho vai ao formato novo',
        () async {
      final repo = _Repo();
      final cubit = _cubit(repo);
      addTearDown(cubit.close);
      cubit.load(_copa, uid: 'u1');
      repo.config.add(Right(_config));
      await _tick();
      repo.participant.add(const Right(FantasyParticipantDTO(uid: 'u1')));
      repo.round.add(Right(_openRound));
      repo.lineup.add(Right(FantasyLineupDTO(uid: 'u1', lineup: _full)));
      await _tick();
      expect(cubit.state.formationChanged, isFalse);
      expect(cubit.state.draft, _full);

      const f1222 = FantasyFormation({
        FantasySlot.goalkeeper: 1,
        FantasySlot.defender: 2,
        FantasySlot.midfielder: 2,
        FantasySlot.forward: 2,
        FantasySlot.flex: 0,
      });
      repo.config.add(Right(_config.copyWith(formation: f1222)));
      await _tick();
      expect(cubit.state.formationChanged, isTrue);
      expect(cubit.state.saved!.lineup, _full, reason: 'a gravada segue valendo');
      expect(cubit.state.draft.ids, ['gk', 'lb', '', 'mf', '', 'fw', '']);
      expect(cubit.state.error, FantasyLineupError.incomplete);
      expect(cubit.state.canSave, isFalse);
      cubit.discard();
      expect(cubit.state.draft.formation, f1222, reason: 'descartar volta ao rascunho no formato novo');
    });
  });

  testWidgets('convidado (link da arte): aviso com "Entrar" que leva ao login', (tester) async {
    final repo = _Repo();
    final cubit = _cubit(repo);
    addTearDown(cubit.close);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      routes: {AppRoutes.loginPage: (_) => const Scaffold(body: Text('LOGIN'))},
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>.value(value: _Session.guest()),
          BlocProvider<FantasyLineupCubit>.value(value: cubit),
        ],
        child: const FantasyLineupPage(championship: _copa),
      ),
    ));
    repo.config.add(Right(_config));
    await tester.pump();
    repo.round.add(Right(_openRound));
    await tester.pump();
    expect(find.byKey(const ValueKey('fantasy-guest-login')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('fantasy-guest-login')));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('tela: campinho, folha da vaga e confirmar', (tester) async {
    tester.view.physicalSize = const Size(420, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _Repo();
    final cubit = _cubit(repo);
    addTearDown(cubit.close);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>.value(value: _Session()),
          BlocProvider<FantasyLineupCubit>.value(value: cubit),
        ],
        child: const FantasyLineupPage(championship: _copa),
      ),
    ));
    repo.config.add(Right(_config));
    await tester.pump();
    repo.participant.add(const Right(FantasyParticipantDTO(uid: 'u1', name: 'Ana')));
    repo.round.add(Right(_openRound));
    repo.lineup.add(Right(FantasyLineupDTO(
      uid: 'u1',
      lineup: _full.remove(const FantasySpot(FantasySlot.goalkeeper)),
    )));
    await tester.pump();
    await tester.pump();
    expect(find.text('Rodada 2'), findsOneWidget);
    expect(find.textContaining('Fecha em'), findsOneWidget);
    expect(find.text('Preencha as 5 vagas.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('fantasy-slot-gol')));
    await tester.pumpAndSettle();
    expect(find.text('Escolha o goleiro'), findsOneWidget);
    expect(find.byKey(const ValueKey('fantasy-athlete-lb')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('fantasy-athlete-gk')));
    await tester.pumpAndSettle();
    expect(find.text('GOLEIRO'), findsOneWidget);

    await tester.tap(find.text('Confirmar escalação'));
    await tester.pump();
    expect(repo.saved.single.$2.lineup.idAt(const FantasySpot(FantasySlot.goalkeeper)), 'gk');
    expect(repo.saved.single.$2.lineup.captainId, 'fw');
  });

  testWidgets('campinho: vagas em figurinha nas cores do time, vazia tracejada, braçadeira escolhe o capitão',
      (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    String? captain;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(
        body: SingleChildScrollView(
          child: FantasyPitch(
            lineup: _full.remove(const FantasySpot(FantasySlot.goalkeeper)),
            athletes: {for (final a in _athletes) a.id: a},
            teams: const {'t1': TeamDTO(id: 't1', name: 'Leões', region: '', primaryColor: '#C62828')},
            editable: true,
            onSlotTap: (_) {},
            onCaptainTap: (id) => captain = id,
          ),
        ),
      ),
    ));
    expect(find.byType(StickerCard), findsNWidgets(4));
    expect(find.byType(EmptySlot), findsOneWidget);
    expect(find.text('ZAG'), findsOneWidget);
    expect(find.text('GOL'), findsOneWidget);
    expect(find.text('LATERAL'), findsOneWidget);
    final zag = tester.widget<StickerCard>(
        find.descendant(of: find.byKey(const ValueKey('fantasy-slot-zag')), matching: find.byType(StickerCard)));
    expect(zag.style.accent, const Color(0xFFC62828));
    await tester.tap(find.byKey(const ValueKey('fantasy-captain-mei')));
    expect(captain, 'mf');
  });

  test('craques da rodada: a última rodada fechada e o top dela', () async {
    final repo = _Repo();
    final cubit = FantasyLineupCubit(
      WatchFantasyConfigUseCase(repo),
      WatchFantasyRoundUseCase(repo),
      WatchFantasyParticipantUseCase(repo),
      WatchFantasyLineupUseCase(repo),
      JoinFantasyUseCase(repo),
      SaveFantasyLineupUseCase(repo),
      GetFantasyAthletesCacheFirstUseCase(repo),
      clock: () => _now,
      tick: null,
      rounds: GetFantasyRoundsUseCase(repo),
      topAthletes: GetFantasyTopAthletesCacheFirstUseCase(repo),
    );
    addTearDown(cubit.close);
    cubit.load(_copa, uid: '');
    repo.config.add(Right(_config));
    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(cubit.state.topRound, 3);
    expect(cubit.state.topAthletes.map((a) => a.athleteId), ['gk', 'cb', 'dm']);
  });

  testWidgets('card dos craques: até 5, posição com empate, toque e "Ver todos"', (tester) async {
    final athletes = [
      for (var i = 0; i < 7; i++)
        FantasyAthleteScoreDTO.fromMap('a$i', {'nome': 'Atleta $i', 'total': i < 2 ? 20 : 20 - i, 'posicao': 'ata'}),
    ];
    String? tapped;
    var seeAll = false;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(
        body: SingleChildScrollView(
          child: FantasyTopAthletesCard(
            round: 3,
            athletes: athletes,
            onAthleteTap: (a) => tapped = a.athleteId,
            onSeeAll: () => seeAll = true,
          ),
        ),
      ),
    ));
    expect(find.text('Craques da rodada 3'), findsOneWidget);
    expect(find.byType(FantasyTopAthleteRow), findsNWidgets(5));
    expect(find.text('1º'), findsNWidgets(2));
    expect(find.text('Atleta 5'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('fantasy-top-a2')));
    expect(tapped, 'a2');
    await tester.tap(find.byKey(const ValueKey('fantasy-top-see-all')));
    expect(seeAll, isTrue);
  });

  test('formação: a LIVRE joga na linha da posição do atleta (vazia = meio)', () {
    expect(fantasyFlexLine('atacante'), FantasySlot.forward);
    expect(fantasyFlexLine('lateral'), FantasySlot.defender);
    expect(fantasyFlexLine('volante'), FantasySlot.midfielder);
    expect(fantasyFlexLine('goleiro'), FantasySlot.goalkeeper);
    expect(fantasyFlexLine(null), FantasySlot.midfielder);
    // Padrão (uma de cada): a LIVRE ao lado da fixa da linha dela, as outras no centro.
    final f = FantasyPitch.formation(FantasyPitch.rows(FantasyFormation.defaults.spots, (_) => FantasySlot.forward));
    expect(f[const FantasySpot(FantasySlot.flex)], const Alignment(0.5, -0.9));
    expect(f[const FantasySpot(FantasySlot.forward)], const Alignment(-0.5, -0.9));
    expect(f[const FantasySpot(FantasySlot.midfielder)]!.x, 0);
  });

  group('formato da escalação', () {
    const f1222 = FantasyFormation({
      FantasySlot.goalkeeper: 1,
      FantasySlot.defender: 2,
      FantasySlot.midfielder: 2,
      FantasySlot.forward: 2,
      FantasySlot.flex: 0,
    });

    test('faixas, total de 3 a 7, chaves numeradas e leitura do doc', () {
      expect(FantasyFormation.defaults.total, 5);
      expect(f1222.total, 7);
      expect(f1222.isValid, isTrue);
      expect(f1222.withCount(FantasySlot.flex, 1).isValid, isFalse, reason: '8 atletas');
      expect(f1222.withCount(FantasySlot.goalkeeper, 3).countOf(FantasySlot.goalkeeper), 1, reason: 'GOL vai até 1');
      expect(f1222.spots.map((s) => s.key), ['gol', 'zag', 'zag2', 'mei', 'mei2', 'ata', 'ata2']);
      expect(FantasyFormation.fromMap(f1222.toMap()), f1222);
      expect(FantasyFormation.fromMap({'gol': 1, 'zag': 4, 'mei': 4, 'ata': 0, 'livre': 0}), FantasyFormation.defaults);
      expect(FantasyFormation.fromMap(null), FantasyFormation.defaults);
      expect(FantasySpot.parse('zag2'), const FantasySpot(FantasySlot.defender, 1));
      expect(FantasySpot.parse('livre'), const FantasySpot(FantasySlot.flex));
      expect(FantasySpot.parse('gol2'), isNull);
      expect(FantasySpot.parse('xyz'), isNull);
    });

    test('mudar o formato: a escalação antiga fica igual; o rascunho mantém as vagas que existem', () {
      expect(_full.fitsFormation(FantasyFormation.defaults), isTrue);
      expect(_full.fitsFormation(f1222), isFalse);
      final adapted = _full.adaptTo(f1222);
      expect(adapted.ids, ['gk', 'lb', '', 'mf', '', 'fw', '']);
      expect(adapted.captainId, 'fw');
      expect(adapted.validate((_) => 'atacante'), FantasyLineupError.incomplete);
      expect(_full.withCaptain('dm').adaptTo(f1222).captainId, '', reason: 'a LIVRE saiu do formato');
      expect(_full.ids, ['gk', 'lb', 'mf', 'fw', 'dm'], reason: 'nada muda na escalação gravada');
    });

    test('DTO: chaves numeradas e o formato pelas chaves gravadas (rodada antiga segue com 5)', () {
      final dto = FantasyLineupDTO.fromMap('u1', {
        'atletas': {'gol': 'gk', 'zag': 'lb', 'zag2': 'cb', 'mei': 'mf', 'mei2': '', 'ata': 'fw', 'ata2': 'fw2'},
        'capitao': 'cb',
      });
      expect(dto.lineup.formation, f1222);
      expect(dto.lineup.idAt(const FantasySpot(FantasySlot.defender, 1)), 'cb');
      expect(dto.lineup.filledSpots.length, 6);
      expect(dto.toOwnerMap()['atletas'],
          {'gol': 'gk', 'zag': 'lb', 'zag2': 'cb', 'mei': 'mf', 'mei2': '', 'ata': 'fw', 'ata2': 'fw2'});
      final old = FantasyLineupDTO.fromMap('u1', {
        'atletas': {'gol': 'gk', 'zag': 'lb', 'mei': 'mf', 'ata': 'fw', 'livre': 'dm'},
        'capitao': 'fw',
      });
      expect(old.lineup.formation, FantasyFormation.defaults);
      expect(old.toOwnerMap()['idsAtletas'], ['gk', 'lb', 'mf', 'fw', 'dm']);
    });

    test('campinho 1-2-2-2: as vagas da linha espalhadas por igual, figurinha menor com 4 na linha', () {
      final rows = FantasyPitch.rows(f1222.spots, (_) => FantasySlot.midfielder);
      final f = FantasyPitch.formation(rows);
      expect(f[const FantasySpot(FantasySlot.defender)], const Alignment(-0.5, 0.4));
      expect(f[const FantasySpot(FantasySlot.defender, 1)], const Alignment(0.5, 0.4));
      expect(f[const FantasySpot(FantasySlot.goalkeeper)], const Alignment(0, 0.95));
      expect(FantasyPitch.cardFraction(2), 0.22);
      expect(FantasyPitch.cardFraction(5), lessThan(0.22));
    });
  });

  testWidgets('campinho: LIVRE com atacante sobe para o ataque; com volante, volta ao meio', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Widget pitch(String flexId) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: FantasyPitch(
                lineup: _full.place(const FantasySpot(FantasySlot.flex), flexId),
                athletes: {
                  for (final a in _athletes) a.id: a,
                  'fw2': const FantasyAthleteDTO(id: 'fw2', name: 'Beto Ponta', position: 'atacante', teamId: 't2'),
                },
                editable: true,
                onSlotTap: (_) {},
                onCaptainTap: (_) {},
              ),
            ),
          ),
        );
    Alignment at(String key) =>
        tester.widget<AnimatedAlign>(find.byKey(ValueKey('fantasy-pos-$key'))).alignment as Alignment;
    await tester.pumpWidget(pitch('fw2'));
    await tester.pumpAndSettle();
    expect(at('livre'), const Alignment(0.5, -0.9));
    expect(at('ata'), const Alignment(-0.5, -0.9));
    expect(at('mei'), const Alignment(0, -0.25));
    await tester.pumpWidget(pitch('dm'));
    await tester.pumpAndSettle();
    expect(at('livre'), const Alignment(0.5, -0.25));
    expect(at('mei'), const Alignment(-0.5, -0.25));
    expect(at('ata'), const Alignment(0, -0.9));
  });

  test('fichas de posição: só as do cadastro aceitas pela vaga e com atleta', () {
    String keys(FantasySlot slot) => fantasyPickerPositions(_athletes, slot).map((p) => p.key).join(',');
    expect(keys(FantasySlot.defender), 'lateral');
    expect(keys(FantasySlot.midfielder), 'volante,meia');
    expect(keys(FantasySlot.flex), 'goleiro,lateral,volante,meia,atacante');
    expect(keys(FantasySlot.forward), 'atacante');
    expect(filterFantasyAthletes(_athletes, slot: FantasySlot.midfielder, position: 'meia').map((a) => a.id), ['mf']);
  });

  testWidgets('folha: filtro por posição na ZAG (zagueiro · lateral); a ATA não tem fichas', (tester) async {
    const athletes = [
      ..._athletes,
      FantasyAthleteDTO(id: 'cb', name: 'Caio Zagueiro', position: 'zagueiro', teamId: 't2', team: 'Tigres'),
    ];
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(body: Builder(builder: (context) {
        ctx = context;
        return const SizedBox.shrink();
      })),
    ));
    showFantasyAthletePicker(ctx, slot: FantasySlot.defender, athletes: athletes, lineup: const FantasyLineup());
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('fantasy-filter-all')), findsOneWidget);
    expect(find.byKey(const ValueKey('fantasy-athlete-cb')), findsOneWidget);
    expect(find.byKey(const ValueKey('fantasy-athlete-lb')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('fantasy-filter-lateral')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('fantasy-athlete-cb')), findsNothing);
    expect(find.byKey(const ValueKey('fantasy-athlete-lb')), findsOneWidget);
    Navigator.pop(ctx);
    await tester.pumpAndSettle();

    showFantasyAthletePicker(ctx, slot: FantasySlot.forward, athletes: athletes, lineup: const FantasyLineup());
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('fantasy-filter-all')), findsNothing);
    expect(find.byKey(const ValueKey('fantasy-athlete-fw')), findsOneWidget);
  });

  test('rodada em andamento: começou, tem partidas e não foi finalizada', () {
    final started =
        FantasyRoundDTO(number: 1, status: 'aberta', closesAt: DateTime(2026, 11, 18, 11), matchIds: const ['m1']);
    expect(started.inProgressAt(_now), isTrue);
    expect(started.isOpenAt(_now), isFalse);
    expect(
        FantasyRoundDTO(number: 1, status: 'fechada', closesAt: DateTime(2026, 11, 18, 11), matchIds: const ['m1'])
            .inProgressAt(_now),
        isTrue);
    expect(
        FantasyRoundDTO(
                number: 1,
                status: 'fechada',
                closesAt: DateTime(2026, 11, 18, 11),
                matchIds: const ['m1'],
                finished: true)
            .inProgressAt(_now),
        isFalse);
    expect(_openRound.inProgressAt(_now), isFalse);
  });

  testWidgets('tela: rodada em andamento trava o campinho e avisa que a próxima abre depois', (tester) async {
    tester.view.physicalSize = const Size(420, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _Repo();
    final cubit = _cubit(repo);
    addTearDown(cubit.close);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>.value(value: _Session()),
          BlocProvider<FantasyLineupCubit>.value(value: cubit),
        ],
        child: const FantasyLineupPage(championship: _copa),
      ),
    ));
    repo.config.add(Right(_config));
    await tester.pump();
    repo.participant.add(const Right(FantasyParticipantDTO(uid: 'u1', name: 'Ana')));
    repo.round.add(Right(
        FantasyRoundDTO(number: 2, status: 'aberta', closesAt: DateTime(2026, 11, 18, 11), matchIds: const ['m1'])));
    repo.lineup.add(Right(FantasyLineupDTO(uid: 'u1', lineup: _full)));
    await tester.pump();
    await tester.pump();
    expect(find.text('Rodada 2 em andamento. A próxima rodada abre quando todos os jogos terminarem.'), findsOneWidget);
    expect(find.text('Em andamento'), findsOneWidget);
    expect(cubit.state.editable, isFalse);
    expect(find.text('Confirmar escalação'), findsNothing);
  });

  test('quem já jogou: pontos só deles', () {
    final dto = FantasyLineupDTO.fromMap('u1', {
      'atletas': {'gol': 'gk', 'zag': 'lb', 'mei': 'mf', 'ata': 'fw', 'livre': 'dm'},
      'capitao': 'fw',
      'pontos': 12,
      'pontosAtletas': {'gk': -3, 'lb': 0, 'mf': 0, 'fw': 15, 'dm': 0},
      'atletasJogaram': ['fw', 'gk', 'lb'],
    });
    expect(dto.playedIds, ['fw', 'gk', 'lb']);
    expect(dto.playedPoints, {'fw': 15.0, 'gk': -3.0, 'lb': 0.0});
  });

  testWidgets('tela: rodada em andamento mostra o parcial e os pontos de quem já jogou', (tester) async {
    tester.view.physicalSize = const Size(420, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _Repo();
    final cubit = _cubit(repo);
    addTearDown(cubit.close);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>.value(value: _Session()),
          BlocProvider<FantasyLineupCubit>.value(value: cubit),
        ],
        child: const FantasyLineupPage(championship: _copa),
      ),
    ));
    repo.config.add(Right(_config));
    await tester.pump();
    repo.participant.add(const Right(FantasyParticipantDTO(uid: 'u1', name: 'Ana', points: 23.5)));
    repo.round.add(Right(FantasyRoundDTO(
      number: 2,
      status: 'fechada',
      closesAt: DateTime(2026, 11, 18, 11),
      matchIds: const ['m1', 'm2'],
      matchesFinished: 1,
    )));
    repo.lineup.add(Right(FantasyLineupDTO(
      uid: 'u1',
      lineup: _full,
      points: 23.5,
      athletePoints: {'fw': 15, 'gk': -3, 'mf': 0, 'lb': 0, 'dm': 0},
      playedIds: ['fw', 'gk'],
    )));
    await tester.pump();
    await tester.pump();
    expect(find.byKey(const ValueKey('fantasy-round-score')), findsOneWidget);
    expect(find.text('Sua pontuação na rodada 2'), findsOneWidget);
    expect(find.text('Parcial · 1 de 2 jogos'), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('fantasy-round-score')), matching: find.text('23,5')),
        findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('fantasy-points-ata')), matching: find.text('+15')),
        findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('fantasy-points-gol')), matching: find.text('-3')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('fantasy-points-mei')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rodada encerrada: abre no resultado (pontos e figurinhas) e o seletor volta para escalar',
      (tester) async {
    tester.view.physicalSize = const Size(420, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _PastRepo(_now.subtract(const Duration(hours: 1)));
    final cubit = FantasyLineupCubit(
      WatchFantasyConfigUseCase(repo),
      WatchFantasyRoundUseCase(repo),
      WatchFantasyParticipantUseCase(repo),
      WatchFantasyLineupUseCase(repo),
      JoinFantasyUseCase(repo),
      SaveFantasyLineupUseCase(repo),
      GetFantasyAthletesCacheFirstUseCase(repo),
      clock: () => _now,
      tick: null,
      rounds: GetFantasyRoundsUseCase(repo),
    );
    addTearDown(cubit.close);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>.value(value: _Session()),
          BlocProvider<FantasyLineupCubit>.value(value: cubit),
        ],
        child: const FantasyLineupPage(championship: _copa),
      ),
    ));
    repo.config.add(Right(_config));
    await tester.pump();
    repo.participant.add(const Right(FantasyParticipantDTO(uid: 'u1', name: 'Ana', points: 20)));
    repo.round.add(Right(_openRound));
    repo.lineup.add(Right(FantasyLineupDTO(uid: 'u1', lineup: _full, copied: true)));
    for (var i = 0; i < 5; i++) {
      await tester.pump();
    }
    // Abre no resultado da rodada 1 (encerrada há 1 h).
    expect(cubit.state.showingLast, isTrue);
    expect(find.text('Rodada 1 · Resultado · 20 pts'), findsOneWidget);
    expect(find.text('Rodada 2 · Escalar'), findsOneWidget);
    expect(find.text('Sua pontuação na rodada 1'), findsOneWidget);
    expect(find.text('Final'), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('fantasy-points-ata')), matching: find.text('+22,5')),
        findsOneWidget);
    expect(find.text('Confirmar escalação'), findsNothing);
    // Seletor: volta para a rodada 2 (escalar).
    await tester.tap(find.byKey(const ValueKey('fantasy-switch-current')));
    await tester.pump();
    expect(cubit.state.showingLast, isFalse);
    expect(find.byKey(const ValueKey('fantasy-last-pitch')), findsNothing);
    expect(find.text('Confirmar escalação'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('regras: o livro da AppBar e o "Ver regras" do convite abrem a tela com a config', (tester) async {
    tester.view.physicalSize = const Size(420, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _Repo();
    final cubit = _cubit(repo);
    addTearDown(cubit.close);
    final opened = <Object?>[];
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      routes: {
        AppRoutes.fantasyRulesPage: (context) {
          final config = ModalRoute.of(context)!.settings.arguments as FantasyConfigDTO?;
          opened.add(config);
          return FantasyRulesPage(config: config);
        },
      },
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>.value(value: _Session()),
          BlocProvider<FantasyLineupCubit>.value(value: cubit),
        ],
        child: const FantasyLineupPage(championship: _copa),
      ),
    ));
    final config = FantasyConfigDTO.fromMap('doc1', {'ativo': true, 'rodadaAtual': 2, 'minMinutos': 30, 'capitao': 2.0},
        championship: _copa);
    repo.config.add(Right(config));
    await tester.pump();
    repo.participant.add(const Right(null));
    repo.round.add(Right(_openRound));
    repo.lineup.add(const Right(null));
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('fantasy-open-rules')));
    await tester.pumpAndSettle();
    expect(find.byType(FantasyRulesPage), findsOneWidget);
    expect(find.text('Regras e pontuação'), findsOneWidget);
    final sent = opened.single as FantasyConfigDTO;
    expect(sent.championshipDocId, 'doc1');
    expect(sent.minMinutes, 30);
    expect(sent.captainMultiplier, 2.0);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('fantasy-join-rules')));
    await tester.pumpAndSettle();
    expect(find.byType(FantasyRulesPage), findsOneWidget);
    expect(opened, hasLength(2));
  });
}

extension on FantasyLineup {
  FantasyLineup copyWithNoCaptain() => FantasyLineup(athletes: athletes);
}
