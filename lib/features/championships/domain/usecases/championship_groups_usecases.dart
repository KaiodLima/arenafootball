import 'dart:math';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Grupos de um campeonato, ao vivo.
class WatchChampionshipGroupsUseCase {
  final IChampionshipsRepository _repository;

  WatchChampionshipGroupsUseCase(this._repository);

  Stream<Either<Failure, List<GroupDTO>>> call({required int championshipId, String? season}) =>
      _repository.watchChampionshipGroups(championshipId: championshipId, season: season);
}

class SaveGroupUseCase {
  final IChampionshipsRepository _repository;

  SaveGroupUseCase(this._repository);

  Future<Either<Failure, void>> call(GroupDTO group, {String? season}) => _repository.saveGroup(group, season: season);
}

class DeleteGroupUseCase {
  final IChampionshipsRepository _repository;

  DeleteGroupUseCase(this._repository);

  Future<Either<Failure, void>> call(String groupId, {String? season}) =>
      _repository.deleteGroup(groupId, season: season);
}

/// Sorteio: troca os grupos atuais pelos sorteados, num lote.
class ReplaceGroupsUseCase {
  final IChampionshipsRepository _repository;

  ReplaceGroupsUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required List<GroupDTO> previous,
    required List<GroupDTO> groups,
    String? season,
  }) =>
      _repository.replaceGroups(previous: previous, groups: groups, season: season);
}

/// Nome do grupo de posição [index]: A, B, C...
String groupLetter(int index) => String.fromCharCode('A'.codeUnitAt(0) + index);

/// Quantidades de grupos possíveis para [teamCount] times: todos cabem (até
/// [GroupDTO.maxTeams] por grupo) e cada grupo tem ao menos 2.
List<int> groupCountOptions(int teamCount) {
  if (teamCount < 2) return const [];
  final min = (teamCount / GroupDTO.maxTeams).ceil();
  return [for (var n = min; n <= teamCount ~/ 2; n++) n];
}

/// Distribui [teams] ao acaso em [count] grupos, em rodízio: os tamanhos
/// diferem em no máximo 1. [count] tem de caber todos.
List<List<TeamDTO>> drawGroups(List<TeamDTO> teams, int count, {Random? random}) {
  assert(count > 0 && teams.length <= count * GroupDTO.maxTeams);
  final shuffled = [...teams]..shuffle(random ?? Random());
  final groups = List.generate(count, (_) => <TeamDTO>[]);
  for (var i = 0; i < shuffled.length; i++) {
    groups[i % count].add(shuffled[i]);
  }
  return groups;
}
