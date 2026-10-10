import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/watch_teams_usecase.dart';
import 'package:arena_soccer/features/teams/presentation/bloc/teams_state.dart';

/// Times da região/temporada em tempo real (aba "Times" da home).
class TeamsCubit extends Cubit<TeamsState> {
  final WatchTeamsUseCase watchTeamsUseCase;
  StreamSubscription<Either<Failure, List<TeamDTO>>>? _subscription;

  TeamsCubit(this.watchTeamsUseCase) : super(const LoadingTeamsState());

  void watch({required String region, required String season}) {
    _subscription?.cancel();
    emit(LoadingTeamsState(teams: state.teams));
    _subscription = watchTeamsUseCase(region: region, season: season).listen((response) {
      response.fold(
        (failure) => emit(ErrorTeamsState(errorMessage: failure.toString(), teams: state.teams)),
        (teams) => emit(SuccessTeamsState(teams: teams)),
      );
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
