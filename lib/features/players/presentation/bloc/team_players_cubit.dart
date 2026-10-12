import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_state.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/delete_team_usecase.dart';

/// Elenco de um time em tempo real, com busca e ordenação. As edições do
/// admin ficam na tela do atleta; aqui o admin pode excluir o time.
class TeamPlayersCubit extends Cubit<TeamPlayersState> {
  final WatchTeamPlayersUseCase watchTeamPlayersUseCase;
  final DeleteTeamUseCase deleteTeamUseCase;
  StreamSubscription<Either<Failure, List<PlayerDTO>>>? _subscription;
  String? _teamName;
  String? _season;

  TeamPlayersCubit(this.watchTeamPlayersUseCase, this.deleteTeamUseCase) : super(const LoadingTeamPlayersState());

  void watch({required String teamName, required String season}) {
    _teamName = teamName;
    _season = season;
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

  Future<void> deleteTeam(TeamDTO team) async {
    if (state is DeletingTeamPlayersState) return;
    final before = state;
    // Sem isso, o elenco esvaziando aparece na tela antes do aviso.
    await _subscription?.cancel();
    _subscription = null;
    emit(DeletingTeamPlayersState(players: before.players, sort: before.sort, query: before.query));
    final response = await deleteTeamUseCase(team, season: _season);
    if (isClosed) return;
    response.fold(
      (failure) {
        emit(ErrorTeamPlayersState(
          errorMessage: failure.toString(),
          players: before.players,
          sort: before.sort,
          query: before.query,
        ));
        // O time continua existindo: volta a acompanhar o elenco.
        if (_teamName != null && _season != null) watch(teamName: _teamName!, season: _season!);
      },
      (_) => emit(DeletedTeamPlayersState(teamName: team.name)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
