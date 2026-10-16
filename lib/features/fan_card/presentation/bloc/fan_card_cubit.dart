import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/domain/usecases/get_account_created_at_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/update_user_photo_usecase.dart';
import 'package:arena_soccer/features/fan_card/presentation/bloc/fan_card_state.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_team_by_name_cache_first_usecase.dart';

/// Carteirinha de torcedor: carrega o time do coração (escudo e cores) e
/// troca a foto da conta.
class FanCardCubit extends Cubit<FanCardState> {
  final GetTeamByNameCacheFirstUseCase getTeamByNameCacheFirstUseCase;
  final UpdateUserPhotoUseCase updateUserPhotoUseCase;
  final GetAccountCreatedAtUseCase getAccountCreatedAtUseCase;

  FanCardCubit(this.getTeamByNameCacheFirstUseCase, this.updateUserPhotoUseCase, this.getAccountCreatedAtUseCase)
      : super(const FanCardState());

  /// Sem time (ou falha ao buscar sem cache): a carteirinha usa as cores do
  /// app. Com o time no cache local, aparece na hora com as cores dele (o
  /// skeleton só fica quando não há cache).
  Future<void> load({required String favoriteTeam, String favoriteTeamId = '', bool force = false}) async {
    final memberSince = getAccountCreatedAtUseCase()?.year;
    if (favoriteTeam.trim().isEmpty && favoriteTeamId.isEmpty) {
      emit(state.copyWith(memberSince: memberSince, loading: false));
      return;
    }
    final responses = getTeamByNameCacheFirstUseCase(favoriteTeam, id: favoriteTeamId, force: force);
    await for (final response in responses) {
      if (isClosed) return;
      emit(FanCardState(
        team: response.fold((_) => null, (team) => team),
        memberSince: memberSince,
        loading: false,
        savingPhoto: state.savingPhoto,
      ));
    }
  }

  Future<void> changePhoto({required String userId, required File photo}) async {
    if (state.savingPhoto) return;
    emit(state.copyWith(savingPhoto: true));
    final response = await updateUserPhotoUseCase(userId: userId, photo: photo);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorFanCardState(state, errorMessage: failure.toString())),
      (url) => emit(PhotoSavedFanCardState(state, photoUrl: url)),
    );
  }
}
