import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/register_user_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

class RegisterUserCubit extends Cubit<RegisterUserState> {
  final SignUpUseCase signUpUseCase;
  final GetRegionsUseCase getRegionsUseCase;
  final GetTeamsUseCase getTeamsUseCase;

  RegisterUserCubit(
    this.signUpUseCase,
    this.getRegionsUseCase,
    this.getTeamsUseCase,
  ) : super(const EditingRegisterUserState());

  EditingRegisterUserState get _form => EditingRegisterUserState(
        name: state.name,
        email: state.email,
        password: state.password,
        regions: state.regions,
        selectedRegion: state.selectedRegion,
        teams: state.teams,
        selectedTeam: state.selectedTeam,
      );

  Future<void> load({required String initialRegion}) async {
    final response = await getRegionsUseCase();
    final regions = response.fold((_) => <String>[initialRegion], (list) => list.isEmpty ? [initialRegion] : list);
    final region = regions.contains(initialRegion) ? initialRegion : regions.first;
    emit(_form.copyWith(regions: regions, selectedRegion: region));
    await _loadTeams(region);
  }

  Future<void> selectRegion(String region) async {
    emit(_form.copyWith(selectedRegion: region, teams: const [], clearTeam: true));
    await _loadTeams(region);
  }

  Future<void> _loadTeams(String region) async {
    final response = await getTeamsUseCase(region: region);
    final teams = response.fold((_) => <String>[], (list) => list.map((t) => t.name).toList());
    // Só aplica se o usuário não trocou de região enquanto carregava.
    if (state.selectedRegion != region) return;
    emit(_form.copyWith(teams: teams, selectedTeam: teams.isEmpty ? null : teams.first, clearTeam: teams.isEmpty));
  }

  void changeName(String value) => emit(_form.copyWith(name: value));

  void changeEmail(String value) => emit(_form.copyWith(email: value));

  void changePassword(String value) => emit(_form.copyWith(password: value));

  void selectTeam(String team) => emit(_form.copyWith(selectedTeam: team));

  Future<void> submit() async {
    if (!state.canSubmit || state is SubmittingRegisterUserState) return;
    final form = state;
    emit(SubmittingRegisterUserState(form));

    final response = await signUpUseCase(
      name: form.name,
      email: form.email,
      password: form.password,
      favoriteTeam: form.selectedTeam!,
    );
    response.fold(
      (failure) => emit(ErrorRegisterUserState(form, errorMessage: failure.toString())),
      (user) => emit(SuccessRegisterUserState(user: user)),
    );
  }
}
