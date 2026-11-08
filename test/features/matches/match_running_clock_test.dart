import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/match_clock.dart';

const _match = MatchDTO(homeTeam: 'Lava Jato', awayTeam: 'Volta', date: '22/10', time: '15:00');
DateTime _at(int hour, int minute, [int second = 0]) => DateTime(2026, 10, 22, hour, minute, second);

void main() {
  final live = _match.copyWith(manualStatus: MatchManualStatus.live, startedAt: _at(15, 0));

  test('súmula: relógio corrido com segundos no 1º tempo', () {
    expect(MatchClock.runningLabel(live, _at(15, 0, 30)), '00:30');
    expect(MatchClock.runningLabel(live, _at(15, 23, 41)), '23:41');
    // Um segundo depois, o relógio andou (a tela redesenha a cada segundo).
    expect(MatchClock.runningLabel(live, _at(15, 23, 42)), '23:42');
  });

  test('acréscimo do 1º tempo sem intervalo marcado', () {
    expect(MatchClock.runningLabel(live, _at(15, 47, 10)), '45+2:10');
  });

  test('2º tempo começa em 45:00 e tem acréscimo depois dos 90', () {
    final second = live.copyWith(secondHalfAt: _at(16, 0));
    expect(MatchClock.runningLabel(second, _at(16, 0, 5)), '45:05');
    expect(MatchClock.runningLabel(second, _at(16, 48, 5)), '90+3:05');
  });

  test('intervalo: sem relógio', () {
    final halfTime = live.copyWith(manualStatus: MatchManualStatus.halfTime);
    expect(MatchClock.runningLabel(halfTime, _at(15, 50)), isNull);
  });
}
