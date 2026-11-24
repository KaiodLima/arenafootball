import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/match_day.dart';

MatchDTO _match(String id, String date, String time, {int home = 0, int away = 0}) =>
    MatchDTO(id: id, homeTeam: 'A', awayTeam: 'B', date: date, time: time, homeGoals: home, awayGoals: away);

void main() {
  group('groupMatchesByDate', () {
    test('lista vazia', () {
      expect(groupMatchesByDate(const []), isEmpty);
    });

    test('próximos primeiro (hoje na frente, do mais perto ao mais longe), depois os já jogados', () {
      // Hoje: 03/06 (meio-dia em Brasília).
      final now = DateTime.utc(2026, 6, 3, 15);
      final days = groupMatchesByDate([
        _match('1', '28/05', '15:00'),
        _match('2', '08/06', '15:45'),
        _match('3', '03/06', '15:45'),
        _match('4', '08/06', '16:45'),
        _match('5', '20/06', '10:00'),
        _match('6', '01/06', '10:00'),
      ], now: now);
      expect(days.map((d) => d.date), ['03/06', '08/06', '20/06', '01/06', '28/05']);
      expect(days[1].matches.map((m) => m.id), ['2', '4']);
    });

    test('ordena pelo horário dentro do dia', () {
      final days = groupMatchesByDate([_match('late', '08/06', '16:45'), _match('early', '08/06', '9:30')]);
      expect(days.single.matches.map((m) => m.id), ['early', 'late']);
    });

    test('datas inválidas vão para um grupo sem data no fim', () {
      final days = groupMatchesByDate([_match('x', 'amanhã', ''), _match('y', '01/06', ''), _match('z', '', '')]);
      expect(days.map((d) => d.date), ['01/06', '']);
      expect(days.last.matches.map((m) => m.id), ['x', 'z']);
    });
  });

  group('MatchesSummary', () {
    test('soma jogos e gols e calcula a média', () {
      final summary = MatchesSummary.of([_match('1', '', '', home: 2, away: 2), _match('2', '', '', home: 0, away: 3)]);
      expect(summary.games, 2);
      expect(summary.goals, 7);
      expect(summary.average, 3.5);
    });

    test('média 0 sem jogos', () {
      expect(MatchesSummary.of(const []).average, 0);
    });
  });
}
