import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/watch_highlights_usecase.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlights_state.dart';

/// Carrossel de destaques da home.
class HighlightsCubit extends Cubit<HighlightsState> {
  final WatchHighlightsUseCase watchHighlightsUseCase;
  StreamSubscription<Either<Failure, List<HighlightDTO>>>? _subscription;

  HighlightsCubit(this.watchHighlightsUseCase) : super(const LoadingHighlightsState());

  void watch() {
    _subscription?.cancel();
    emit(LoadingHighlightsState(highlights: state.highlights));
    _subscription = watchHighlightsUseCase().listen((response) {
      response.fold(
        (failure) => emit(ErrorHighlightsState(errorMessage: failure.toString(), highlights: state.highlights)),
        (highlights) => emit(SuccessHighlightsState(highlights: highlights)),
      );
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
