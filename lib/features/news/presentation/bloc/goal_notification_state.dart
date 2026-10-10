import 'package:equatable/equatable.dart';

/// Dados do formulário de card de gol.
class GoalFormData extends Equatable {
  final List<String> regions;
  final String? selectedRegion;
  final List<String> teams;
  final String? homeTeam;
  final String? awayTeam;
  final String homeGoals;
  final String awayGoals;

  const GoalFormData({
    this.regions = const [],
    this.selectedRegion,
    this.teams = const [],
    this.homeTeam,
    this.awayTeam,
    this.homeGoals = '',
    this.awayGoals = '',
  });

  bool get hasTeams => homeTeam != null && awayTeam != null;

  GoalFormData copyWith({
    List<String>? regions,
    String? selectedRegion,
    List<String>? teams,
    String? homeTeam,
    String? awayTeam,
    String? homeGoals,
    String? awayGoals,
    bool clearTeams = false,
  }) {
    return GoalFormData(
      regions: regions ?? this.regions,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      teams: teams ?? this.teams,
      homeTeam: clearTeams ? null : (homeTeam ?? this.homeTeam),
      awayTeam: clearTeams ? null : (awayTeam ?? this.awayTeam),
      homeGoals: homeGoals ?? this.homeGoals,
      awayGoals: awayGoals ?? this.awayGoals,
    );
  }

  @override
  List<Object?> get props => [regions, selectedRegion, teams, homeTeam, awayTeam, homeGoals, awayGoals];
}

class GoalNotificationState extends Equatable {
  final GoalFormData form;

  const GoalNotificationState({this.form = const GoalFormData()});

  @override
  List<Object?> get props => [form];
}

class EditingGoalNotificationState extends GoalNotificationState {
  const EditingGoalNotificationState({super.form});
}

class SubmittingGoalNotificationState extends GoalNotificationState {
  const SubmittingGoalNotificationState({required super.form});
}

class SuccessGoalNotificationState extends GoalNotificationState {
  const SuccessGoalNotificationState({required super.form});
}

class ErrorGoalNotificationState extends GoalNotificationState {
  final String errorMessage;

  const ErrorGoalNotificationState({required super.form, required this.errorMessage});

  @override
  List<Object?> get props => [form, errorMessage];
}
