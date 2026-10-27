import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';
import 'package:arena_soccer/features/players/domain/usecases/get_player_season_history_usecase.dart';
import 'package:arena_soccer/features/players/presentation/player_match_stats.dart';

class _Players implements IPlayersRepository {
  @override
  Future<Either<Failure, PlayerDTO?>> getPlayerByUser({required String userId, String? season}) async => Right(
        switch (season) {
          '2025' => const PlayerDTO(id: 'a25', name: 'Kaio', team: 'Riacho', goals: 7),
          '2026' => const PlayerDTO(id: 'a26', name: 'Kaio', team: 'Lava Jato', goals: 3),
          _ => null,
        },
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Matches implements IMatchesRepository {
  @override
  Future<Either<Failure, int>> countElectedMatches({required String playerId, String? season}) async =>
      Right(playerId == 'a25' ? 2 : 0);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _player = PlayerDTO(id: 'p1', name: 'Kaio', team: 'Riacho', teamId: 't1');

MatchDTO _match(String id, String date, {List<MatchGoal> goals = const [], int home = 0, int away = 0}) => MatchDTO(
      id: id,
      homeTeam: 'Riacho',
      awayTeam: 'Lava Jato',
      homeTeamId: 't1',
      awayTeamId: 't2',
      date: date,
      homeGoals: home,
      awayGoals: away,
      goals: goals,
    );

void main() {
  final now = DateTime(2026, 10, 27, 12);

  group('últimas partidas', () {
    test('gols e assistências do atleta, adversário e ordem por data', () {
      final stats = PlayerMatchStats.lastMatches([
        _match('m2', '20/10/2026', goals: const [
          MatchGoal(id: 'g1', side: MatchSide.home, scorerId: 'p1'),
          MatchGoal(id: 'g2', side: MatchSide.home, scorerId: 'x', assistantId: 'p1'),
        ]),
        _match('m1', '10/10/2026', goals: const [MatchGoal(id: 'g3', side: MatchSide.away, scorerId: 'y')]),
      ], _player, now: now);
      expect(stats.map((s) => s.match.id), ['m1', 'm2']);
      expect([stats[1].goals, stats[1].assists], [1, 1]);
      expect([stats[0].goals, stats[0].assists], [0, 0]);
      expect(stats[0].opponent, 'Lava Jato');
    });

    test('fora: partida futura, de outro time e antiga sem lista de gols (exceto 0 × 0)', () {
      final other = _match('o', '10/10/2026').copyWith(homeTeamId: 't8', homeTeam: 'X', awayTeamId: 't9', awayTeam: 'Y');
      final stats = PlayerMatchStats.lastMatches([
        _match('future', '30/10/2026'),
        other,
        _match('old', '01/10/2026', home: 2, away: 1),
        _match('zero', '02/10/2026'),
      ], _player, now: now);
      expect(stats.map((s) => s.match.id), ['zero']);
    });

    test('limite: as últimas', () {
      final matches = [for (var d = 1; d <= 12; d++) _match('m$d', '$d/10/2026')];
      final stats = PlayerMatchStats.lastMatches(matches, _player, now: now, limit: 10);
      expect(stats.length, 10);
      expect(stats.first.match.id, 'm3');
      expect(stats.last.match.id, 'm12');
    });
  });

  test('histórico: temporadas da conta, mais nova primeiro, com os troféus', () async {
    final history = await GetPlayerSeasonHistoryUseCase(_Players(), _Matches())(
      userId: 'u1',
      seasons: const ['2024', '2025', '2026'],
    );
    expect(history.right.map((h) => (h.season, h.player.team, h.awards)), [('2026', 'Lava Jato', 0), ('2025', 'Riacho', 2)]);
    expect((await GetPlayerSeasonHistoryUseCase(_Players(), _Matches())(userId: '', seasons: const ['2026'])).right, isEmpty);
  });
}
