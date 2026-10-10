import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_standings_usecase.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/standings_state.dart';

/// Classificação de um grupo em tempo real.
class StandingsCubit extends Cubit<StandingsState> {
  final WatchStandingsUseCase watchStandingsUseCase;
  StreamSubscription<Either<Failure, List<StandingDTO>>>? _subscription;

  StandingsCubit(this.watchStandingsUseCase) : super(const LoadingStandingsState());

  void watch({required String region, required String group, required String season}) {
    _subscription?.cancel();
    emit(LoadingStandingsState(standings: state.standings));
    _subscription = watchStandingsUseCase(region: region, group: group, season: season).listen((response) {
      response.fold(
        (failure) => emit(ErrorStandingsState(errorMessage: failure.toString(), standings: state.standings)),
        (standings) => emit(SuccessStandingsState(standings: standings)),
      );
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
