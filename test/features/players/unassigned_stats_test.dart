import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';
import 'package:arena_soccer/features/players/domain/usecases/assign_unassigned_stats_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/repair_player_totals_usecase.dart';

class _Repo implements IPlayersRepository {
  ({int goals, int assists, PlayerEnrollment? enrollment})? assigned;

  @override
  Future<Either<Failure, void>> assignUnassigned({
    required String playerId,
    int goals = 0,
    int assists = 0,
    PlayerEnrollment? enrollment,
    String? season,
  }) async {
    assigned = (goals: goals, assists: assists, enrollment: enrollment);
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _cup = PlayerEnrollment(championshipId: 7, teamId: 't1', team: 'Riacho', goals: 2, assists: 1);

void main() {
  group('sem competição', () {
    test('atleta antigo: o Geral inteiro', () {
      const player = PlayerDTO(name: 'Kaio', team: 'Riacho', goals: 1, assists: 2);
      expect(player.unassignedGoals, 1);
      expect(player.unassignedAssists, 2);
    });

    test('com inscrições: o que passa da soma', () {
      const player = PlayerDTO(name: 'Kaio', team: 'Riacho', goals: 3, assists: 1, enrollments: [_cup]);
      expect(player.unassignedGoals, 1);
      expect(player.unassignedAssists, 0);
    });

    test('Geral igual à soma: nada solto', () {
      const player = PlayerDTO(name: 'Kaio', team: 'Riacho', goals: 2, assists: 1, enrollments: [_cup]);
      expect(player.unassignedGoals, 0);
    });
  });

  group('reparo por competição', () {
    test('contagem nas partidas: lado e time do gol; amistoso fora', () {
      const goals = [
        MatchGoal(id: 'g1', side: MatchSide.away, scorerId: 'p1', assistantId: 'p2'),
        MatchGoal(id: 'g2', side: MatchSide.away, scorerId: 'p1'),
      ];
      const match = MatchDTO(
        id: 'm1',
        homeTeam: 'Lava Jato',
        awayTeam: 'Riacho',
        homeTeamId: 't0',
        awayTeamId: 't1',
        championshipId: 7,
        goals: goals,
      );
      const friendly = MatchDTO(id: 'm2', homeTeam: 'A', awayTeam: 'B', goals: goals);
      final counts = RepairPlayerTotalsUseCase.championshipCounts([match, friendly]);
      expect(counts['p1']?[7], (goals: 2, assists: 0, teamId: 't1', team: 'Riacho'));
      expect(counts['p2']?[7]?.assists, 1);
      expect(counts['p1']!.length, 1);
    });

    test('cria a inscrição que falta, sobe a que ficou abaixo e nunca baixa', () {
      const player = PlayerDTO(name: 'Kaio', team: 'Riacho', goals: 3, enrollments: [_cup]);
      final repaired = player.repairedEnrollments({
        7: (goals: 1, assists: 3, teamId: 't1', team: 'Riacho'),
        9: (goals: 1, assists: 0, teamId: 't2', team: 'Lava Jato'),
      })!;
      expect(repaired.map((e) => (e.championshipId, e.goals, e.assists)), [(7, 2, 3), (9, 1, 0)]);
      expect(player.repairedEnrollments({7: (goals: 1, assists: 0, teamId: 't1', team: 'Riacho')}), isNull);
    });

    test('atleta antigo ganha inscrição: Geral nunca abaixo da soma, sem descontar amistosos', () {
      const legacy = PlayerDTO(name: 'Kaio', team: 'Riacho', goals: 1);
      final enrollments = legacy.repairedEnrollments({7: (goals: 2, assists: 0, teamId: 't1', team: 'Riacho')});
      expect(
        legacy.repairedTotals(stored: 1, storedAssists: 0, friendlyGoals: 1, enrollments: enrollments),
        {PlayerDTO.goalsField: 2, PlayerDTO.friendlyGoalsField: 1},
      );
      // Sem inscrição nova, o antigo continua só com os amistosos.
      expect(legacy.repairedTotals(stored: 1, storedAssists: 0), isNull);
    });
  });

  group('atribuir', () {
    test('para a competição: até a sobra', () async {
      final repo = _Repo();
      const player = PlayerDTO(id: 'p1', name: 'Kaio', team: 'Riacho', goals: 3, assists: 1, enrollments: [_cup]);
      await AssignUnassignedStatsUseCase(repo)(player, goals: 5, assists: 1, enrollment: _cup);
      expect(repo.assigned?.goals, 1);
      expect(repo.assigned?.assists, 0);
      expect(repo.assigned?.enrollment, _cup);
    });

    test('para amistosos: sem inscrição', () async {
      final repo = _Repo();
      const player = PlayerDTO(id: 'p1', name: 'Kaio', team: 'Riacho', goals: 1);
      await AssignUnassignedStatsUseCase(repo)(player, goals: 1);
      expect(repo.assigned, (goals: 1, assists: 0, enrollment: null));
    });
  });
}
