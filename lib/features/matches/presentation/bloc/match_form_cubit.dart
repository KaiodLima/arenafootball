import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_cache_first_usecase.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/usecases/create_match_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_region_matches_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/watch_matches_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_form_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Cadastro de partida (admin). As partidas já cadastradas na região
/// alimentam as sugestões (horários e locais) e o aviso de conflito.
class MatchFormCubit extends Cubit<MatchFormState> {
  final CreateMatchUseCase createMatchUseCase;
  final GetRegionsUseCase getRegionsUseCase;
  final GetTeamsCacheFirstUseCase getTeamsCacheFirstUseCase;
  final GetRegionMatchesUseCase getRegionMatchesUseCase;
  final GetRegionChampionshipsCacheFirstUseCase getRegionChampionshipsCacheFirstUseCase;

  MatchFormCubit(
    this.createMatchUseCase,
    this.getRegionsUseCase,
    this.getTeamsCacheFirstUseCase,
    this.getRegionMatchesUseCase,
    this.getRegionChampionshipsCacheFirstUseCase,
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
    _edit(state.form.copyWith(
      selectedRegion: region,
      teams: const [],
      regionTeams: const [],
      championships: const [],
      championshipId: () => null,
      existing: const [],
      clearTeams: true,
    ));
    await _loadRegionData(region);
  }

  /// Times da temporada atual, campeonatos da região e partidas já
  /// cadastradas nela. Com vários campeonatos, começa no mais antigo. O
  /// mandante começa no primeiro time e o visitante no último (como no app
  /// antigo); o local começa no mais usado.
  Future<void> _loadRegionData(String region) async {
    // Cache-first: fica com a última emissão (o remoto quando revalidou).
    final teamsFuture = getTeamsCacheFirstUseCase(region: region).last;
    final matchesFuture = getRegionMatchesUseCase(region: region);
    final championshipsFuture =
        getRegionChampionshipsCacheFirstUseCase(region: region, season: SeasonCollection.currentSeason).last;
    final teamsResponse = await teamsFuture;
    final matchesResponse = await matchesFuture;
    final championshipsResponse = await championshipsFuture;
    if (isClosed || state.form.selectedRegion != region) return;

    final regionTeams = teamsResponse.fold((_) => const <TeamDTO>[], (list) => list);
    // Sem as partidas, só faltam as sugestões e o aviso de conflito.
    final existing = matchesResponse.fold((_) => const <MatchDTO>[], (list) => list);
    // Sem os campeonatos, o UseCase resolve pelo campeonato da região.
    final championships = championshipsResponse.fold((_) => const <ChampionshipDTO>[], (list) => list);
    final championshipId = championships.firstOrNull?.championshipId;

    var form = state.form.copyWith(
      regionTeams: regionTeams,
      championships: championships,
      championshipId: () => championshipId,
      existing: existing,
    );
    form = _withTeams(form.copyWith(teams: form.teamsFor(championshipId)));
    if (form.venue.isEmpty && form.frequentVenues.isNotEmpty) form = form.copyWith(venue: form.frequentVenues.first);
    _edit(form);
  }

  MatchFormData _withTeams(MatchFormData form) => form.teams.isEmpty
      ? form.copyWith(clearTeams: true)
      : form.copyWith(homeTeam: form.teams.first.name, awayTeam: form.teams.last.name);

  /// Outro campeonato: os times oferecidos passam a ser os dele.
  void selectChampionship(int championshipId) {
    if (championshipId == state.form.championshipId) return;
    final form = state.form.copyWith(championshipId: () => championshipId);
    _edit(_withTeams(form.copyWith(teams: form.teamsFor(championshipId))));
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
