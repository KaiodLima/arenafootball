import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

class EditTeamState extends Equatable {
  final TeamDTO team;
  final bool saving;

  const EditTeamState({required this.team, this.saving = false});

  EditTeamState copyWith({TeamDTO? team, bool? saving}) =>
      EditTeamState(team: team ?? this.team, saving: saving ?? this.saving);

  @override
  List<Object?> get props => [team, saving];
}

/// Salvou: a tela fecha devolvendo o time atualizado.
class SavedEditTeamState extends EditTeamState {
  SavedEditTeamState(EditTeamState state) : super(team: state.team);
}

class ErrorEditTeamState extends EditTeamState {
  final String errorMessage;

  ErrorEditTeamState(EditTeamState state, {required this.errorMessage}) : super(team: state.team);

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
