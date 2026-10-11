import 'package:equatable/equatable.dart';

/// Etapa 2 do cadastro (região e time do coração). O estado base carrega as
/// listas e a seleção, para sobreviverem às transições.
class ChooseTeamState extends Equatable {
  final List<String> regions;
  final String? selectedRegion;
  final List<String> teams;
  final String? selectedTeam;

  /// Times da região selecionada ainda carregando.
  final bool loadingTeams;

  const ChooseTeamState({
    this.regions = const [],
    this.selectedRegion,
    this.teams = const [],
    this.selectedTeam,
    this.loadingTeams = false,
  });

  bool get canSave => selectedRegion != null && selectedTeam != null && !loadingTeams;

  @override
  List<Object?> get props => [regions, selectedRegion, teams, selectedTeam, loadingTeams];
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
        );
}

class SavedChooseTeamState extends ChooseTeamState {
  const SavedChooseTeamState({required String region, required String team})
      : super(selectedRegion: region, selectedTeam: team);
}

class SaveErrorChooseTeamState extends ChooseTeamState {
  final String errorMessage;

  SaveErrorChooseTeamState(ChooseTeamState from, {required this.errorMessage})
      : super(
          regions: from.regions,
          selectedRegion: from.selectedRegion,
          teams: from.teams,
          selectedTeam: from.selectedTeam,
        );

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
