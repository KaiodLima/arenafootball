import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';

class GroupsState extends Equatable {
  final List<GroupDTO> groups;

  const GroupsState({this.groups = const []});

  @override
  List<Object?> get props => [groups];
}

class LoadingGroupsState extends GroupsState {
  const LoadingGroupsState({super.groups});
}

class SuccessGroupsState extends GroupsState {
  const SuccessGroupsState({required super.groups});
}

class ErrorGroupsState extends GroupsState {
  final String errorMessage;

  const ErrorGroupsState({required this.errorMessage, super.groups});

  @override
  List<Object?> get props => [groups, errorMessage];
}
