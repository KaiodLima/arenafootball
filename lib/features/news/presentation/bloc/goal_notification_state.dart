import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Dados do formulário de card de gol.
class GoalFormData extends Equatable {
  static const int maxGoals = 99;

  final List<String> regions;
  final String? selectedRegion;
  final List<TeamDTO> teams;
  final String? homeTeam;
  final String? awayTeam;
  final int homeGoals;
  final int awayGoals;

  /// Partidas de hoje da região (atalho que preenche times e placar).
  final List<MatchDTO> todayMatches;

  /// Gravar também o placar na partida de hoje correspondente.
  final bool updateMatch;

  const GoalFormData({
    this.regions = const [],
    this.selectedRegion,
    this.teams = const [],
    this.homeTeam,
    this.awayTeam,
    this.homeGoals = 0,
    this.awayGoals = 0,
    this.todayMatches = const [],
    this.updateMatch = false,
  });

  bool get hasTeams => homeTeam != null && awayTeam != null;

  bool get sameTeam => hasTeams && homeTeam == awayTeam;

  bool get canSubmit => hasTeams && !sameTeam;

  /// Partida de hoje com o mesmo mandante e visitante escolhidos.
  MatchDTO? get linkedMatch {
    for (final match in todayMatches) {
      if (match.homeTeam == homeTeam && match.awayTeam == awayTeam) return match;
    }
    return null;
  }

  String? crestOf(String? teamName) {
    if (teamName == null) return null;
    for (final team in teams) {
      if (team.name == teamName) return team.imageUrl;
    }
    return null;
  }

  GoalFormData copyWith({
    List<String>? regions,
    String? selectedRegion,
    List<TeamDTO>? teams,
    String? homeTeam,
    String? awayTeam,
    int? homeGoals,
    int? awayGoals,
    List<MatchDTO>? todayMatches,
    bool? updateMatch,
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
      todayMatches: todayMatches ?? this.todayMatches,
      updateMatch: updateMatch ?? this.updateMatch,
    );
  }

  @override
  List<Object?> get props =>
      [regions, selectedRegion, teams, homeTeam, awayTeam, homeGoals, awayGoals, todayMatches, updateMatch];
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
  /// O placar da partida também foi atualizado.
  final bool matchUpdated;

  const SuccessGoalNotificationState({required super.form, this.matchUpdated = false});

  @override
  List<Object?> get props => [form, matchUpdated];
}

/// Card publicado, mas a atualização da partida falhou.
class PartialGoalNotificationState extends GoalNotificationState {
  final String errorMessage;

  const PartialGoalNotificationState({required super.form, required this.errorMessage});

  @override
  List<Object?> get props => [form, errorMessage];
}

class ErrorGoalNotificationState extends GoalNotificationState {
  final String errorMessage;

  const ErrorGoalNotificationState({required super.form, required this.errorMessage});

  @override
  List<Object?> get props => [form, errorMessage];
}
