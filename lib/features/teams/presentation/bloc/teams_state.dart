import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

class TeamsState extends Equatable {
  final List<TeamDTO> teams;

  const TeamsState({this.teams = const []});

  @override
  List<Object?> get props => [teams];
}

class LoadingTeamsState extends TeamsState {
  const LoadingTeamsState({super.teams});
}

class SuccessTeamsState extends TeamsState {
  const SuccessTeamsState({required super.teams});
}

class ErrorTeamsState extends TeamsState {
  final String errorMessage;

  const ErrorTeamsState({required this.errorMessage, super.teams});

  @override
  List<Object?> get props => [teams, errorMessage];
}
