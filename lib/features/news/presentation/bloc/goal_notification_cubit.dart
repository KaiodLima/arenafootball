import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/create_news_usecase.dart';
import 'package:arena_soccer/features/news/presentation/bloc/goal_notification_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

/// Publica um card de gol (notícia com tag "gol") com o placar da partida.
class GoalNotificationCubit extends Cubit<GoalNotificationState> {
  final CreateNewsUseCase createNewsUseCase;
  final GetRegionsUseCase getRegionsUseCase;
  final GetTeamsUseCase getTeamsUseCase;

  GoalNotificationCubit(
    this.createNewsUseCase,
    this.getRegionsUseCase,
    this.getTeamsUseCase,
  ) : super(const EditingGoalNotificationState());

  void _edit(GoalFormData form) => emit(EditingGoalNotificationState(form: form));

  Future<void> load({required String initialRegion}) async {
    _edit(state.form.copyWith(regions: [initialRegion], selectedRegion: initialRegion));
    final loadTeams = _loadTeams(initialRegion);

    final response = await getRegionsUseCase();
    final regions = response.fold((_) => <String>[], (list) => list);
    if (regions.isNotEmpty) {
      final current = state.form.selectedRegion ?? initialRegion;
      _edit(state.form.copyWith(regions: regions.contains(current) ? regions : [current, ...regions]));
    }
    await loadTeams;
  }

  Future<void> selectRegion(String region) async {
    _edit(state.form.copyWith(selectedRegion: region, teams: const [], clearTeams: true));
    await _loadTeams(region);
  }

  /// Times da temporada corrente na região. Como no app antigo, o mandante
  /// começa no primeiro time e o visitante no último.
  Future<void> _loadTeams(String region) async {
    final response = await getTeamsUseCase(region: region);
    final teams = response.fold((_) => <String>[], (list) => list.map((team) => team.name).toList());
    if (state.form.selectedRegion != region) return;
    if (teams.isEmpty) {
      _edit(state.form.copyWith(teams: const [], clearTeams: true));
      return;
    }
    _edit(state.form.copyWith(teams: teams, homeTeam: teams.first, awayTeam: teams.last));
  }

  void selectHomeTeam(String team) => _edit(state.form.copyWith(homeTeam: team));

  void selectAwayTeam(String team) => _edit(state.form.copyWith(awayTeam: team));

  void changeHomeGoals(String value) => _edit(state.form.copyWith(homeGoals: value.trim()));

  void changeAwayGoals(String value) => _edit(state.form.copyWith(awayGoals: value.trim()));

  Future<void> submit() async {
    final form = state.form;
    if (!form.hasTeams || state is SubmittingGoalNotificationState) return;
    emit(SubmittingGoalNotificationState(form: form));

    final response = await createNewsUseCase(
      news: NewsDTO(
        tag: NewsDTO.goalTag,
        isVisible: true,
        region: form.selectedRegion ?? '',
        homeTeam: form.homeTeam!,
        awayTeam: form.awayTeam!,
        homeGoals: form.homeGoals,
        awayGoals: form.awayGoals,
      ),
    );
    response.fold(
      (failure) => emit(ErrorGoalNotificationState(form: form, errorMessage: failure.toString())),
      (_) => emit(SuccessGoalNotificationState(form: form)),
    );
  }
}
