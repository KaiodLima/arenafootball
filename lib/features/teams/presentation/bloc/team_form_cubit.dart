import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/create_team_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_next_team_number_usecase.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/team_form_state.dart';

/// Cadastro de time (admin).
class TeamFormCubit extends Cubit<TeamFormState> {
  final CreateTeamUseCase createTeamUseCase;
  final GetNextTeamNumberUseCase getNextTeamNumberUseCase;
  final GetRegionsUseCase getRegionsUseCase;

  TeamFormCubit(
    this.createTeamUseCase,
    this.getNextTeamNumberUseCase,
    this.getRegionsUseCase,
  ) : super(const EditingTeamFormState());

  void _edit(TeamFormData form) => emit(EditingTeamFormState(form: form));

  Future<void> load({required String initialRegion}) async {
    _edit(TeamFormData(regions: [initialRegion], selectedRegion: initialRegion));
    await _loadNextNumber();

    final response = await getRegionsUseCase();
    if (isClosed) return;
    final regions = response.fold((_) => <String>[], (list) => list);
    if (regions.isEmpty) return;
    final current = state.form.selectedRegion ?? initialRegion;
    _edit(state.form.copyWith(regions: regions.contains(current) ? regions : [current, ...regions]));
  }

  Future<void> _loadNextNumber() async {
    final response = await getNextTeamNumberUseCase();
    if (isClosed) return;
    // Sem o número a tela só não o exibe; o UseCase recalcula ao gravar.
    if (response.isRight) _edit(state.form.copyWith(nextNumber: response.right));
  }

  void changeName(String value) => _edit(state.form.copyWith(name: value));

  void changeDescription(String value) => _edit(state.form.copyWith(description: value));

  void selectRegion(String region) => _edit(state.form.copyWith(selectedRegion: region));

  void setCrest(File file) => _edit(state.form.copyWith(crest: file));

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
    // Como no app antigo, continua na tela para cadastrar o próximo time.
    emit(SuccessTeamFormState(form: form.cleared()));
    await _loadNextNumber();
  }
}
