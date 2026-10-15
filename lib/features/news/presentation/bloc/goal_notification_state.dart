import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
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

  /// Partida de onde o admin veio (toque no card de partida); vale para o
  /// vínculo mesmo que não seja de hoje.
  final MatchDTO? pinnedMatch;

  /// Elencos do mandante e do visitante (para escolher autor/assistência).
  final List<PlayerDTO> homeSquad;
  final List<PlayerDTO> awaySquad;

  /// Autor do gol e quem deu o passe (opcionais): ao publicar, somam +1 gol
  /// e +1 assistência nos números deles.
  final PlayerDTO? scorer;
  final PlayerDTO? assistant;

  /// Time do gol deste card: o do último "+" (ou o do autor escolhido).
  final String? scoringTeam;

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
    this.pinnedMatch,
    this.homeSquad = const [],
    this.awaySquad = const [],
    this.scorer,
    this.assistant,
    this.scoringTeam,
  });

  /// Elenco do mandante ou do visitante pelo nome do time.
  List<PlayerDTO> squadOf(String? team) {
    if (team == null) return const [];
    return team == homeTeam ? homeSquad : (team == awayTeam ? awaySquad : const []);
  }

  bool get hasTeams => homeTeam != null && awayTeam != null;

  bool get sameTeam => hasTeams && homeTeam == awayTeam;

  bool get canSubmit => hasTeams && !sameTeam;

  /// Partida vinculada: a de origem (card de partida) ou a de hoje com o
  /// mesmo mandante e visitante escolhidos.
  MatchDTO? get linkedMatch {
    final pinned = pinnedMatch;
    if (pinned != null && pinned.homeTeam == homeTeam && pinned.awayTeam == awayTeam) return pinned;
    for (final match in todayMatches) {
      if (match.homeTeam == homeTeam && match.awayTeam == awayTeam) return match;
    }
    return null;
  }

  /// Id do time de nome [teamName] na lista carregada ('' se não achar).
  String teamIdOf(String? teamName) => TeamDirectory(teams).idOf(name: teamName ?? '');

  /// Time de nome [teamName] na lista carregada (escudo e cores).
  TeamDTO? teamOf(String? teamName) {
    if (teamName == null) return null;
    for (final team in teams) {
      if (team.name == teamName) return team;
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
    MatchDTO? pinnedMatch,
    bool clearPinned = false,
    bool clearTeams = false,
    List<PlayerDTO>? homeSquad,
    List<PlayerDTO>? awaySquad,
    PlayerDTO? scorer,
    PlayerDTO? assistant,
    bool clearScorer = false,
    bool clearAssistant = false,
    String? scoringTeam,
    bool clearScoringTeam = false,
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
      pinnedMatch: clearPinned ? null : (pinnedMatch ?? this.pinnedMatch),
      homeSquad: homeSquad ?? this.homeSquad,
      awaySquad: awaySquad ?? this.awaySquad,
      scorer: clearScorer ? null : (scorer ?? this.scorer),
      assistant: clearAssistant || clearScorer ? null : (assistant ?? this.assistant),
      scoringTeam: clearScoringTeam ? null : (scoringTeam ?? this.scoringTeam),
    );
  }

  @override
  List<Object?> get props => [
        regions,
        selectedRegion,
        teams,
        homeTeam,
        awayTeam,
        homeGoals,
        awayGoals,
        todayMatches,
        updateMatch,
        pinnedMatch,
        homeSquad,
        awaySquad,
        scorer,
        assistant,
        scoringTeam,
      ];
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

  /// Jogadores que receberam o gol/a assistência (nulo = não informado).
  final PlayerDTO? scorer;
  final PlayerDTO? assistant;

  const SuccessGoalNotificationState({
    required super.form,
    this.matchUpdated = false,
    this.scorer,
    this.assistant,
  });

  @override
  List<Object?> get props => [form, matchUpdated, scorer, assistant];
}

/// O que falhou depois de o card já ter sido publicado.
enum GoalPartialFailure { match, stats }

/// Card publicado, mas a atualização da partida ou a soma nos jogadores
/// falhou.
class PartialGoalNotificationState extends GoalNotificationState {
  final String errorMessage;
  final GoalPartialFailure failure;

  const PartialGoalNotificationState({
    required super.form,
    required this.errorMessage,
    this.failure = GoalPartialFailure.match,
  });

  @override
  List<Object?> get props => [form, errorMessage, failure];
}

class ErrorGoalNotificationState extends GoalNotificationState {
  final String errorMessage;

  const ErrorGoalNotificationState({required super.form, required this.errorMessage});

  @override
  List<Object?> get props => [form, errorMessage];
}
