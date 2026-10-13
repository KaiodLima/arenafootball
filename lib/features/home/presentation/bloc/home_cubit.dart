import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/home/presentation/bloc/home_state.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/watch_pending_player_requests_count_usecase.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/watch_pending_team_requests_count_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_team_by_name_usecase.dart';

class HomeCubit extends Cubit<HomeState> {
  final GetTeamByNameUseCase getTeamByNameUseCase;
  final WatchPendingPlayerRequestsCountUseCase watchPendingPlayerRequestsCountUseCase;
  final WatchPendingTeamRequestsCountUseCase watchPendingTeamRequestsCountUseCase;
  StreamSubscription<Either<Failure, int>>? _pendingRequests;
  StreamSubscription<Either<Failure, int>>? _pendingTeamRequests;

  HomeCubit(
    this.getTeamByNameUseCase,
    this.watchPendingPlayerRequestsCountUseCase,
    this.watchPendingTeamRequestsCountUseCase,
  ) : super(const HomeState());

  void selectTab(HomeTab tab) => emit(state.copyWith(tab: tab));

  Future<void> loadFavoriteTeam(String teamName, {String teamId = ''}) async {
    if (teamName.isEmpty && teamId.isEmpty) return;
    final response = await getTeamByNameUseCase(teamName, id: teamId);
    response.fold(
      // O escudo é só decorativo; sem ele o drawer mostra o avatar vazio.
      (_) => null,
      (team) {
        if (team != null && team.imageUrl.isNotEmpty) emit(state.copyWith(favoriteTeamImage: team.imageUrl));
      },
    );
  }

  /// Contador do menu do admin. Falha só deixa o contador como está.
  void watchPendingPlayerRequests() {
    _pendingRequests?.cancel();
    _pendingRequests = watchPendingPlayerRequestsCountUseCase().listen((response) {
      if (response.isRight) emit(state.copyWith(pendingPlayerRequests: response.right));
    });
    _pendingTeamRequests?.cancel();
    _pendingTeamRequests = watchPendingTeamRequestsCountUseCase().listen((response) {
      if (response.isRight) emit(state.copyWith(pendingTeamRequests: response.right));
    });
  }

  @override
  Future<void> close() {
    _pendingRequests?.cancel();
    _pendingTeamRequests?.cancel();
    return super.close();
  }
}
