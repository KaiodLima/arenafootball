import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/create_suggested_achievements_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/delete_achievement_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/save_achievement_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/watch_achievements_catalog_usecase.dart';

class ManageAchievementsState extends Equatable {
  final List<AchievementDTO> achievements;
  final bool loading;
  final bool working;

  /// Mensagem de sucesso a mostrar uma vez (ex.: sugeridas criadas).
  final String? notice;
  final String? errorMessage;

  const ManageAchievementsState({
    this.achievements = const [],
    this.loading = true,
    this.working = false,
    this.notice,
    this.errorMessage,
  });

  /// Próxima posição na ordem (cadastro novo vai para o fim).
  int get nextOrder => achievements.fold(0, (max, a) => a.order >= max ? a.order + 1 : max);

  ManageAchievementsState copyWith({
    List<AchievementDTO>? achievements,
    bool? loading,
    bool? working,
    String? Function()? notice,
    String? Function()? errorMessage,
  }) {
    return ManageAchievementsState(
      achievements: achievements ?? this.achievements,
      loading: loading ?? this.loading,
      working: working ?? this.working,
      notice: notice != null ? notice() : this.notice,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [achievements, loading, working, notice, errorMessage];
}

/// Admin: lista de conquistas (ativas e inativas), ativar/desativar, excluir
/// e criar as sugeridas.
class ManageAchievementsCubit extends Cubit<ManageAchievementsState> {
  final WatchAchievementsCatalogUseCase watchCatalogUseCase;
  final SaveAchievementUseCase saveAchievementUseCase;
  final DeleteAchievementUseCase deleteAchievementUseCase;
  final CreateSuggestedAchievementsUseCase createSuggestedUseCase;
  StreamSubscription? _subscription;

  ManageAchievementsCubit(
    this.watchCatalogUseCase,
    this.saveAchievementUseCase,
    this.deleteAchievementUseCase,
    this.createSuggestedUseCase,
  ) : super(const ManageAchievementsState());

  void watch() {
    _subscription?.cancel();
    _subscription = watchCatalogUseCase().listen((response) {
      if (isClosed) return;
      response.fold(
        (failure) => emit(state.copyWith(loading: false, errorMessage: () => failure.toString())),
        (list) {
          final sorted = [...list]..sort((a, b) {
              final byOrder = a.order.compareTo(b.order);
              return byOrder != 0 ? byOrder : a.title.toLowerCase().compareTo(b.title.toLowerCase());
            });
          emit(state.copyWith(achievements: sorted, loading: false));
        },
      );
    });
  }

  Future<void> setActive(AchievementDTO achievement, bool active) async {
    final response = await saveAchievementUseCase(achievement.copyWith(active: active));
    if (isClosed) return;
    response.fold((failure) => emit(state.copyWith(errorMessage: () => failure.toString())), (_) {});
  }

  Future<void> delete(AchievementDTO achievement, {required String notice}) => _run(
        () => deleteAchievementUseCase(achievement.id),
        notice,
      );

  Future<void> createSuggested({required String notice}) => _run(createSuggestedUseCase.call, notice);

  Future<void> _run(Future<dynamic> Function() action, String notice) async {
    if (state.working) return;
    emit(state.copyWith(working: true, notice: () => null, errorMessage: () => null));
    final response = await action();
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(working: false, errorMessage: () => failure.toString())),
      (_) => emit(state.copyWith(working: false, notice: () => notice)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
