import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/players/domain/usecases/repair_player_totals_usecase.dart';

const _enrollments = [
  PlayerEnrollment(championshipId: 7, teamId: '1', team: 'Lava Jato', goals: 5, assists: 2),
  PlayerEnrollment(championshipId: 9, teamId: '1', team: 'Lava Jato', goals: 3, assists: 1),
];

PlayerDTO _cached({int goals = 0, int assists = 0, bool enrolled = true, int friendlyGoals = 0}) =>
    PlayerDTO.fromCache({
      'id': 'dudu',
      'name': 'Dudu',
      'team': 'Lava Jato',
      'goals': goals,
      'assists': assists,
      'friendlyGoals': friendlyGoals,
      if (enrolled) 'enrollments': PlayerEnrollment.mapOf(_enrollments),
    });

void main() {
  test('geral nunca fica abaixo da soma das competições', () {
    // Gravado 4 (ajuste antigo só no total), competições somam 8.
    final player = _cached(goals: 4, assists: 0);
    expect(player.goals, 8);
    expect(player.assists, 3);
    expect(player.statIn(PlayerDTO.goalsField, null), 8);
    expect(player.statIn(PlayerDTO.goalsField, 7), 5);
  });

  test('amistosos à parte: chip "Amistosos" lê a contagem própria', () {
    final player = _cached(goals: 8, friendlyGoals: 2);
    expect(player.statIn(PlayerDTO.goalsField, PlayerDTO.friendlyId), 2);
    expect(player.goals, 8);
  });

  test('atleta antigo (sem inscrições): o número gravado', () {
    expect(_cached(goals: 4, enrolled: false).goals, 4);
  });

  test('correção: geral = soma (tirando amistosos que entraram nele), amistosos à parte', () {
    final player = _cached(goals: 4);
    // Gravado abaixo da soma: sobe para a soma.
    expect(player.repairedTotals(stored: 4, storedAssists: 3), {PlayerDTO.goalsField: 8});
    // Gravado com 2 gols de amistoso dentro: sai para a contagem à parte.
    expect(
      player.repairedTotals(stored: 10, storedAssists: 3, friendlyGoals: 2),
      {PlayerDTO.goalsField: 8, PlayerDTO.friendlyGoalsField: 2},
    );
    // Já certo: nada a gravar.
    expect(_cached(goals: 8, friendlyGoals: 2).repairedTotals(stored: 8, storedAssists: 3, friendlyGoals: 2), isNull);
  });

  test('amistosos contados nas partidas sem competição', () {
    final counts = RepairPlayerTotalsUseCase.friendlyCounts(const [
      MatchDTO(homeTeam: 'A', awayTeam: 'B', goals: [
        MatchGoal(id: '1', side: MatchSide.home, scorerId: 'dudu', assistantId: 'ana'),
        MatchGoal(id: '2', side: MatchSide.home, scorerId: 'dudu'),
      ]),
      MatchDTO(homeTeam: 'A', awayTeam: 'C', championshipId: 7, goals: [
        MatchGoal(id: '3', side: MatchSide.home, scorerId: 'dudu'),
      ]),
    ]);
    expect(counts['dudu'], (goals: 2, assists: 0));
    expect(counts['ana'], (goals: 0, assists: 1));
  });
}
