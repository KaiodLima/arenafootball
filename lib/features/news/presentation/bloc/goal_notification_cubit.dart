import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_today_matches_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/update_match_score_usecase.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/create_news_usecase.dart';
import 'package:arena_soccer/features/news/presentation/bloc/goal_notification_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

/// Publica um card de gol (notícia com tag "gol") com o placar da partida e,
/// opcionalmente, grava o mesmo placar na partida de hoje correspondente.
class GoalNotificationCubit extends Cubit<GoalNotificationState> {
  final CreateNewsUseCase createNewsUseCase;
  final GetRegionsUseCase getRegionsUseCase;
  final GetTeamsUseCase getTeamsUseCase;
  final GetTodayMatchesUseCase getTodayMatchesUseCase;
  final UpdateMatchScoreUseCase updateMatchScoreUseCase;
  String? _season;

  /// Card de gol de partida (feed): usado só no primeiro carregamento.
  NewsDTO? _initial;

  GoalNotificationCubit(
    this.createNewsUseCase,
    this.getRegionsUseCase,
    this.getTeamsUseCase,
    this.getTodayMatchesUseCase,
    this.updateMatchScoreUseCase,
  ) : super(const EditingGoalNotificationState());

  void _edit(GoalFormData form) => emit(EditingGoalNotificationState(form: form));

  Future<void> load({required String initialRegion, String? season, NewsDTO? initial}) async {
    _season = season;
    _initial = initial;
    _edit(state.form.copyWith(regions: [initialRegion], selectedRegion: initialRegion));
    final loadRegion = _loadRegionData(initialRegion);

    final response = await getRegionsUseCase();
    if (isClosed) return;
    final regions = response.fold((_) => <String>[], (list) => list);
    if (regions.isNotEmpty) {
      final current = state.form.selectedRegion ?? initialRegion;
      _edit(state.form.copyWith(regions: regions.contains(current) ? regions : [current, ...regions]));
    }
    await loadRegion;
  }

  Future<void> selectRegion(String region) async {
    if (region == state.form.selectedRegion) return;
    _initial = null;
    _edit(state.form.copyWith(
      selectedRegion: region,
      teams: const [],
      todayMatches: const [],
      updateMatch: false,
      clearTeams: true,
    ));
    await _loadRegionData(region);
  }

  /// Times da temporada corrente e partidas de hoje da região. Como no app
  /// antigo, o mandante começa no primeiro time e o visitante no último.
  Future<void> _loadRegionData(String region) async {
    final teamsFuture = getTeamsUseCase(region: region);
    final matchesFuture = getTodayMatchesUseCase(region: region, season: _season);
    final teamsResponse = await teamsFuture;
    final matchesResponse = await matchesFuture;
    if (isClosed || state.form.selectedRegion != region) return;
    final teams = teamsResponse.fold((_) => const <TeamDTO>[], (list) => list);
    // Sem as partidas de hoje, só não aparece o atalho.
    final matches = matchesResponse.fold((_) => const <MatchDTO>[], (list) => list);

    final form = state.form.copyWith(teams: teams, todayMatches: matches);
    final initial = _initial;
    _initial = null;
    if (initial != null && initial.homeTeam.isNotEmpty && initial.awayTeam.isNotEmpty) {
      // Parte do card tocado no feed (mesmo que o time não esteja mais na lista).
      _edit(form.copyWith(
        homeTeam: initial.homeTeam,
        awayTeam: initial.awayTeam,
        homeGoals: _goals(initial.homeGoals),
        awayGoals: _goals(initial.awayGoals),
      ));
      return;
    }
    _edit(teams.isEmpty
        ? form.copyWith(clearTeams: true)
        : form.copyWith(homeTeam: teams.first.name, awayTeam: teams.last.name));
  }

  /// Gols gravados como texto no card ("2"); vazio ou inválido = 0.
  static int _goals(String value) => (int.tryParse(value.trim()) ?? 0).clamp(0, GoalFormData.maxGoals);

  void selectHomeTeam(String team) => _edit(state.form.copyWith(homeTeam: team));

  void selectAwayTeam(String team) => _edit(state.form.copyWith(awayTeam: team));

  void incrementHome() => _setGoals(home: state.form.homeGoals + 1);

  void decrementHome() => _setGoals(home: state.form.homeGoals - 1);

  void incrementAway() => _setGoals(away: state.form.awayGoals + 1);

  void decrementAway() => _setGoals(away: state.form.awayGoals - 1);

  void _setGoals({int? home, int? away}) => _edit(state.form.copyWith(
        homeGoals: home?.clamp(0, GoalFormData.maxGoals),
        awayGoals: away?.clamp(0, GoalFormData.maxGoals),
      ));

  /// Atalho "jogos de hoje": preenche times e placar atual e liga a
  /// atualização da partida.
  void pickMatch(MatchDTO match) => _edit(state.form.copyWith(
        homeTeam: match.homeTeam,
        awayTeam: match.awayTeam,
        homeGoals: match.homeGoals,
        awayGoals: match.awayGoals,
        updateMatch: true,
      ));

  void toggleUpdateMatch(bool value) => _edit(state.form.copyWith(updateMatch: value));

  Future<void> submit() async {
    final form = state.form;
    if (!form.canSubmit || state is SubmittingGoalNotificationState) return;
    emit(SubmittingGoalNotificationState(form: form));

    final response = await createNewsUseCase(
      news: NewsDTO(
        tag: NewsDTO.goalTag,
        isVisible: true,
        region: form.selectedRegion ?? '',
        homeTeam: form.homeTeam!,
        awayTeam: form.awayTeam!,
        homeGoals: '${form.homeGoals}',
        awayGoals: '${form.awayGoals}',
      ),
    );
    if (isClosed) return;
    if (response.isLeft) {
      emit(ErrorGoalNotificationState(form: form, errorMessage: response.left.toString()));
      return;
    }

    final match = form.updateMatch ? form.linkedMatch : null;
    if (match == null) {
      emit(SuccessGoalNotificationState(form: form));
      return;
    }
    final update = await updateMatchScoreUseCase(
      match: match,
      homeGoals: '${form.homeGoals}',
      awayGoals: '${form.awayGoals}',
      season: _season,
    );
    if (isClosed) return;
    update.fold(
      (failure) => emit(PartialGoalNotificationState(form: form, errorMessage: failure.toString())),
      (updated) {
        // A lista local passa a ter o placar novo.
        final matches = [for (final m in form.todayMatches) m.id == updated.id ? updated : m];
        emit(SuccessGoalNotificationState(form: form.copyWith(todayMatches: matches), matchUpdated: true));
      },
    );
  }
}
