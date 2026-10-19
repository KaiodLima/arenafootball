import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/usecases/update_match_goals_usecase.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';

/// Folha "Gols da partida": a lista em edição, a lista de quando abriu (base
/// da diferença nos números dos atletas) e os elencos dos dois lados.
class MatchGoalsState extends Equatable {
  final MatchDTO? match;
  final List<MatchGoal> original;
  final List<MatchGoal> goals;
  final List<PlayerDTO> homeSquad;
  final List<PlayerDTO> awaySquad;
  final bool saving;

  /// Salvou: a folha fecha.
  final bool saved;
  final String? errorMessage;

  const MatchGoalsState({
    this.match,
    this.original = const [],
    this.goals = const [],
    this.homeSquad = const [],
    this.awaySquad = const [],
    this.saving = false,
    this.saved = false,
    this.errorMessage,
  });

  int get homeGoals => goals.where((g) => g.side == MatchSide.home).length;

  int get awayGoals => goals.where((g) => g.side == MatchSide.away).length;

  List<MatchGoal> goalsOf(MatchSide side) => goals.where((g) => g.side == side).toList();

  List<PlayerDTO> squadOf(MatchSide side) => side == MatchSide.home ? homeSquad : awaySquad;

  /// Algo mudou desde que abriu.
  bool get dirty => goals.length != original.length || !goals.every(original.contains);

  MatchGoalsState copyWith({
    MatchDTO? match,
    List<MatchGoal>? original,
    List<MatchGoal>? goals,
    List<PlayerDTO>? homeSquad,
    List<PlayerDTO>? awaySquad,
    bool? saving,
    bool? saved,
    String? Function()? errorMessage,
  }) {
    return MatchGoalsState(
      match: match ?? this.match,
      original: original ?? this.original,
      goals: goals ?? this.goals,
      homeSquad: homeSquad ?? this.homeSquad,
      awaySquad: awaySquad ?? this.awaySquad,
      saving: saving ?? this.saving,
      saved: saved ?? this.saved,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [match, original, goals, homeSquad, awaySquad, saving, saved, errorMessage];
}

/// "Editar placar": cada gol com autor e assistência (do elenco do lado na
/// competição da partida); salvar grava a lista e acerta os números.
class MatchGoalsCubit extends Cubit<MatchGoalsState> {
  final WatchTeamPlayersUseCase watchTeamPlayersUseCase;
  final UpdateMatchGoalsUseCase updateMatchGoalsUseCase;
  String? _season;

  MatchGoalsCubit(this.watchTeamPlayersUseCase, this.updateMatchGoalsUseCase) : super(const MatchGoalsState());

  /// [newId] só para teste.
  Future<void> load({required MatchDTO match, String? season, String Function()? newId}) async {
    _season = season;
    final goals = MatchGoal.forEditing(
      saved: match.goals,
      homeGoals: match.homeGoals,
      awayGoals: match.awayGoals,
      newId: newId ?? MatchGoal.newId,
    );
    emit(MatchGoalsState(match: match, original: goals, goals: goals));
    final home = watchTeamPlayersUseCase(teamId: match.homeTeamId, teamName: match.homeTeam, season: season).first;
    final away = watchTeamPlayersUseCase(teamId: match.awayTeamId, teamName: match.awayTeam, season: season).first;
    final homeResponse = await home;
    final awayResponse = await away;
    if (isClosed) return;
    List<PlayerDTO> squad(List<PlayerDTO> list, {required bool isHome}) {
      final teamId = isHome ? match.homeTeamId : match.awayTeamId;
      final teamName = isHome ? match.homeTeam : match.awayTeam;
      // Só quem joga por esse time na competição da partida.
      final filtered = match.championshipId > 0
          ? list.where((p) => p.playsIn(match.championshipId, teamId: teamId, teamName: teamName)).toList()
          : list;
      return filtered..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    emit(state.copyWith(
      homeSquad: homeResponse.fold((_) => const [], (list) => squad(list, isHome: true)),
      awaySquad: awayResponse.fold((_) => const [], (list) => squad(list, isHome: false)),
    ));
  }

  /// Um gol a mais do [side] (autor/assistência opcionais).
  void addGoal(MatchSide side, {PlayerDTO? scorer, PlayerDTO? assistant, String Function()? newId}) {
    final goal = MatchGoal(
      id: (newId ?? MatchGoal.newId)(),
      side: side,
      scorerId: scorer?.id ?? '',
      scorerName: scorer?.name ?? '',
      assistantId: assistant != null && assistant.id != scorer?.id ? assistant.id : '',
      assistantName: assistant != null && assistant.id != scorer?.id ? assistant.name : '',
    );
    emit(state.copyWith(goals: [...state.goals, goal], errorMessage: () => null));
  }

  /// Corrige o autor/assistência de um gol.
  void updateGoal(String id, {PlayerDTO? scorer, PlayerDTO? assistant}) {
    emit(state.copyWith(
      goals: [
        for (final g in state.goals)
          if (g.id != id)
            g
          else
            MatchGoal(
              id: g.id,
              side: g.side,
              scorerId: scorer?.id ?? '',
              scorerName: scorer?.name ?? '',
              assistantId: assistant != null && assistant.id != scorer?.id ? assistant.id : '',
              assistantName: assistant != null && assistant.id != scorer?.id ? assistant.name : '',
            ),
      ],
      errorMessage: () => null,
    ));
  }

  void removeGoal(String id) => emit(state.copyWith(goals: [
        for (final g in state.goals)
          if (g.id != id) g
      ], errorMessage: () => null));

  Future<void> save() async {
    final match = state.match;
    if (match == null || state.saving || !state.dirty) return;
    emit(state.copyWith(saving: true, errorMessage: () => null));
    final response = await updateMatchGoalsUseCase(
      match: match,
      before: state.original,
      after: state.goals,
      season: _season,
    );
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(saving: false, errorMessage: () => failure.toString())),
      (updated) => emit(state.copyWith(match: updated, original: state.goals, saving: false, saved: true)),
    );
  }
}
