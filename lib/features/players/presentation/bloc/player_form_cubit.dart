import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/players/domain/usecases/create_player_usecase.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_form_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

/// Cadastro de jogador (admin).
class PlayerFormCubit extends Cubit<PlayerFormState> {
  final CreatePlayerUseCase createPlayerUseCase;
  final GetRegionsUseCase getRegionsUseCase;
  final GetTeamsUseCase getTeamsUseCase;

  PlayerFormCubit(
    this.createPlayerUseCase,
    this.getRegionsUseCase,
    this.getTeamsUseCase,
  ) : super(const EditingPlayerFormState());

  void _edit(PlayerFormData form) => emit(EditingPlayerFormState(form: form));

  Future<void> load({required String initialRegion}) async {
    _edit(PlayerFormData(regions: [initialRegion], selectedRegion: initialRegion));
    await _loadTeams(initialRegion);

    final response = await getRegionsUseCase();
    if (isClosed) return;
    final regions = response.fold((_) => <String>[], (list) => list);
    if (regions.isEmpty) return;
    final current = state.form.selectedRegion ?? initialRegion;
    _edit(state.form.copyWith(regions: regions.contains(current) ? regions : [current, ...regions]));
  }

  /// Times da região na temporada corrente (coleção `times` sem sufixo),
  /// onde o jogador novo é gravado.
  Future<void> _loadTeams(String region) async {
    final response = await getTeamsUseCase(region: region);
    if (isClosed || state.form.selectedRegion != region) return;
    response.fold(
      (failure) => emit(ErrorPlayerFormState(form: state.form.withTeams(const []), errorMessage: failure.toString())),
      (teams) => _edit(state.form.withTeams(teams.map((team) => team.name).toList())),
    );
  }

  Future<void> selectRegion(String region) async {
    _edit(state.form.copyWith(selectedRegion: region).withTeams(const []));
    await _loadTeams(region);
  }

  void selectTeam(String team) => _edit(state.form.copyWith(selectedTeam: team));

  void changeName(String value) => _edit(state.form.copyWith(name: value));

  void changeGoals(String value) => _edit(state.form.copyWith(goals: value));

  void changeAssists(String value) => _edit(state.form.copyWith(assists: value));

  Future<void> submit() async {
    final form = state.form;
    if (form.error != null || state is SubmittingPlayerFormState) return;
    emit(SubmittingPlayerFormState(form: form));

    final response = await createPlayerUseCase(form.toPlayer());
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorPlayerFormState(form: form, errorMessage: failure.toString())),
      // Como no app antigo, continua na tela para cadastrar o próximo.
      (_) => emit(SuccessPlayerFormState(form: form.cleared())),
    );
  }
}
