import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/delete_championship_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_championships_usecase.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/manage_championships_state.dart';

/// Lista do admin: todos os campeonatos em tempo real, filtrados pela região
/// escolhida nos chips; excluir é otimista e volta se falhar.
class ManageChampionshipsCubit extends Cubit<ManageChampionshipsState> {
  final WatchChampionshipsUseCase watchChampionshipsUseCase;
  final DeleteChampionshipUseCase deleteChampionshipUseCase;
  StreamSubscription<Either<Failure, List<ChampionshipDTO>>>? _subscription;

  ManageChampionshipsCubit(this.watchChampionshipsUseCase, this.deleteChampionshipUseCase)
      : super(const ManageChampionshipsState());

  void watch({required String region}) {
    emit(state.copyWith(region: region));
    _subscription?.cancel();
    _subscription = watchChampionshipsUseCase().listen((response) {
      response.fold(
        (failure) => emit(ErrorManageChampionshipsState(state, errorMessage: failure.toString())),
        (championships) => emit(state.copyWith(championships: championships, loading: false)),
      );
    });
  }

  void selectRegion(String region) => emit(state.copyWith(region: region));

  Future<void> delete(ChampionshipDTO championship) async {
    final before = state;
    emit(state.copyWith(championships: state.championships.where((c) => c.id != championship.id).toList()));
    final response = await deleteChampionshipUseCase(championship.id);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorManageChampionshipsState(before, errorMessage: failure.toString())),
      (_) => emit(DeletedManageChampionshipsState(state)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
