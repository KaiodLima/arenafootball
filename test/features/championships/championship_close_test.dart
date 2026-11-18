import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';
import 'package:arena_soccer/features/championships/data/datasources/championships_datasource.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_podium.dart';
import 'package:arena_soccer/features/championships/domain/usecases/close_championship_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_season_championships_usecase.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championship_details_cubit.dart';
import 'package:arena_soccer/features/championships/presentation/page/championship_details_page.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/matches_cubit.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/widgets/champion_card.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';
import 'package:arena_soccer/injection_container.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

const _lj =
    ChampionshipPodiumTeam(teamId: 't1', name: 'Lava Jato', imageUrl: 'https://img/lj.png', primaryColor: '#1B8E2D');

const _copa = ChampionshipDTO(
  id: 'doc1',
  championshipId: 7,
  title: 'Copa Verde',
  region: 'Floresta',
  season: '2026',
  teams: ['Lava Jato', 'Volta'],
  teamIds: ['t1', 't2'],
);

class _Teams implements GetTeamsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) =>
      Stream.value(const Right([
        TeamDTO(id: 't1', name: 'Lava Jato', region: 'Floresta', primaryColor: '#1B8E2D'),
        TeamDTO(id: 't2', name: 'Volta', region: 'Floresta'),
      ]));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Close implements CloseChampionshipUseCase {
  String? id;
  ChampionshipPodiumTeam? champion;
  ChampionshipPodiumTeam? runnerUp;

  @override
  Future<Either<Failure, void>> call(String id,
      {required ChampionshipPodiumTeam champion, ChampionshipPodiumTeam? runnerUp}) async {
    this.id = id;
    this.champion = champion;
    this.runnerUp = runnerUp;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Matches implements MatchesCubit {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Session extends Cubit<SessionState> implements SessionCubit {
  _Session({bool admin = false, String uid = 'u1'})
      : super(SessionState(user: UserDTO(id: uid, name: 'Conta', email: 'c@x.com', isAdmin: admin)));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('DTO: encerramento vai e volta do cache; aberta por padrão', () {
    expect(_copa.isOpen, isTrue);
    final closed = _copa.copyWith(
      closed: true,
      closedAt: () => DateTime(2026, 11, 17),
      champion: () => _lj,
      runnerUp: () => const ChampionshipPodiumTeam(teamId: 't2', name: 'Volta'),
    );
    expect(closed.isOpen, isFalse);
    expect(ChampionshipDTO.fromCache(closed.toCache()), closed);
    // O formulário não grava o encerramento (gravação própria).
    expect(closed.toMap().containsKey('encerrado'), isFalse);
    expect(closed.toMap().containsKey('campeao'), isFalse);
  });

  test('closeFields: encerrado, hora do servidor, campeão; sem vice apaga o antigo', () {
    final fields = ChampionshipsDataSource.closeFields(champion: _lj);
    expect(fields['encerrado'], isTrue);
    expect(fields['encerradoEm'], isA<FieldValue>());
    expect((fields['campeao'] as Map)['idTime'], 't1');
    expect(fields['vice'], isA<FieldValue>());
  });

  test('competição encerrada não entra na inscrição do time', () {
    const team = TeamDTO(id: 't1', name: 'Lava Jato', region: 'Floresta');
    final closed = _copa.copyWith(id: 'doc2', championshipId: 8, closed: true);
    expect(GetSeasonChampionshipsUseCase.eligibleFor([_copa, closed], team).map((c) => c.championshipId), [7]);
  });

  group('detalhe da competição', () {
    late _Close close;

    setUp(() {
      close = _Close();
      sl.registerSingleton<CloseChampionshipUseCase>(close);
    });
    tearDown(() => sl.unregister<CloseChampionshipUseCase>());

    Future<void> pump(WidgetTester tester,
        {required SessionCubit session, ChampionshipDTO championship = _copa}) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<SessionCubit>.value(value: session),
            BlocProvider<ChampionshipDetailsCubit>(create: (_) => ChampionshipDetailsCubit(_Teams())),
            BlocProvider<MatchesCubit>.value(value: _Matches()),
          ],
          child: ChampionshipDetailsPage(championship: championship),
        ),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('admin encerra escolhendo o campeão e o vice; aparece o selo e o campeão', (tester) async {
      await pump(tester, session: _Session(admin: true));
      await tester.tap(find.byKey(const ValueKey('championship-manage')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Encerrar competição'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('close-champion-0')));
      await tester.tap(find.byKey(const ValueKey('close-vice-1')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('close-confirm')));
      await tester.pumpAndSettle();

      expect(close.id, 'doc1');
      expect(close.champion?.name, 'Lava Jato');
      expect(close.champion?.primaryColor, '#1B8E2D');
      expect(close.runnerUp?.teamId, 't2');
      expect(find.textContaining('ENCERRADA'), findsOneWidget);
      expect(find.byKey(const ValueKey('champion-banner')), findsOneWidget);
    });

    testWidgets('organizador da competição gerencia; usuário comum não', (tester) async {
      await pump(tester, session: _Session(uid: 'org1'), championship: _copa.copyWith(organizerId: 'org1'));
      expect(find.byKey(const ValueKey('championship-manage')), findsOneWidget);
      await pump(tester, session: _Session(uid: 'u9'), championship: _copa.copyWith(organizerId: 'org1'));
      expect(find.byKey(const ValueKey('championship-manage')), findsNothing);
    });

    testWidgets('engrenagem: "Arena Fantasy" só para o admin', (tester) async {
      await pump(tester, session: _Session(admin: true));
      await tester.tap(find.byKey(const ValueKey('championship-manage')));
      await tester.pumpAndSettle();
      expect(find.text('Arena Fantasy'), findsOneWidget);
    });

    testWidgets('engrenagem: o organizador não vê o "Arena Fantasy"', (tester) async {
      await pump(tester, session: _Session(uid: 'org1'), championship: _copa.copyWith(organizerId: 'org1'));
      await tester.tap(find.byKey(const ValueKey('championship-manage')));
      await tester.pumpAndSettle();
      expect(find.text('Arena Fantasy'), findsNothing);
    });
  });

  testWidgets('card de campeão: selo, time, competição e vice', (tester) async {
    const news = NewsDTO(
      id: 'campeao_doc1',
      title: '🏆 Lava Jato é campeão',
      isVisible: true,
      tag: NewsDTO.championTag,
      homeTeam: 'Lava Jato',
      homeColor: '#1B8E2D',
      awayTeam: 'Volta',
      championshipTitle: 'Copa Verde',
      championshipDocId: 'doc1',
      season: '2026',
    );
    expect(news.isChampion, isTrue);
    expect(NewsDTO.fromCache(news.toCache()), news);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(body: SingleChildScrollView(child: ChampionCard(news: news, onTap: () {}))),
    ));
    expect(find.text('CAMPEÃO'), findsOneWidget);
    expect(find.text('LAVA JATO'), findsOneWidget);
    expect(find.text('COPA VERDE'), findsOneWidget);
    expect(find.text('Vice: Volta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
