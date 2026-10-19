import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

const _goals = [
  MatchGoal(
      id: 'a', side: MatchSide.home, scorerId: 'dudu', scorerName: 'Dudu', assistantId: 'ana', assistantName: 'Ana'),
  MatchGoal(id: 'b', side: MatchSide.away),
  MatchGoal(id: 'c', side: MatchSide.home, scorerId: 'dudu', scorerName: 'Dudu'),
  MatchGoal(
      id: 'd', side: MatchSide.away, scorerId: 'rafa', scorerName: 'Rafa', assistantId: 'leo', assistantName: 'Leo'),
];

void main() {
  test('resumo: junta o mesmo autor, ignora sem autor, mantém as assistências', () {
    final home = MatchGoal.summaryOf(_goals, MatchSide.home);
    expect(home.single.scorer, 'Dudu');
    expect(home.single.count, 2);
    expect(home.single.assists, ['Ana']);
    final away = MatchGoal.summaryOf(_goals, MatchSide.away);
    expect(away.map((l) => l.scorer), ['Rafa']);
  });

  Future<void> pump(WidgetTester tester, MatchDTO match) => tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          body: MatchCard(
            match: match,
            isAdmin: false,
            showVoting: false,
            onVotingTap: () {},
            onToggleVoting: () {},
            onEditScore: () {},
            onDelete: () {},
          ),
        ),
      ));

  testWidgets('minimizado só o placar; "Gols" expande com autores e passes', (tester) async {
    await pump(
      tester,
      const MatchDTO(homeTeam: 'Lava Jato', awayTeam: 'Volta', homeGoals: 2, awayGoals: 2, goals: _goals),
    );
    expect(find.text('Dudu (2)'), findsNothing);
    await tester.tap(find.text('Gols'));
    await tester.pumpAndSettle();
    expect(find.text('Dudu (2)'), findsOneWidget);
    expect(find.text('assist. Ana'), findsOneWidget);
    expect(find.text('Rafa'), findsOneWidget);
    await tester.tap(find.text('Gols'));
    await tester.pumpAndSettle();
    expect(find.text('Dudu (2)'), findsNothing);
  });

  testWidgets('sem gol com autor: sem o botão', (tester) async {
    await pump(
      tester,
      const MatchDTO(
        homeTeam: 'Lava Jato',
        awayTeam: 'Volta',
        homeGoals: 1,
        goals: [MatchGoal(id: 'x', side: MatchSide.home)],
      ),
    );
    expect(find.text('Gols'), findsNothing);
  });
}
