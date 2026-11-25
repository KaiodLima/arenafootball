import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_season_championships_usecase.dart';
import 'package:arena_soccer/features/players/data/datasources/players_datasource.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/players/domain/player_link.dart';
import 'package:arena_soccer/features/players/domain/usecases/link_player_usecase.dart';
import 'package:arena_soccer/features/players/presentation/bloc/link_player_cubit.dart';
import 'package:arena_soccer/features/players/presentation/widgets/link_player_sheet.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

const _noTeam = PlayerDTO(id: 'p1', name: 'Dudu', team: '', userId: 'u1', hasEnrollmentField: true);
const _volta = PlayerDTO(
  id: 'p2',
  name: 'Beto',
  team: 'Volta',
  teamId: '2',
  hasEnrollmentField: true,
  enrollments: [PlayerEnrollment(championshipId: 7, teamId: '2', team: 'Volta', goals: 3, assists: 1)],
);
const _legacy = PlayerDTO(id: 'p3', name: 'Caio', team: 'Volta', teamId: '2');
const _already = PlayerDTO(id: 'p4', name: 'Zeca', team: 'Lava Jato', teamId: '1');

const _copa = ChampionshipDTO(
  id: 'cx',
  championshipId: 7,
  title: 'Copa X',
  teams: ['Lava Jato', 'Volta'],
  teamIds: ['1', '2'],
);
const _liga = ChampionshipDTO(id: 'cy', championshipId: 8, title: 'Liga', teams: ['Lava Jato'], teamIds: ['1']);
const _voltaCup = ChampionshipDTO(id: 'cz', championshipId: 9, title: 'Taça', teams: ['Volta'], teamIds: ['2']);

class _FakeLink implements LinkPlayerUseCase {
  PlayerLinkPlan? plan;
  PlayerDTO? player;
  List<PlayerDTO> list = const [_noTeam, _volta, _already];

  @override
  Future<Either<Failure, List<PlayerDTO>>> candidates({required List<String> teamIds, String? season}) async =>
      Right(list);

  @override
  Future<Either<Failure, void>> link(
    PlayerDTO player,
    PlayerLinkPlan plan, {
    required String teamId,
    required String team,
    String? season,
  }) async {
    this.player = player;
    this.plan = plan;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTeams implements GetTeamsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) =>
      Stream.value(const Right([TeamDTO(id: '1', name: 'Lava Jato'), TeamDTO(id: '2', name: 'Volta')]));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeChampionships implements GetSeasonChampionshipsCacheFirstUseCase {
  @override
  Future<Either<Failure, List<ChampionshipDTO>>> latest(String season, {bool force = false}) async =>
      const Right([_copa, _liga, _voltaCup]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PlayerLinkPlan _plan(PlayerDTO p,
        {Set<int> selected = const {}, Set<int> transfers = const {}, bool makeMain = false}) =>
    PlayerLinkPlan.of(
      p,
      teamId: '1',
      team: 'Lava Jato',
      selected: selected,
      transfers: transfers,
      makeMain: makeMain,
      legacyChampionships: const [7, 9],
    );

void main() {
  group('PlayerLinkPlan', () {
    test('sem time: vira o time principal e entra na competição zerada', () {
      final plan = _plan(_noTeam, selected: {8});
      expect(plan.setMain, isTrue);
      expect(plan.upserts, const [PlayerEnrollment(championshipId: 8, teamId: '1', team: 'Lava Jato')]);
      expect(plan.teamIds, ['1']);
    });

    test('com time: o principal só muda com "Tornar time principal"', () {
      expect(_plan(_volta, selected: {8}).setMain, isFalse);
      expect(_plan(_volta, selected: {8}).teamIds, ['2', '1']);
      expect(_plan(_volta, selected: {8}, makeMain: true).setMain, isTrue);
    });

    test('competição jogada por outro time: só entra com a transferência', () {
      expect(PlayerLinkPlan.slotOf(_volta, 7, teamId: '1', team: 'Lava Jato'), LinkSlot.otherTeam);
      expect(PlayerLinkPlan.slotOf(_volta, 8, teamId: '1', team: 'Lava Jato'), LinkSlot.free);
      expect(_plan(_volta, selected: {7}).upserts, isEmpty);
      final moved = _plan(_volta, selected: {7}, transfers: {7});
      expect(moved.upserts.single.teamId, '1');
      // A inscrição muda de time; o Volta segue no idsTimes por ser o principal.
      expect(moved.teamIds, ['2', '1']);
    });

    test('atleta antigo: as competições implícitas do time antigo ficam reais', () {
      final plan = _plan(_legacy, selected: {8});
      expect(plan.upserts, const [
        PlayerEnrollment(championshipId: 8, teamId: '1', team: 'Lava Jato'),
        PlayerEnrollment(championshipId: 7, teamId: '2', team: 'Volta'),
        PlayerEnrollment(championshipId: 9, teamId: '2', team: 'Volta'),
      ]);
      // Inscrição implícita não bloqueia a competição.
      expect(PlayerLinkPlan.slotOf(_legacy, 7, teamId: '1', team: 'Lava Jato'), LinkSlot.free);
    });

    test('sem competição: só o time (principal + idsTimes)', () {
      final plan = _plan(_volta);
      expect(plan.upserts, isEmpty);
      expect(plan.setMain, isTrue);
      expect(plan.teamIds, ['1', '2']);
    });

    test('já é do time e nada muda: plano vazio', () {
      expect(_plan(_already).isEmpty, isTrue);
    });
  });

  test('linkFields grava inscrição sem mexer nos números, idsTimes e principal', () {
    final fields = PlayersDataSource.linkFields(
      _plan(_noTeam, selected: {8}),
      teamId: '1',
      team: 'Lava Jato',
    );
    expect(fields[FieldPath(const ['inscricoes', 'c8', 'idTime'])], '1');
    expect(fields[FieldPath(const ['inscricoes', 'c8', 'time'])], 'Lava Jato');
    expect(fields[FieldPath(const ['inscricoes', 'c8', 'nGols'])], isA<FieldValue>());
    expect(fields[FieldPath(const ['inscricoes', 'c8', 'nAssistencias'])], isA<FieldValue>());
    expect(fields['time'], 'Lava Jato');
    expect(fields['idTime'], '1');
    expect(fields['idsTimes'], ['1']);
  });

  test('filterCandidates: conta, busca sem acento, ordem e sem os do time', () {
    const ana = PlayerDTO(id: 'p5', name: 'Ána', team: 'Volta', teamId: '2', userId: 'u5');
    const all = [_volta, _already, ana, _noTeam];
    List<String> ids({String query = '', LinkAccountFilter account = LinkAccountFilter.all}) => [
          for (final p
              in PlayerLinkPlan.filterCandidates(all, teamId: '1', team: 'Lava Jato', query: query, account: account))
            p.id,
        ];
    expect(ids(), ['p1', 'p5', 'p2']);
    expect(ids(account: LinkAccountFilter.withAccount), ['p1', 'p5']);
    expect(ids(account: LinkAccountFilter.withoutAccount), ['p2']);
    expect(ids(query: 'ana'), ['p5']);
  });

  group('folhas do vínculo', () {
    late _FakeLink link;
    late LinkPlayerCubit cubit;

    setUp(() {
      link = _FakeLink();
      cubit = LinkPlayerCubit(link, _FakeTeams(), _FakeChampionships());
    });
    tearDown(() => cubit.close());

    Future<void> open(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showLinkPlayerToTeam(
                context,
                teamId: '1',
                team: 'Lava Jato',
                region: 'Floresta',
                season: '2026',
                cubit: cubit,
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    testWidgets('lista sem time e de outro time, com o selo da conta; vincula', (tester) async {
      await open(tester);
      expect(find.byKey(const ValueKey('link-candidate-p1')), findsOneWidget);
      expect(find.byKey(const ValueKey('link-candidate-p2')), findsOneWidget);
      expect(find.byKey(const ValueKey('link-candidate-p4')), findsNothing); // já é do time
      expect(find.text('Sem time'), findsOneWidget);
      expect(find.text('com conta'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('link-candidate-p1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('link-make-main')), findsNothing); // sem time: vira principal
      await tester.tap(find.byKey(const ValueKey('link-championship-8')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('link-save')));
      await tester.pumpAndSettle();

      expect(link.player, _noTeam);
      expect(link.plan!.setMain, isTrue);
      expect(link.plan!.upserts.single.championshipId, 8);
    });

    testWidgets('competição de outro time pede "Transferir" e confirma', (tester) async {
      await open(tester);
      await tester.tap(find.byKey(const ValueKey('link-candidate-p2')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('link-transfer-7')), findsOneWidget);
      expect(find.byKey(const ValueKey('link-make-main')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('link-transfer-7')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('link-save')));
      await tester.pumpAndSettle();
      expect(find.text('Confirmar transferência?'), findsOneWidget);
      await tester.tap(find.text('Transferir').last);
      await tester.pumpAndSettle();

      expect(link.plan!.upserts.single, const PlayerEnrollment(championshipId: 7, teamId: '1', team: 'Lava Jato'));
      expect(link.plan!.setMain, isFalse);
    });

    testWidgets('filtro "Sem conta" esconde quem tem conta', (tester) async {
      await open(tester);
      expect(find.text('Com conta (1)'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('link-filter-noaccount')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('link-candidate-p1')), findsNothing);
      expect(find.byKey(const ValueKey('link-candidate-p2')), findsOneWidget);
    });

    testWidgets('pagina de 20 em 20 ao rolar', (tester) async {
      link.list = [
        for (var i = 0; i < 25; i++) PlayerDTO(id: 'x$i', name: 'Atleta ${i.toString().padLeft(2, '0')}', team: ''),
      ];
      await open(tester);
      final list = find.byType(Scrollable).last;
      // 1ª página: 20 itens + o rodapé com "Carregar mais".
      await tester.scrollUntilVisible(find.byKey(const ValueKey('link-candidate-x19')), 300, scrollable: list);
      expect(find.byKey(const ValueKey('link-candidate-x20')), findsNothing);
      // Rolando até o fim, a próxima página entra sozinha.
      await tester.scrollUntilVisible(find.text('25 atletas'), 300, scrollable: list);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('link-candidate-x24')), findsOneWidget);
    });
  });
}
