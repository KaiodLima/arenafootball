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

  test('caso relatado: iniciada na mão às 20:28, 40 min, esquecida em andamento', () {
    final forgotten = const MatchDTO(
      homeTeam: 'Real Luiz',
      awayTeam: 'Capão FC',
      date: '22/10',
      time: '21:00',
      durationMinutes: 40,
      manualStatus: MatchManualStatus.live,
    ).copyWith(startedAt: _at(20, 28));
    // Fim esperado 21:08; encerra sozinha às 21:38.
    expect(MatchClock.expectedEnd(forgotten, _at(21, 0)), _at(21, 8));
    final playing = MatchCardStatus.of(forgotten, _at(21, 20));
    expect(playing.live, isTrue);
    expect(playing.nextChange, _at(21, 38));
    final late = MatchCardStatus.of(forgotten, _at(21, 49));
    expect(late.live, isFalse);
    expect(late.finished, isTrue);
  });

  test('acréscimo do 1º tempo até +10; depois, 2º tempo contínuo', () {
    final manual = const MatchDTO(homeTeam: 'A', awayTeam: 'B', date: '22/10', time: '21:00', durationMinutes: 40)
        .copyWith(manualStatus: MatchManualStatus.live, startedAt: _at(20, 0));
    expect(MatchClock.of(manual, _at(20, 24)).minuteLabel, "20+5'");
    final second = MatchClock.of(manual, _at(20, 30));
    expect(second.phase, MatchClockPhase.secondHalf);
    expect(second.minuteLabel, "31'");
  });

  test('intervalo esquecido também encerra', () {
    final halfTime = _match.copyWith(manualStatus: MatchManualStatus.halfTime, halfTimeAt: _at(15, 45));
    // 15:45 + 15 de pausa + 45 do 2º tempo = 16:45; encerra às 17:15.
    expect(MatchCardStatus.of(halfTime, _at(17, 0)).halfTime, isTrue);
    expect(MatchCardStatus.of(halfTime, _at(17, 16)).finished, isTrue);
  });
}
