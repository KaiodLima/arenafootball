import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/usecases/create_match_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_region_matches_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/watch_matches_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_form_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

/// Cadastro de partida (admin). As partidas já cadastradas na região
/// alimentam as sugestões (horários e locais) e o aviso de conflito.
class MatchFormCubit extends Cubit<MatchFormState> {
  final CreateMatchUseCase createMatchUseCase;
  final GetRegionsUseCase getRegionsUseCase;
  final GetTeamsUseCase getTeamsUseCase;
  final GetRegionMatchesUseCase getRegionMatchesUseCase;

  MatchFormCubit(
    this.createMatchUseCase,
    this.getRegionsUseCase,
    this.getTeamsUseCase,
    this.getRegionMatchesUseCase,
  ) : super(const EditingMatchFormState());

  void _edit(MatchFormData form) {
    if (!isClosed) emit(EditingMatchFormState(form: form));
  }

  /// [now] só para teste.
  Future<void> load({required String initialRegion, DateTime? now}) async {
    _edit(state.form.copyWith(
      regions: [initialRegion],
      selectedRegion: initialRegion,
      date: WatchMatchesUseCase.formatMatchDate(now ?? DateTime.now()),
    ));
    final loadRegion = _loadRegionData(initialRegion);

    final response = await getRegionsUseCase();
    final regions = response.fold((_) => <String>[], (list) => list);
    if (regions.isNotEmpty) {
      final current = state.form.selectedRegion ?? initialRegion;
      _edit(state.form.copyWith(regions: regions.contains(current) ? regions : [current, ...regions]));
    }
    await loadRegion;
  }

  Future<void> selectRegion(String region) async {
    if (region == state.form.selectedRegion) return;
    _edit(state.form.copyWith(selectedRegion: region, teams: const [], existing: const [], clearTeams: true));
    await _loadRegionData(region);
  }

  /// Times da temporada corrente e partidas já cadastradas na região. O
  /// mandante começa no primeiro time e o visitante no último (como no app
  /// antigo); o local começa no mais usado.
  Future<void> _loadRegionData(String region) async {
    final teamsFuture = getTeamsUseCase(region: region);
    final matchesFuture = getRegionMatchesUseCase(region: region);
    final teamsResponse = await teamsFuture;
    final matchesResponse = await matchesFuture;
    if (isClosed || state.form.selectedRegion != region) return;

    final teams = teamsResponse.fold((_) => const <TeamDTO>[], (list) => list);
    // Sem as partidas, só faltam as sugestões e o aviso de conflito.
    final existing = matchesResponse.fold((_) => const <MatchDTO>[], (list) => list);
    var form = state.form.copyWith(teams: teams, existing: existing);
    form = teams.isEmpty
        ? form.copyWith(clearTeams: true)
        : form.copyWith(homeTeam: teams.first.name, awayTeam: teams.last.name);
    if (form.venue.isEmpty && form.frequentVenues.isNotEmpty) form = form.copyWith(venue: form.frequentVenues.first);
    _edit(form);
  }

  void selectHomeTeam(String team) => _edit(state.form.copyWith(homeTeam: team));

  void selectAwayTeam(String team) => _edit(state.form.copyWith(awayTeam: team));

  /// Inverte o mando.
  void swapTeams() {
    final form = state.form;
    if (form.homeTeam == null || form.awayTeam == null) return;
    _edit(form.copyWith(homeTeam: form.awayTeam, awayTeam: form.homeTeam));
  }

  void selectDate(DateTime date) => _edit(state.form.copyWith(date: WatchMatchesUseCase.formatMatchDate(date)));

  void selectTime(String time) => _edit(state.form.copyWith(time: time));

  void selectVenue(String venue) => _edit(state.form.copyWith(venue: venue, customVenue: false));

  /// "Novo local": troca os chips pelo campo de texto.
  void startCustomVenue() => _edit(state.form.copyWith(venue: '', customVenue: true));

  void changeVenue(String value) => _edit(state.form.copyWith(venue: value));

  Future<void> submit() async {
    final form = state.form;
    if (!form.canSubmit || state is SubmittingMatchFormState) return;
    emit(SubmittingMatchFormState(form: form));

    final match = form.toMatch();
    final response = await createMatchUseCase(match);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorMatchFormState(form: form, errorMessage: failure.toString())),
      // Montar uma rodada: data, hora e local ficam; os times são escolhidos de
      // novo. A partida entra na lista para o aviso de conflito valer.
      (_) => emit(SuccessMatchFormState(
        form: form.copyWith(
          clearTeams: true,
          customVenue: false,
          existing: [...form.existing, match],
        ),
      )),
    );
  }
}
