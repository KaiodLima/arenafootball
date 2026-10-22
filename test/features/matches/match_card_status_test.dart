import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

final _now = DateTime(2026, 10, 22, 15, 30);

MatchCardStatus _status({String date = '22/10', String time = '16:00', int home = 0, int away = 0}) =>
    MatchCardStatus.of(
      MatchDTO(homeTeam: 'Lava Jato', awayTeam: 'Volta', date: date, time: time, homeGoals: home, awayGoals: away),
      _now,
    );

void main() {
  test('hoje antes da hora: antes do jogo, dia 0', () {
    final status = _status();
    expect(status.upcoming, isTrue);
    expect(status.dayOffset, 0);
  });

  test('hoje depois da hora ou com gol: jogada', () {
    expect(_status(time: '15:00').upcoming, isFalse);
    expect(_status(home: 1).upcoming, isFalse);
  });

  test('data passada: jogada; amanhã: dia 1; sem data: jogada', () {
    expect(_status(date: '21/10').upcoming, isFalse);
    final tomorrow = _status(date: '23/10');
    expect(tomorrow.upcoming, isTrue);
    expect(tomorrow.dayOffset, 1);
    expect(_status(date: '').upcoming, isFalse);
  });

  test('janeiro visto em dezembro é do ano que vem', () {
    final status = MatchCardStatus.of(
      const MatchDTO(homeTeam: 'A', awayTeam: 'B', date: '02/01', time: '10:00'),
      DateTime(2026, 12, 31, 20),
    );
    expect(status.upcoming, isTrue);
    expect(status.dayOffset, 2);
  });

  Future<void> pump(WidgetTester tester, MatchDTO match) => tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          body: MatchCard(
            match: match,
            isAdmin: false,
            now: _now,
            onVotingTap: () {},
            onToggleVoting: () {},
            onEditScore: () {},
            onDelete: () {},
          ),
        ),
      ));

  testWidgets('antes do jogo: horário e "HOJE" no lugar do placar', (tester) async {
    await pump(tester, const MatchDTO(homeTeam: 'Lava Jato', awayTeam: 'Volta', date: '22/10', time: '16:00'));
    expect(find.text('16:00'), findsOneWidget);
    expect(find.text('HOJE'), findsOneWidget);
    expect(find.text('0 × 0'), findsNothing);
  });

  testWidgets('jogada: placar grande', (tester) async {
    await pump(
      tester,
      const MatchDTO(
          homeTeam: 'Lava Jato', awayTeam: 'Volta', date: '22/10', time: '10:00', homeGoals: 2, awayGoals: 1),
    );
    expect(find.text('2 × 1'), findsOneWidget);
    expect(find.text('10:00'), findsOneWidget);
  });
}
