import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_progress_dto.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_board.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/mark_achievement_seen_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/record_achievement_action_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/record_daily_visit_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/watch_achievement_progress_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/watch_achievement_unlocks_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/watch_achievements_catalog_usecase.dart';

class AchievementsState extends Equatable {
  final List<AchievementDTO> catalog;
  final AchievementProgressDTO progress;

  /// Números calculados no app (time do coração, foto, atleta, dono) até o
  /// servidor gravar os dele.
  final Map<AchievementMetric, int> derived;
  final Map<String, AchievementUnlockDTO> unlocks;
  final bool loading;

  const AchievementsState({
    this.catalog = const [],
    this.progress = const AchievementProgressDTO(),
    this.derived = const {},
    this.unlocks = const {},
    this.loading = true,
  });

  AchievementBoard get board =>
      AchievementBoard.of(catalog: catalog, progress: progress.withDerived(derived), unlocks: unlocks);

  /// Desbloqueadas pelo servidor que o usuário ainda não viu (comemoração).
  List<AchievementDTO> get unseen => [
        for (final achievement in catalog)
          if (achievement.active && (unlocks[achievement.id]?.seen == false)) achievement,
      ];

  AchievementsState copyWith({
    List<AchievementDTO>? catalog,
    AchievementProgressDTO? progress,
    Map<AchievementMetric, int>? derived,
    Map<String, AchievementUnlockDTO>? unlocks,
    bool? loading,
  }) {
    return AchievementsState(
      catalog: catalog ?? this.catalog,
      progress: progress ?? this.progress,
      derived: derived ?? this.derived,
      unlocks: unlocks ?? this.unlocks,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [catalog, progress, derived, unlocks, loading];
}

/// Conquistas da conta logada (global): catálogo, contadores e desbloqueios
/// ao vivo, o registro do dia de uso e das ações contadas no app.
class AchievementsCubit extends Cubit<AchievementsState> {
  final WatchAchievementsCatalogUseCase watchCatalogUseCase;
  final WatchAchievementProgressUseCase watchProgressUseCase;
  final WatchAchievementUnlocksUseCase watchUnlocksUseCase;
  final RecordAchievementActionUseCase recordActionUseCase;
  final RecordDailyVisitUseCase recordDailyVisitUseCase;
  final MarkAchievementSeenUseCase markSeenUseCase;

  final List<StreamSubscription> _subscriptions = [];
  String _uid = '';
  bool _visitRecorded = false;

  AchievementsCubit(
    this.watchCatalogUseCase,
    this.watchProgressUseCase,
    this.watchUnlocksUseCase,
    this.recordActionUseCase,
    this.recordDailyVisitUseCase,
    this.markSeenUseCase,
  ) : super(const AchievementsState());

  /// Segue a conta [uid] (nulo = saiu: limpa tudo).
  void follow(String? uid) {
    if ((uid ?? '') == _uid) return;
    _cancel();
    _uid = uid ?? '';
    _visitRecorded = false;
    emit(AchievementsState(loading: _uid.isNotEmpty, derived: state.derived));
    if (_uid.isEmpty) return;

    final uidNow = _uid;
    void onError(Failure failure) {
      // Conquistas são extra: sem elas a tela mostra o que tiver.
      if (!isClosed && _uid == uidNow) emit(state.copyWith(loading: false));
    }

    _subscriptions
      ..add(watchCatalogUseCase().listen((response) {
        if (isClosed || _uid != uidNow) return;
        response.fold(onError, (catalog) => emit(state.copyWith(catalog: catalog, loading: false)));
      }))
      ..add(watchProgressUseCase(uidNow).listen((response) {
        if (isClosed || _uid != uidNow) return;
        response.fold(onError, (progress) {
          emit(state.copyWith(progress: progress));
          _recordVisit(progress);
        });
      }))
      ..add(watchUnlocksUseCase(uidNow).listen((response) {
        if (isClosed || _uid != uidNow) return;
        response.fold(
          onError,
          (list) => emit(state.copyWith(unlocks: {for (final unlock in list) unlock.achievementId: unlock})),
        );
      }));
  }

  /// Uma vez por sessão, com os contadores já lidos: registra o dia de uso.
  Future<void> _recordVisit(AchievementProgressDTO progress) async {
    if (_visitRecorded) return;
    _visitRecorded = true;
    await recordDailyVisitUseCase(_uid, progress);
  }

  /// Números calculados no app a partir da conta, do atleta e do time do dono.
  void updateDerived(Map<AchievementMetric, int> derived) {
    if (derived.length == state.derived.length && derived.entries.every((e) => state.derived[e.key] == e.value)) {
      return;
    }
    emit(state.copyWith(derived: derived));
  }

  /// Soma 1 numa ação contada no app (compartilhar, ler notícia).
  Future<Either<Failure, void>> record(AchievementMetric metric) => recordActionUseCase(_uid, metric);

  Future<void> markSeen(String achievementId) async {
    if (_uid.isEmpty) return;
    await markSeenUseCase(_uid, achievementId);
  }

  void _cancel() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  @override
  Future<void> close() {
    _cancel();
    return super.close();
  }
}
