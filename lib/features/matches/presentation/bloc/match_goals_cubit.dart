import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/matches/domain/usecases/sync_live_match_card_usecase.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/match_squads.dart';
import 'package:arena_soccer/features/matches/domain/usecases/publish_goal_cards_usecase.dart';
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

  /// Publicar card de gol no feed para os gols novos (ligado por padrão).
  final bool publishCards;

  /// Cards de gol publicados ao salvar (o aviso de "salvo" conta).
  final int publishedCards;

  const MatchGoalsState({
    this.match,
    this.original = const [],
    this.goals = const [],
    this.homeSquad = const [],
    this.awaySquad = const [],
    this.saving = false,
    this.saved = false,
    this.errorMessage,
    this.publishCards = true,
    this.publishedCards = 0,
  });

  int get homeGoals => goals.where((g) => g.side == MatchSide.home).length;

  int get awayGoals => goals.where((g) => g.side == MatchSide.away).length;

  List<MatchGoal> goalsOf(MatchSide side) => goals.where((g) => g.side == side).toList();

  List<PlayerDTO> squadOf(MatchSide side) => side == MatchSide.home ? homeSquad : awaySquad;

  /// Algo mudou desde que abriu.
  bool get dirty => goals.length != original.length || !goals.every(original.contains);

  /// Gols novos desde que abriu (os que viram card).
  int get newGoals {
    final ids = {for (final g in original) g.id};
    return goals.where((g) => !ids.contains(g.id)).length;
  }

  MatchGoalsState copyWith({
    MatchDTO? match,
    List<MatchGoal>? original,
    List<MatchGoal>? goals,
    List<PlayerDTO>? homeSquad,
    List<PlayerDTO>? awaySquad,
    bool? saving,
    bool? saved,
    String? Function()? errorMessage,
    bool? publishCards,
    int? publishedCards,
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
      publishCards: publishCards ?? this.publishCards,
      publishedCards: publishedCards ?? this.publishedCards,
    );
  }

  @override
  List<Object?> get props =>
      [match, original, goals, homeSquad, awaySquad, saving, saved, errorMessage, publishCards, publishedCards];
}

/// "Editar placar": cada gol com autor e assistência (do elenco do lado na
/// competição da partida); salvar grava a lista e acerta os números.
class MatchGoalsCubit extends Cubit<MatchGoalsState> {
  final WatchTeamPlayersUseCase watchTeamPlayersUseCase;
  final UpdateMatchGoalsUseCase updateMatchGoalsUseCase;

  /// Cards de gol dos gols novos (nulo = não publica).
  final PublishGoalCardsUseCase? publishGoalCardsUseCase;
  String? _season;

  final SyncLiveMatchCardUseCase? syncLiveMatchCardUseCase;

  MatchGoalsCubit(
    this.watchTeamPlayersUseCase,
    this.updateMatchGoalsUseCase, [
    this.publishGoalCardsUseCase,
    this.syncLiveMatchCardUseCase,
  ]) : super(const MatchGoalsState());

  void togglePublishCards(bool value) => emit(state.copyWith(publishCards: value));

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
    // Só quem joga por esse time na competição da partida.
    emit(state.copyWith(
      homeSquad: homeResponse.fold((_) => const [], (list) => matchSquad(list, match, MatchSide.home)),
      awaySquad: awayResponse.fold((_) => const [], (list) => matchSquad(list, match, MatchSide.away)),
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
    if (response.isLeft) {
      emit(state.copyWith(saving: false, errorMessage: () => response.left.toString()));
      return;
    }
    // Placar salvo: os cards de gol (novos, removidos e editados).
    var published = 0;
    final publish = publishGoalCardsUseCase;
    if (publish != null && state.publishCards) {
      final cards = await publish(match: match, before: state.original, after: state.goals, season: _season);
      if (isClosed) return;
      // O placar já foi salvo: a falha do card só avisa.
      published = cards.fold((_) => -1, (count) => count);
      final live = syncLiveMatchCardUseCase;
      if (live != null) {
        final synced =
            await live(match: response.right, before: match.copyWith(goals: state.original), season: _season);
        if (isClosed) return;
        if (synced.isLeft) published = -1;
      }
    }
    emit(state.copyWith(
      match: response.right,
      original: state.goals,
      saving: false,
      saved: true,
      publishedCards: published,
    ));
  }
}
