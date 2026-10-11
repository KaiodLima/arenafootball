import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';

/// Nome de time normalizado: chave do mapa de escudos e da comparação com o
/// time do coração do usuário.
String normalizeTeamName(String name) => name.trim().toLowerCase();

/// O estado base carrega os grupos e os escudos dos times (nome normalizado →
/// URL), preservados entre as transições.
class GroupsState extends Equatable {
  final List<GroupDTO> groups;
  final Map<String, String> crests;

  const GroupsState({this.groups = const [], this.crests = const {}});

  String? crestOf(String teamName) => crests[normalizeTeamName(teamName)];

  @override
  List<Object?> get props => [groups, crests];
}

class LoadingGroupsState extends GroupsState {
  const LoadingGroupsState({super.groups, super.crests});
}

class SuccessGroupsState extends GroupsState {
  const SuccessGroupsState({required super.groups, super.crests});
}

class ErrorGroupsState extends GroupsState {
  final String errorMessage;

  const ErrorGroupsState({required this.errorMessage, super.groups, super.crests});

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
