import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_state.dart';

/// Elenco de um time em tempo real, com busca e ordenação. As edições do
/// admin ficam na tela do atleta.
class TeamPlayersCubit extends Cubit<TeamPlayersState> {
  final WatchTeamPlayersUseCase watchTeamPlayersUseCase;
  StreamSubscription<Either<Failure, List<PlayerDTO>>>? _subscription;

  TeamPlayersCubit(this.watchTeamPlayersUseCase) : super(const LoadingTeamPlayersState());

  void watch({required String teamName, required String season}) {
    _subscription?.cancel();
    emit(LoadingTeamPlayersState(players: state.players, sort: state.sort, query: state.query));
    _subscription = watchTeamPlayersUseCase(teamName: teamName, season: season).listen((response) {
      response.fold(
        (failure) => emit(ErrorTeamPlayersState(
          errorMessage: failure.toString(),
          players: state.players,
          sort: state.sort,
          query: state.query,
        )),
        (players) => emit(SuccessTeamPlayersState(players: players, sort: state.sort, query: state.query)),
      );
    });
  }

  void setSort(PlayersSort sort) => emit(_withView(sort: sort));

  void setQuery(String query) => emit(_withView(query: query));

  /// Mesmo estado (e tipo) com outra ordenação/busca.
  TeamPlayersState _withView({PlayersSort? sort, String? query}) {
    final s = state;
    final newSort = sort ?? s.sort;
    final newQuery = query ?? s.query;
    if (s is LoadingTeamPlayersState) {
      return LoadingTeamPlayersState(players: s.players, sort: newSort, query: newQuery);
    }
    if (s is ErrorTeamPlayersState) {
      return ErrorTeamPlayersState(errorMessage: s.errorMessage, players: s.players, sort: newSort, query: newQuery);
    }
    return SuccessTeamPlayersState(players: s.players, sort: newSort, query: newQuery);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
