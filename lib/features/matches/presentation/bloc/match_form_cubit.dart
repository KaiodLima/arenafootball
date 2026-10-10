import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/matches/domain/usecases/create_match_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_form_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

/// Cadastro de partida (admin).
class MatchFormCubit extends Cubit<MatchFormState> {
  final CreateMatchUseCase createMatchUseCase;
  final GetRegionsUseCase getRegionsUseCase;
  final GetTeamsUseCase getTeamsUseCase;

  MatchFormCubit(
    this.createMatchUseCase,
    this.getRegionsUseCase,
    this.getTeamsUseCase,
  ) : super(const EditingMatchFormState());

  void _edit(MatchFormData form) {
    if (!isClosed) emit(EditingMatchFormState(form: form));
  }

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
    if (isClosed || state.form.selectedRegion != region) return;
    if (teams.isEmpty) {
      _edit(state.form.copyWith(teams: const [], clearTeams: true));
      return;
    }
    _edit(state.form.copyWith(teams: teams, homeTeam: teams.first, awayTeam: teams.last));
  }

  void selectHomeTeam(String team) => _edit(state.form.copyWith(homeTeam: team));

  void selectAwayTeam(String team) => _edit(state.form.copyWith(awayTeam: team));

  void changeDate(String value) => _edit(state.form.copyWith(date: value));

  void changeTime(String value) => _edit(state.form.copyWith(time: value));

  void changeVenue(String value) => _edit(state.form.copyWith(venue: value));

  Future<void> submit() async {
    final form = state.form;
    if (!form.canSubmit || state is SubmittingMatchFormState) return;
    emit(SubmittingMatchFormState(form: form));

    final response = await createMatchUseCase(form.toMatch());
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorMatchFormState(form: form, errorMessage: failure.toString())),
      // Como no app antigo, os campos ficam preenchidos para o próximo cadastro.
      (_) => emit(SuccessMatchFormState(form: form)),
    );
  }
}
