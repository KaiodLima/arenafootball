import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/maintenance/data/dtos/recompress_status_dto.dart';
import 'package:arena_soccer/features/maintenance/domain/usecases/recompress_images_usecase.dart';
import 'package:arena_soccer/features/maintenance/presentation/bloc/recompress_images_state.dart';

/// Tela "Recomprimir imagens antigas": progresso ao vivo e o pedido.
class RecompressImagesCubit extends Cubit<RecompressImagesState> {
  final RecompressImagesUseCase recompressImagesUseCase;
  StreamSubscription<Either<Failure, RecompressStatusDTO>>? _subscription;

  RecompressImagesCubit(this.recompressImagesUseCase) : super(const RecompressImagesState());

  void watch() {
    _subscription?.cancel();
    _subscription = recompressImagesUseCase.watch().listen((response) {
      if (isClosed) return;
      response.fold(
        (failure) => emit(ErrorRecompressImagesState(state, failure.toString())),
        (status) => emit(state.copyWith(status: status, loading: false)),
      );
    });
  }

  Future<void> request() async {
    if (state.status.isRunning || state.requesting) return;
    emit(state.copyWith(requesting: true));
    final response = await recompressImagesUseCase.request();
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorRecompressImagesState(state.copyWith(requesting: false), failure.toString())),
      (_) => emit(state.copyWith(requesting: false)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
