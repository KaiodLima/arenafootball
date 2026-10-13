import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/create_team_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_next_team_number_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/team_form_state.dart';

/// Cadastro de time (admin). Os times já cadastrados na região alimentam a
/// lista da tela e o aviso de nome duplicado.
class TeamFormCubit extends Cubit<TeamFormState> {
  final CreateTeamUseCase createTeamUseCase;
  final GetNextTeamNumberUseCase getNextTeamNumberUseCase;
  final GetRegionsUseCase getRegionsUseCase;
  final GetTeamsUseCase getTeamsUseCase;

  TeamFormCubit(
    this.createTeamUseCase,
    this.getNextTeamNumberUseCase,
    this.getRegionsUseCase,
    this.getTeamsUseCase,
  ) : super(const EditingTeamFormState());

  void _edit(TeamFormData form) {
    if (!isClosed) emit(EditingTeamFormState(form: form));
  }

  Future<void> load({required String initialRegion}) async {
    _edit(TeamFormData(regions: [initialRegion], selectedRegion: initialRegion));
    final loadTeams = _loadTeams(initialRegion);
    await _loadNextNumber();

    final response = await getRegionsUseCase();
    if (isClosed) return;
    final regions = response.fold((_) => <String>[], (list) => list);
    if (regions.isNotEmpty) {
      final current = state.form.selectedRegion ?? initialRegion;
      _edit(state.form.copyWith(regions: regions.contains(current) ? regions : [current, ...regions]));
    }
    await loadTeams;
  }

  Future<void> _loadNextNumber() async {
    final response = await getNextTeamNumberUseCase();
    if (isClosed) return;
    // Sem o número nada muda na tela; o UseCase recalcula ao gravar.
    if (response.isRight) _edit(state.form.copyWith(nextNumber: response.right));
  }

  /// Times da temporada corrente na região. Falhar só esconde a lista.
  Future<void> _loadTeams(String region) async {
    final response = await getTeamsUseCase(region: region);
    if (isClosed || state.form.selectedRegion != region) return;
    _edit(state.form.copyWith(existing: response.fold((_) => const <TeamDTO>[], (list) => list)));
  }

  void changeName(String value) => _edit(state.form.copyWith(name: value));

  void changeDescription(String value) => _edit(state.form.copyWith(description: value));

  Future<void> selectRegion(String region) async {
    if (region == state.form.selectedRegion) return;
    _edit(state.form.copyWith(selectedRegion: region, existing: const []));
    await _loadTeams(region);
  }

  void setCrest(File file) => _edit(state.form.copyWith(crest: file));

  void clearCrest() => _edit(state.form.copyWith(clearCrest: true));

  void setPrimaryColor(String hex) => _edit(state.form.copyWith(primaryColor: hex));

  void setSecondaryColor(String hex) => _edit(state.form.copyWith(secondaryColor: hex));

  Future<void> submit() async {
    final form = state.form;
    if (!form.canSubmit || state is SubmittingTeamFormState) return;
    emit(SubmittingTeamFormState(form: form));

    final response = await createTeamUseCase(team: form.toTeam(), crest: form.crest);
    if (isClosed) return;
    if (response.isLeft) {
      emit(ErrorTeamFormState(form: form, errorMessage: response.left.toString()));
      return;
    }
    // Como no app antigo, continua na tela para cadastrar o próximo time; o
    // novo time entra na lista da região.
    final cleared = form.cleared().copyWith(existing: [...form.existing, response.right]);
    emit(SuccessTeamFormState(form: cleared));
    await _loadNextNumber();
  }
}
