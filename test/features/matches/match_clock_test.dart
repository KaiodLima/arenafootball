import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/match_clock.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

const _match = MatchDTO(homeTeam: 'Lava Jato', awayTeam: 'Volta', date: '22/10', time: '15:00');
DateTime _at(int hour, int minute) => DateTime(2026, 10, 22, hour, minute);

void main() {
  test('automático: 1º tempo pelo horário e 2º tempo contínuo depois da metade', () {
    final first = MatchClock.of(_match, _at(15, 23));
    expect(first.phase, MatchClockPhase.firstHalf);
    expect(first.minuteLabel, "24'");
    final second = MatchClock.of(_match, _at(15, 50));
    expect(second.phase, MatchClockPhase.secondHalf);
    expect(second.minuteLabel, "51'");
  });

  test('início manual pelo inicioEm; acréscimo no 1º tempo sem intervalo marcado', () {
    final manual = _match.copyWith(manualStatus: MatchManualStatus.live, startedAt: _at(15, 10));
    expect(MatchClock.of(manual, _at(15, 30)).minuteLabel, "21'");
    final late = MatchClock.of(manual, _at(15, 56));
    expect(late.phase, MatchClockPhase.firstHalf);
    expect(late.minuteLabel, "45+2'");
  });

  test('intervalo parado; 2º tempo recomeça do 45; acréscimo no fim', () {
    final halfTime = _match.copyWith(manualStatus: MatchManualStatus.halfTime, startedAt: _at(15, 0));
    final paused = MatchClock.of(halfTime, _at(15, 55));
    expect(paused.phase, MatchClockPhase.halfTime);
    expect(paused.minuteLabel, isNull);

    final second = _match.copyWith(
      manualStatus: MatchManualStatus.live,
      startedAt: _at(15, 0),
      secondHalfAt: _at(16, 0),
    );
    expect(MatchClock.of(second, _at(16, 0)).minuteLabel, "46'");
    expect(MatchClock.of(second, _at(16, 47)).minuteLabel, "90+3'");
    // Partida de 60 min: o 2º tempo começa do 30.
    expect(MatchClock.of(second.copyWith(durationMinutes: 60), _at(16, 0)).minuteLabel, "31'");
  });

  test('intervalo conta como em andamento no card', () {
    final status = MatchCardStatus.of(_match.copyWith(manualStatus: MatchManualStatus.halfTime), _at(15, 50));
    expect(status.live, isTrue);
    expect(status.halfTime, isTrue);
    expect(status.finished, isFalse);
  });

  Future<void> pump(WidgetTester tester, MatchDTO match, DateTime now) => tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          body: MatchCard(
            match: match,
            isAdmin: false,
            now: now,
            onVotingTap: () {},
            onToggleVoting: () {},
            onEditScore: () {},
            onDelete: () {},
          ),
        ),
      ));

  testWidgets('card: "1º TEMPO · 31\'" e "INTERVALO"', (tester) async {
    await pump(tester, _match, _at(15, 30));
    expect(find.text("1º TEMPO · 31'"), findsOneWidget);
    await pump(tester, _match.copyWith(manualStatus: MatchManualStatus.halfTime), _at(15, 50));
    expect(find.text('INTERVALO'), findsOneWidget);
  });
}
