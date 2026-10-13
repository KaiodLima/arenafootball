import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Etapa 2 do cadastro (região e time do coração). O estado base carrega as
/// listas e a seleção, para sobreviverem às transições.
class ChooseTeamState extends Equatable {
  final List<String> regions;
  final String? selectedRegion;
  final List<TeamDTO> teams;

  /// Nome do time escolhido (`usuarios.time`, cópia para exibir).
  final String? selectedTeam;

  /// Id do time escolhido (`usuarios.idTime`, o vínculo).
  final String selectedTeamId;

  /// Times da região selecionada ainda carregando.
  final bool loadingTeams;

  const ChooseTeamState({
    this.regions = const [],
    this.selectedRegion,
    this.teams = const [],
    this.selectedTeam,
    this.selectedTeamId = '',
    this.loadingTeams = false,
  });

  bool get canSave => selectedRegion != null && selectedTeam != null && !loadingTeams;

  @override
  List<Object?> get props => [regions, selectedRegion, teams, selectedTeam, selectedTeamId, loadingTeams];
}

class LoadingChooseTeamState extends ChooseTeamState {
  const LoadingChooseTeamState();
}

class ReadyChooseTeamState extends ChooseTeamState {
  const ReadyChooseTeamState({
    required super.regions,
    required super.selectedRegion,
    super.teams,
    super.selectedTeam,
    super.selectedTeamId,
    super.loadingTeams,
  });
}

class LoadErrorChooseTeamState extends ChooseTeamState {
  final String errorMessage;

  const LoadErrorChooseTeamState({required this.errorMessage, super.regions, super.selectedRegion});

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

class SavingChooseTeamState extends ChooseTeamState {
  SavingChooseTeamState(ChooseTeamState from)
      : super(
          regions: from.regions,
          selectedRegion: from.selectedRegion,
          teams: from.teams,
          selectedTeam: from.selectedTeam,
          selectedTeamId: from.selectedTeamId,
        );
}

class SavedChooseTeamState extends ChooseTeamState {
  const SavedChooseTeamState({required String region, required String team, required String teamId})
      : super(selectedRegion: region, selectedTeam: team, selectedTeamId: teamId);
}

class SaveErrorChooseTeamState extends ChooseTeamState {
  final String errorMessage;

  SaveErrorChooseTeamState(ChooseTeamState from, {required this.errorMessage})
      : super(
          regions: from.regions,
          selectedRegion: from.selectedRegion,
          teams: from.teams,
          selectedTeam: from.selectedTeam,
          selectedTeamId: from.selectedTeamId,
        );

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
