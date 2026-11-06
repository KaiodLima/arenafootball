import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/championship_groups_usecases.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/bloc/organizer_groups_cubit.dart';
import 'package:arena_soccer/features/players/presentation/page/team_players_page.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

List<TeamDTO> _teams(int n) => [for (var i = 0; i < n; i++) TeamDTO(id: 't$i', name: 'Time $i')];

void main() {
  test('sorteio: todos os times, sem repetir, até 4 por grupo e tamanhos parecidos', () {
    final teams = _teams(10);
    final groups = drawGroups(teams, 3, random: Random(7));
    expect(groups, hasLength(3));
    final all = groups.expand((g) => g).map((t) => t.id).toList();
    expect(all.toSet(), teams.map((t) => t.id).toSet());
    expect(all, hasLength(10));
    expect(groups.map((g) => g.length), everyElement(lessThanOrEqualTo(GroupDTO.maxTeams)));
    final sizes = groups.map((g) => g.length);
    expect(sizes.reduce(max) - sizes.reduce(min), lessThanOrEqualTo(1));
  });

  test('quantidades de grupos possíveis', () {
    expect(groupCountOptions(1), isEmpty);
    expect(groupCountOptions(4), [1, 2]);
    expect(groupCountOptions(10), [3, 4, 5]);
    expect(groupCountOptions(40), [10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]);
    expect(groupCountOptions(20), [5, 6, 7, 8, 9, 10]);
  });

  test('nomes: A, B... e o próximo livre', () {
    expect(groupLetter(0), 'A');
    expect(groupLetter(2), 'C');
    const state = OrganizerGroupsState(groups: [
      GroupDTO(id: 'g1', description: 'A'),
      GroupDTO(id: 'g2', description: 'C'),
    ]);
    expect(state.nextName(), 'B');
  });

  test('times livres: fora dos outros grupos (o editado continua disponível)', () {
    final teams = _teams(4);
    final a = GroupDTO(id: 'g1', description: 'A', teams: const ['Time 0', 'Time 1'], teamIds: const ['t0', 't1']);
    // Grupo antigo, só com o nome.
    final b = GroupDTO(id: 'g2', description: 'B', teams: const ['time 2']);
    final state = OrganizerGroupsState(groups: [a, b], teams: teams);
    expect(state.freeTeams().map((t) => t.id), ['t3']);
    expect(state.freeTeams(editing: a).map((t) => t.id), ['t0', 't1', 't3']);
  });

  test('grupo gravado com o doc do campeonato', () {
    final group = OrganizerGroupsCubit.groupOf('A', _teams(2));
    final map = GroupDTO(
      id: '',
      description: group.description,
      teams: group.teams,
      teamIds: group.teamIds,
      championshipId: 8,
      championshipDocId: 'c1',
    ).toMap();
    expect(map['fk_campeonato'], 8);
    expect(map[GroupDTO.championshipDocField], 'c1');
    expect(map['idTime2'], 't1');
    expect(map['time3'], '');
  });

  test('elenco aberto pelo organizador: chips só da competição dele', () {
    const all = [
      ChampionshipDTO(id: 'a', championshipId: 3),
      ChampionshipDTO(id: 'b', championshipId: 8),
    ];
    expect(rosterChipChampionships(all, null), all);
    expect(rosterChipChampionships(all, 8).map((c) => c.id), ['b']);
  });
}
