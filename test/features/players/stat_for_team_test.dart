import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';

void main() {
  const goals = PlayerDTO.goalsField;

  test('elenco geral do time: só os gols feitos por ele', () {
    // João Lucas: principal Açaí (1 gol na Copa), 3 gols pelo Veteranos na Liga.
    const joao = PlayerDTO(id: 'jl', name: 'João Lucas', team: 'Açaí', teamId: 'acai', goals: 4, enrollments: [
      PlayerEnrollment(championshipId: 7, teamId: 'acai', team: 'Açaí', goals: 1),
      PlayerEnrollment(championshipId: 9, teamId: 'vet', team: 'Veteranos', goals: 3),
    ]);
    expect(joao.statForTeam(goals, teamId: 'acai', teamName: 'Açaí'), 1);
    expect(joao.statForTeam(goals, teamId: 'vet', teamName: 'Veteranos'), 3);
  });

  test('gols sem competição contam só no time principal; antigo = Geral no principal', () {
    const unassigned = PlayerDTO(id: 'a', name: 'A', team: 'Açaí', teamId: 'acai', goals: 6, enrollments: [
      PlayerEnrollment(championshipId: 9, teamId: 'vet', team: 'Veteranos', goals: 3),
    ]);
    expect(unassigned.statForTeam(goals, teamId: 'acai', teamName: 'Açaí'), 3);
    expect(unassigned.statForTeam(goals, teamId: 'vet', teamName: 'Veteranos'), 3);

    const legacy = PlayerDTO(id: 'b', name: 'B', team: 'Açaí', teamId: 'acai', goals: 5);
    expect(legacy.statForTeam(goals, teamId: 'acai', teamName: 'Açaí'), 5);
    expect(legacy.statForTeam(goals, teamId: 'vet', teamName: 'Veteranos'), 0);
    // Doc antigo sem id: pelo nome.
    expect(legacy.statForTeam(goals, teamName: 'Açaí'), 5);
  });
}
