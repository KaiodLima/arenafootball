import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/players/data/dtos/player_merge.dart';

const _copaVerde = 1;
const _municipal = 2;

PlayerEnrollment _in(int championship, String teamId, String team, {int goals = 0, int assists = 0}) =>
    PlayerEnrollment(championshipId: championship, teamId: teamId, team: team, goals: goals, assists: assists);

void main() {
  // Paulo: Açaí na Copa Verde (cadastro A1) e Mulekada no Municipal (B1).
  const a1 = PlayerDTO(
    id: 'a1',
    name: 'Paulo',
    team: 'Açaí',
    teamId: 'acai',
    goals: 2,
    assists: 1,
    friendlyGoals: 1,
    userId: 'u1',
    enrollments: [PlayerEnrollment(championshipId: _copaVerde, teamId: 'acai', team: 'Açaí', goals: 2, assists: 1)],
    hasEnrollmentField: true,
  );
  const b1 = PlayerDTO(
    id: 'b1',
    name: 'Paulo Silva',
    team: 'Mulekada',
    teamId: 'mulekada',
    goals: 3,
    enrollments: [PlayerEnrollment(championshipId: _municipal, teamId: 'mulekada', team: 'Mulekada', goals: 3)],
    hasEnrollmentField: true,
  );

  test('competições diferentes: cada uma com o seu time e os seus números', () {
    final result = PlayerMerge.merge(target: b1, source: a1);
    expect(result.conflict, isNull);
    final merged = result.merged!;
    expect(merged.enrollments, [
      _in(_copaVerde, 'acai', 'Açaí', goals: 2, assists: 1),
      _in(_municipal, 'mulekada', 'Mulekada', goals: 3),
    ]);
    expect((merged.goals, merged.assists, merged.friendlyGoals), (5, 1, 1));
    expect(merged.teamIds, containsAll(['mulekada', 'acai']));
    // Fica o cadastro reivindicado (id, nome e time principal).
    expect((merged.id, merged.name, merged.teamId), ('b1', 'Paulo Silva', 'mulekada'));
  });

  test('mesma competição pelo mesmo time (cadastro repetido): números somam', () {
    final dup = a1.copyWith(enrollments: [_in(_municipal, 'mulekada', 'Mulekada', goals: 1)], goals: 1);
    final merged = PlayerMerge.merge(target: b1, source: dup).merged!;
    expect(merged.enrollments, [_in(_municipal, 'mulekada', 'Mulekada', goals: 4)]);
    expect(merged.goals, 4);
  });

  test('mesma competição por times diferentes: conflito, nada juntado', () {
    final other = a1.copyWith(enrollments: [_in(_municipal, 'acai', 'Açaí')]);
    final result = PlayerMerge.merge(target: b1, source: other);
    expect(result.merged, isNull);
    expect(result.conflict, (championshipId: _municipal, currentTeam: 'Mulekada', otherTeam: 'Açaí'));
  });

  test('conflictIn: só inscrição real por outro time na mesma competição', () {
    // Açaí também disputa o Municipal, mas o Paulo não está nesse elenco.
    expect(PlayerMerge.conflictIn(a1, _municipal, 'mulekada', 'Mulekada'), isNull);
    expect(PlayerMerge.conflictIn(b1, _municipal, 'mulekada', 'Mulekada'), isNull);
    expect(
      PlayerMerge.conflictIn(b1, _municipal, 'acai', 'Açaí'),
      (championshipId: _municipal, currentTeam: 'Mulekada', otherTeam: 'Açaí'),
    );
    // Atleta antigo (sem inscrições) não bloqueia.
    const legacy = PlayerDTO(name: 'Zé', team: 'Açaí', teamId: 'acai', goals: 4);
    expect(PlayerMerge.conflictIn(legacy, _municipal, 'mulekada', 'Mulekada'), isNull);
  });

  test('withEnrollment: acrescenta a do pedido sem números; já inscrito = igual', () {
    final added = PlayerMerge.withEnrollment(a1, _in(_municipal, 'mulekada', 'Mulekada', goals: 9));
    expect(added.enrollments.last, _in(_municipal, 'mulekada', 'Mulekada'));
    expect(PlayerMerge.withEnrollment(b1, _in(_municipal, 'mulekada', 'Mulekada')), b1);
  });

  test('repointGoals: troca autor e assistência e mantém o resto', () {
    final goals = [
      {'id': 'g1', 'lado': 'casa', 'idJogador': 'a1', 'jogador': 'Paulo', 'idAssistencia': 'x'},
      {'id': 'g2', 'lado': 'fora', 'idJogador': 'y', 'idAssistencia': 'a1'},
    ];
    final fixed = PlayerMerge.repointGoals(goals, 'a1', 'b1')!;
    expect(fixed[0]['idJogador'], 'b1');
    expect(fixed[0]['jogador'], 'Paulo');
    expect(fixed[1]['idAssistencia'], 'b1');
    expect(fixed[1]['idJogador'], 'y');
    expect(PlayerMerge.repointGoals(goals, 'z', 'b1'), isNull);
    expect(PlayerMerge.repointGoals(null, 'a1', 'b1'), isNull);
  });
}
