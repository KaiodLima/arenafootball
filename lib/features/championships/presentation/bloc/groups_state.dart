import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_table_dto.dart';

/// O estado base carrega os grupos, os escudos dos times (nome normalizado →
/// URL) e as tabelas automáticas dos grupos de campeonato (id do grupo →
/// tabela), preservados entre as transições.
class GroupsState extends Equatable {
  final List<GroupDTO> groups;
  final Map<String, String> crests;
  final Map<String, GroupTableDTO> tables;

  const GroupsState({this.groups = const [], this.crests = const {}, this.tables = const {}});

  String? crestOf(String teamName) => crests[normalizeTeamName(teamName)];

  /// Tabela calculada do grupo (nula = grupo antigo ou ainda sem tabela).
  GroupTableDTO? tableOf(GroupDTO group) {
    final table = tables[group.id];
    return table == null || table.rows.isEmpty ? null : table;
  }

  @override
  List<Object?> get props => [groups, crests, tables];
}

class LoadingGroupsState extends GroupsState {
  const LoadingGroupsState({super.groups, super.crests, super.tables});
}

class SuccessGroupsState extends GroupsState {
  const SuccessGroupsState({required super.groups, super.crests, super.tables});
}

class ErrorGroupsState extends GroupsState {
  final String errorMessage;

  const ErrorGroupsState({required this.errorMessage, super.groups, super.crests, super.tables});

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
