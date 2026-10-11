import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';

PlayerDTO _player(String name, {int goals = 0, int assists = 0}) =>
    PlayerDTO(id: name, name: name, team: 'Time', goals: goals, assists: assists);

void main() {
  group('buildRanking', () {
    test('lista vazia', () {
      expect(buildRanking(const [], StatsRankingType.goals), isEmpty);
    });

    test('empatados dividem a posição e o próximo pula (1, 1, 3)', () {
      final ranking = buildRanking(
        [_player('a', goals: 7), _player('b', goals: 7), _player('c', goals: 5), _player('d', goals: 5)],
        StatsRankingType.goals,
      );
      expect(ranking.map((e) => e.position), [1, 1, 3, 3]);
      expect(ranking.map((e) => e.value), [7, 7, 5, 5]);
    });

    test('usa o quesito pedido', () {
      final ranking = buildRanking(
        [_player('a', goals: 1, assists: 4), _player('b', goals: 9, assists: 2)],
        StatsRankingType.assists,
      );
      expect(ranking.map((e) => e.value), [4, 2]);
      expect(ranking.map((e) => e.position), [1, 2]);
    });

    test('menos de 3 jogadores', () {
      final ranking = buildRanking([_player('a', goals: 2)], StatsRankingType.goals);
      expect(ranking.single.position, 1);
    });
  });
}
