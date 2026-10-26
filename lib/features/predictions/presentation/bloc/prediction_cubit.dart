import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/count_predictions_usecase.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/save_prediction_usecase.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/watch_my_prediction_usecase.dart';

/// Palpite da conta numa partida: o gravado (ao vivo), o rascunho do −/+ e
/// quantas pessoas palpitaram.
class PredictionState extends Equatable {
  final PredictionDTO? prediction;
  final bool loading;
  final int home;
  final int away;
  final bool saving;

  /// Gravou agora (a folha fecha).
  final bool saved;
  final int? count;
  final String? errorMessage;

  const PredictionState({
    this.prediction,
    this.loading = true,
    this.home = 0,
    this.away = 0,
    this.saving = false,
    this.saved = false,
    this.count,
    this.errorMessage,
  });

  /// O rascunho é diferente do gravado (ou ainda não há palpite).
  bool get changed => prediction == null || prediction!.home != home || prediction!.away != away;

  PredictionState copyWith({
    PredictionDTO? Function()? prediction,
    bool? loading,
    int? home,
    int? away,
    bool? saving,
    bool? saved,
    int? count,
    String? Function()? errorMessage,
  }) {
    return PredictionState(
      prediction: prediction != null ? prediction() : this.prediction,
      loading: loading ?? this.loading,
      home: home ?? this.home,
      away: away ?? this.away,
      saving: saving ?? this.saving,
      saved: saved ?? this.saved,
      count: count ?? this.count,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [prediction, loading, home, away, saving, saved, count, errorMessage];
}

class PredictionCubit extends Cubit<PredictionState> {
  final WatchMyPredictionUseCase watchMyPredictionUseCase;
  final SavePredictionUseCase savePredictionUseCase;
  final CountPredictionsUseCase countPredictionsUseCase;

  PredictionCubit(this.watchMyPredictionUseCase, this.savePredictionUseCase, this.countPredictionsUseCase)
      : super(const PredictionState());

  StreamSubscription? _subscription;
  String _matchId = '';
  String? _season;

  /// Acompanha o palpite da conta; o primeiro que chega vira o rascunho.
  void watch({required String matchId, required String uid, String? season}) {
    _matchId = matchId;
    _season = season;
    _subscription?.cancel();
    if (uid.isEmpty) {
      emit(state.copyWith(loading: false));
      return;
    }
    var first = true;
    _subscription = watchMyPredictionUseCase(matchId: matchId, uid: uid, season: season).listen((response) {
      if (isClosed) return;
      response.fold(
        (failure) => emit(state.copyWith(loading: false, errorMessage: () => failure.toString())),
        (prediction) {
          final draft = first && prediction != null;
          first = false;
          emit(state.copyWith(
            prediction: () => prediction,
            loading: false,
            home: draft ? prediction.home : null,
            away: draft ? prediction.away : null,
          ));
        },
      );
    });
  }

  Future<void> loadCount() async {
    final response = await countPredictionsUseCase(matchId: _matchId, season: _season);
    if (isClosed) return;
    response.fold((_) {}, (count) => emit(state.copyWith(count: count)));
  }

  void changeHome(int delta) => _setDraft(home: state.home + delta);

  void changeAway(int delta) => _setDraft(away: state.away + delta);

  void _setDraft({int? home, int? away}) => emit(state.copyWith(
        home: home?.clamp(0, SavePredictionUseCase.maxGoals),
        away: away?.clamp(0, SavePredictionUseCase.maxGoals),
        saved: false,
        errorMessage: () => null,
      ));

  Future<void> save({required String uid, required String name}) async {
    if (state.saving) return;
    emit(state.copyWith(saving: true, saved: false, errorMessage: () => null));
    final response = await savePredictionUseCase(
      matchId: _matchId,
      uid: uid,
      name: name,
      home: state.home,
      away: state.away,
      season: _season,
    );
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.copyWith(saving: false, errorMessage: () => failure.toString())),
      (_) => emit(state.copyWith(saving: false, saved: true)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
