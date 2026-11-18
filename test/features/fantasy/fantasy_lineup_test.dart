import 'dart:async';

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

class _Session extends Cubit<SessionState> implements SessionCubit {
  _Session() : super(const SessionState(user: UserDTO(id: 'u1', name: 'Ana', email: 'a@x.com', isAdmin: false)));

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

const _full = FantasyLineup(
  athletes: {
    FantasySlot.goalkeeper: 'gk',
    FantasySlot.defender: 'lb',
    FantasySlot.midfielder: 'mf',
    FantasySlot.forward: 'fw',
    FantasySlot.flex: 'dm',
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
    var lineup = const FantasyLineup().place(FantasySlot.goalkeeper, 'gk');
    expect(lineup.validate(position), FantasyLineupError.incomplete);
    lineup = _full.withCaptain('mf');
    expect(lineup.validate(position), isNull);
    // O mesmo atleta em outra vaga sai da anterior (não repete).
    final moved = lineup.place(FantasySlot.flex, 'mf');
    expect(moved.idAt(FantasySlot.midfielder), isNull);
    expect(moved.captainId, 'mf');
    // Tirar o capitão tira a braçadeira.
    expect(lineup.remove(FantasySlot.midfielder).captainId, '');
    expect(_full.withCaptain('zz').captainId, 'fw');
    expect(
        const FantasyLineup(athletes: {FantasySlot.goalkeeper: 'fw'}).place(FantasySlot.defender, 'lb').ids.length, 5);
    final wrong = _full.place(FantasySlot.goalkeeper, 'dm').place(FantasySlot.flex, 'gk');
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
      repo.lineup.add(const Right(FantasyLineupDTO(uid: 'u1', lineup: _full, copied: true)));
      await _tick();
      expect(cubit.state.dirty, isFalse);
      expect(cubit.state.canSave, isTrue);
      cubit.setCaptain('gk');
      expect(cubit.state.draft.captainId, 'gk');

      repo.round.add(Right(FantasyRoundDTO(number: 2, status: 'aberta', closesAt: DateTime(2026, 11, 18, 11))));
      await _tick();
      expect(cubit.state.editable, isFalse);
      cubit.place(FantasySlot.flex, 'mf');
      expect(cubit.state.draft.idAt(FantasySlot.flex), 'dm');
      await cubit.save();
      expect(repo.saved, isEmpty);
    });
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
      lineup: _full.remove(FantasySlot.goalkeeper),
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
    expect(repo.saved.single.$2.lineup.idAt(FantasySlot.goalkeeper), 'gk');
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
            lineup: _full.remove(FantasySlot.goalkeeper),
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
    final f = FantasyPitch.formation(FantasySlot.forward);
    expect(f[FantasySlot.flex], const Alignment(0.5, -0.9));
    expect(f[FantasySlot.forward], const Alignment(-0.5, -0.9));
    expect(f[FantasySlot.midfielder]!.x, 0);
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
                lineup: _full.place(FantasySlot.flex, flexId),
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
}

extension on FantasyLineup {
  FantasyLineup copyWithNoCaptain() => FantasyLineup(athletes: athletes);
}
