import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/update_team_details_usecase.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/edit_team_state.dart';

/// Edição do time pelo admin: escudo, descrição, cores e região (o nome é
/// fixo). Grava na temporada [season] (nula = atual).
class EditTeamCubit extends Cubit<EditTeamState> {
  final UpdateTeamDetailsUseCase updateTeamDetailsUseCase;
  final String? season;

  EditTeamCubit(this.updateTeamDetailsUseCase, {required TeamDTO team, this.season}) : super(EditTeamState(team: team));

  Future<void> save({
    required String description,
    required String primaryColor,
    required String secondaryColor,
    File? crest,
    String? region,
  }) async {
    if (state.saving) return;
    final team = state.team;
    final changeRegion = region != null && region.isNotEmpty && region != team.region;
    emit(state.copyWith(saving: true));
    final response = await updateTeamDetailsUseCase(
      team.copyWith(
        description: description,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        region: changeRegion ? region : team.region,
      ),
      crest: crest,
      changeRegion: changeRegion,
      season: season,
    );
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorEditTeamState(state.copyWith(saving: false), errorMessage: failure.toString())),
      (updated) => emit(SavedEditTeamState(state.copyWith(team: updated))),
    );
  }
}
