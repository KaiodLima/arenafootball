import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_championships_usecase.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championships_state.dart';

/// Campeonatos da região em tempo real (aba de campeonatos e aba de tabelas).
class ChampionshipsCubit extends Cubit<ChampionshipsState> {
  final WatchChampionshipsUseCase watchChampionshipsUseCase;
  StreamSubscription<Either<Failure, List<ChampionshipDTO>>>? _subscription;

  ChampionshipsCubit(this.watchChampionshipsUseCase) : super(const LoadingChampionshipsState());

  void watch({required String region}) {
    _subscription?.cancel();
    emit(LoadingChampionshipsState(championships: state.championships));
    _subscription = watchChampionshipsUseCase(region: region).listen((response) {
      response.fold(
        (failure) => emit(ErrorChampionshipsState(
          errorMessage: failure.toString(),
          championships: state.championships,
        )),
        (championships) => emit(SuccessChampionshipsState(championships: championships)),
      );
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
