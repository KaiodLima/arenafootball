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
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_score_dto.dart';
import 'package:arena_soccer/features/fantasy/domain/repositories/fantasy_repository_interface.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_config_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_lineup_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_ranking_usecases.dart';
import 'package:arena_soccer/features/fantasy/presentation/bloc/fantasy_ranking_cubit.dart';
import 'package:arena_soccer/features/fantasy/presentation/page/fantasy_ranking_page.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

const _copa = ChampionshipDTO(id: 'doc1', championshipId: 8, title: 'Copa Verde', region: 'Floresta', season: '2026');

FantasyRankingEntry _e(String uid, double points) =>
    FantasyRankingEntry(uid: uid, name: uid.toUpperCase(), points: points);

final _lineupU1 = FantasyLineupDTO.fromMap('u1', {
  'atletas': {'gol': 'gk', 'zag': 'cb', 'mei': 'mf', 'ata': 'fw', 'livre': 'dm'},
  'capitao': 'fw',
  'pontos': 41.5,
  'pontosAtletas': {'gk': 5, 'cb': 7, 'mf': 6, 'fw': 22.5, 'dm': 1},
});

class _Repo implements IFantasyRepository {
  final rounds = [
    FantasyRoundDTO.fromMap('1', {'status': 'fechada', 'apuracao': {}, 'finalizada': true}),
    FantasyRoundDTO.fromMap('2', {'status': 'fechada'}),
    FantasyRoundDTO.fromMap('3', {'status': 'aberta'}),
  ];
  final roundRanking = <int, List<FantasyRankingEntry>>{
    1: [_e('a', 50), _e('b', 50), _e('c', 30), _e('d', 20)],
    2: const [],
  };
  final lineups = <int, FantasyLineupDTO?>{1: _lineupU1, 2: const FantasyLineupDTO(uid: 'u1')};
  final counts = <String>[];

  final top = <int, List<FantasyAthleteScoreDTO>>{
    1: [
      FantasyAthleteScoreDTO.fromMap(
          'fw', {'nome': 'Ângelo Atacante', 'time': 'Tigres', 'total': 22, 'posicao': 'ata'}),
      FantasyAthleteScoreDTO.fromMap('mf', {'nome': 'Mateus Meia', 'total': 15, 'posicao': 'mei'}),
    ],
    2: [
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
  Stream<Either<Failure, FantasyConfigDTO>> watchConfig(ChampionshipDTO championship) => Stream.value(Right(
        FantasyConfigDTO.fromMap(
            'doc1',
            {
              'ativo': true,
              'campeao': [
                {'uid': 'a', 'nome': 'Ana', 'pontos': 120},
              ],
            },
            championship: championship),
      ));

  @override
  Future<Either<Failure, List<FantasyRoundDTO>>> getRounds(String fantasyId) async => Right(rounds);

  @override
  Future<Either<Failure, CachedValue<List<FantasyRankingEntry>>?>> getCachedRanking(
          String fantasyId, int? round) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> saveRankingCache(String fantasyId, int? round, List<FantasyRankingEntry> e) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<FantasyRankingEntry>>> getRoundRanking(String fantasyId, int round) async =>
      Right(roundRanking[round] ?? const []);

  @override
  Future<Either<Failure, List<FantasyRankingEntry>>> getOverallRanking(String fantasyId) async =>
      Right([_e('a', 120), _e('b', 90), _e('c', 80), _e('d', 60)]);

  @override
  Future<Either<Failure, int>> countAbove(String fantasyId, double points, {int? round}) async {
    counts.add('$round:$points');
    return const Right(7);
  }

  @override
  Future<Either<Failure, FantasyLineupDTO?>> getLineup(String fantasyId, int round, String uid) async =>
      Right(lineups[round]);

  @override
  Stream<Either<Failure, FantasyParticipantDTO?>> watchParticipant(String fantasyId, String uid) =>
      Stream.value(const Right(FantasyParticipantDTO(uid: 'u1', points: 41.5)));

  @override
  Future<Either<Failure, CachedValue<List<FantasyAthleteDTO>>?>> getCachedAthletes(FantasyConfigDTO config) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<FantasyAthleteDTO>>> getEligibleAthletes(FantasyConfigDTO config) async => const Right([
        FantasyAthleteDTO(id: 'fw', name: 'Ângelo Atacante', position: 'atacante', teamId: 't1'),
        FantasyAthleteDTO(id: 'gk', name: 'Rafael Goleiro', position: 'goleiro', teamId: 't1'),
      ]);

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

FantasyRankingCubit _cubit(_Repo repo) => FantasyRankingCubit(
      WatchFantasyConfigUseCase(repo),
      GetFantasyRankingCacheFirstUseCase(repo),
      GetFantasyPositionUseCase(repo),
      GetFantasyRoundsUseCase(repo),
      GetFantasyLineupUseCase(repo),
      WatchFantasyParticipantUseCase(repo),
      GetFantasyAthletesCacheFirstUseCase(repo),
      topAthletes: GetFantasyTopAthletesCacheFirstUseCase(repo),
    );

Future<void> _settle() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test('posições com empate, ordem pelo nome e pontos com 1 casa só quando houver', () {
    final sorted = sortFantasyRanking([_e('b', 50), _e('c', 30), _e('a', 50), _e('d', 30), _e('e', 10)]);
    expect(sorted.map((e) => e.uid), ['a', 'b', 'c', 'd', 'e']);
    expect(fantasyPositions(sorted), [1, 1, 3, 3, 5]);
    expect(fantasyPointsLabel(12), '12');
    expect(fantasyPointsLabel(7.5), '7,5');
    expect(fantasyPointsLabel(-9), '-9');
  });

  test('DTOs: pontos da escalação, rodada apurada e campeões', () {
    expect(_lineupU1.points, 41.5);
    expect(_lineupU1.athletePoints['fw'], 22.5);
    expect(const FantasyLineupDTO(uid: 'x').points, isNull);
    final round = FantasyRoundDTO.fromMap('1', {'status': 'fechada', 'apuracao': {}, 'finalizada': true});
    expect((round.closed, round.scored, round.finished), (true, true, true));
    final config = FantasyConfigDTO.fromMap('d', {
      'campeao': [
        {'uid': 'a', 'nome': 'Ana', 'pontos': 90},
        {'uid': 'b', 'nome': 'Bia', 'pontos': 90},
      ],
    });
    expect(config.champions.map((c) => c.name), ['Ana', 'Bia']);
  });

  test('cubit: rodadas fechadas (mais recente primeiro), setas, posição fora do top e histórico', () async {
    final repo = _Repo();
    final cubit = _cubit(repo);
    addTearDown(cubit.close);
    await cubit.load(_copa, uid: 'u1');
    await _settle();
    expect(cubit.state.rounds.map((r) => r.number), [2, 1]);
    expect(cubit.state.selectedRound, 2);
    // Rodada 2 sem apuração: a conta escalou, mas ainda sem pontos.
    expect(cubit.state.myRound.points, isNull);
    cubit.olderRound();
    await _settle();
    expect(cubit.state.selectedRound, 1);
    expect(cubit.state.roundEntries.length, 4);
    // Fora do top: os que têm mais + 1.
    expect(cubit.state.myRound, const FantasyMyPosition(points: 41.5, position: 8));
    expect(cubit.state.myOverall, const FantasyMyPosition(points: 41.5, position: 8));
    expect(cubit.state.hasNewer, isTrue);
    expect(cubit.state.hasOlder, isFalse);

    await cubit.loadHistory();
    expect(cubit.state.history.map((h) => (h.round.number, h.position)), [(2, null), (1, 8)]);
  });

  testWidgets('tela: pódio da rodada, sua posição, campeão no geral e o histórico com o capitão', (tester) async {
    tester.view.physicalSize = const Size(420, 1000);
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
          BlocProvider<FantasyRankingCubit>.value(value: cubit),
        ],
        child: const FantasyRankingPage(championship: _copa),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('RODADA 2'), findsOneWidget);
    expect(find.text('Você não escalou nesta rodada.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('fantasy-round-older')));
    await tester.pumpAndSettle();
    expect(find.text('RODADA 1'), findsOneWidget);
    expect(find.text('1º'), findsNWidgets(2));
    // 8º no cartão "Sua posição" (e no cabeçalho da rodada).
    expect(
      find.descendant(of: find.byKey(const ValueKey('fantasy-my-position')), matching: find.text('8º')),
      findsOneWidget,
    );

    await tester.tap(find.text('Geral'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('fantasy-champion-banner')), findsOneWidget);
    expect(find.text('CAMPEÃO DO ARENA FANTASY'), findsOneWidget);

    await tester.tap(find.text('Histórico'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('fantasy-history-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('fantasy-history-captain-fw')), findsOneWidget);
    expect(find.text('Ângelo Atacante'), findsOneWidget);
    expect(find.text('22,5'), findsOneWidget);
    expect(find.text('Aguardando apuração'), findsOneWidget);
  });

  testWidgets('aba Atletas: craques da rodada escolhida, empate na mesma posição, troca de rodada', (tester) async {
    tester.view.physicalSize = const Size(420, 1000);
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
          BlocProvider<FantasyRankingCubit>.value(value: cubit),
        ],
        child: const FantasyRankingPage(championship: _copa, initialTab: FantasyRankingTab.athletes),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('RODADA 2'), findsOneWidget);
    expect(find.text('Rafael Goleiro'), findsOneWidget);
    // Selo da vaga + time.
    expect(find.text('GOL'), findsOneWidget);
    expect(find.text('Leões'), findsOneWidget);
    expect(find.text('1º'), findsNWidgets(2));
    expect(find.text('3º'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('fantasy-round-older')));
    await tester.pumpAndSettle();
    expect(find.text('Ângelo Atacante'), findsOneWidget);
    expect(find.text('22'), findsOneWidget);
    expect(find.text('Rafael Goleiro'), findsNothing);
  });
}
