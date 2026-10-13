import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/domain/usecases/update_favorite_team_usecase.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/choose_team_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

/// Etapa 2 do cadastro. Roda já com o usuário logado: só assim o Firestore
/// libera a leitura de `competicao` e `times`.
class ChooseTeamCubit extends Cubit<ChooseTeamState> {
  final GetRegionsUseCase getRegionsUseCase;
  final GetTeamsUseCase getTeamsUseCase;
  final UpdateFavoriteTeamUseCase updateFavoriteTeamUseCase;

  ChooseTeamCubit(
    this.getRegionsUseCase,
    this.getTeamsUseCase,
    this.updateFavoriteTeamUseCase,
  ) : super(const LoadingChooseTeamState());

  Future<void> load({required String initialRegion}) async {
    emit(const LoadingChooseTeamState());
    final response = await getRegionsUseCase();
    await response.fold(
      (failure) async => emit(LoadErrorChooseTeamState(errorMessage: failure.toString())),
      (regions) async {
        if (regions.isEmpty) {
          emit(const LoadErrorChooseTeamState(errorMessage: ''));
          return;
        }
        final region = regions.contains(initialRegion) ? initialRegion : regions.first;
        await _loadTeams(regions, region);
      },
    );
  }

  /// Tenta de novo a partir do que já foi carregado.
  Future<void> retry({required String initialRegion}) async {
    if (state.regions.isEmpty) return load(initialRegion: initialRegion);
    await _loadTeams(state.regions, state.selectedRegion ?? state.regions.first);
  }

  Future<void> selectRegion(String region) async {
    if (region == state.selectedRegion) return;
    await _loadTeams(state.regions, region);
  }

  Future<void> _loadTeams(List<String> regions, String region) async {
    emit(ReadyChooseTeamState(regions: regions, selectedRegion: region, loadingTeams: true));
    final response = await getTeamsUseCase(region: region);
    // Só aplica se o usuário não trocou de região enquanto carregava.
    if (state.selectedRegion != region) return;
    response.fold(
      (failure) => emit(
        LoadErrorChooseTeamState(errorMessage: failure.toString(), regions: regions, selectedRegion: region),
      ),
      (teams) => emit(
        ReadyChooseTeamState(regions: regions, selectedRegion: region, teams: teams),
      ),
    );
  }

  void selectTeam(TeamDTO team) {
    emit(
      ReadyChooseTeamState(
        regions: state.regions,
        selectedRegion: state.selectedRegion,
        teams: state.teams,
        selectedTeam: team.name,
        selectedTeamId: team.id,
      ),
    );
  }

  Future<void> save({required String userId}) async {
    if (!state.canSave || state is SavingChooseTeamState) return;
    final current = state;
    emit(SavingChooseTeamState(current));
    final response = await updateFavoriteTeamUseCase(
      userId: userId,
      team: current.selectedTeam!,
      teamId: current.selectedTeamId,
    );
    response.fold(
      (failure) => emit(SaveErrorChooseTeamState(current, errorMessage: failure.toString())),
      (_) => emit(SavedChooseTeamState(
        region: current.selectedRegion!,
        team: current.selectedTeam!,
        teamId: current.selectedTeamId,
      )),
    );
  }
}
