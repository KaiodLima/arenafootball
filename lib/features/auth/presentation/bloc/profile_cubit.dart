import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/domain/usecases/update_user_name_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/update_user_photo_usecase.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/profile_state.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_team_by_name_cache_first_usecase.dart';

/// "Meu perfil": troca o nome e a foto da conta e mostra o escudo do time do
/// coração (cache da carteirinha). Quem atualiza a sessão é a tela, ao
/// receber o aviso de salvo.
class ProfileCubit extends Cubit<ProfileState> {
  final UpdateUserNameUseCase updateUserNameUseCase;
  final UpdateUserPhotoUseCase updateUserPhotoUseCase;
  final GetTeamByNameCacheFirstUseCase? getTeamByNameCacheFirstUseCase;

  ProfileCubit(this.updateUserNameUseCase, this.updateUserPhotoUseCase, [this.getTeamByNameCacheFirstUseCase])
      : super(const ProfileState());

  /// Escudo do time do coração; sem time (ou sem o use case), nenhum.
  Future<void> loadTeam({required String name, String id = ''}) async {
    final useCase = getTeamByNameCacheFirstUseCase;
    if (useCase == null || (name.trim().isEmpty && id.isEmpty)) {
      emit(state.copyWith(clearTeam: true));
      return;
    }
    await for (final response in useCase(name, id: id)) {
      if (isClosed) return;
      final team = response.fold((_) => null, (team) => team);
      if (team != null) emit(state.copyWith(team: team));
    }
  }

  Future<void> saveName({required String userId, required String name}) async {
    if (state.savingName) return;
    emit(state.copyWith(savingName: true));
    final value = name.trim();
    final response = await updateUserNameUseCase(userId: userId, name: value);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorProfileState(state.copyWith(savingName: false), errorMessage: failure.toString())),
      (_) => emit(NameSavedProfileState(state, name: value)),
    );
  }

  Future<void> changePhoto({required String userId, required File photo}) async {
    if (state.savingPhoto) return;
    emit(state.copyWith(savingPhoto: true));
    final response = await updateUserPhotoUseCase(userId: userId, photo: photo);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorProfileState(state.copyWith(savingPhoto: false), errorMessage: failure.toString())),
      (url) => emit(PhotoSavedProfileState(state, photoUrl: url)),
    );
  }
}
