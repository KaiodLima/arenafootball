import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/update_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_state.dart';

/// Elenco de um time em tempo real + edições do admin (nome, foto, gols e
/// assistências).
class TeamPlayersCubit extends Cubit<TeamPlayersState> {
  final WatchTeamPlayersUseCase watchTeamPlayersUseCase;
  final UpdatePlayerUseCase updatePlayerUseCase;
  StreamSubscription<Either<Failure, List<PlayerDTO>>>? _subscription;
  String? _season;

  TeamPlayersCubit(this.watchTeamPlayersUseCase, this.updatePlayerUseCase) : super(const LoadingTeamPlayersState());

  void watch({required String teamName, required String season}) {
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
    if (s is SavingTeamPlayersState) {
      return SavingTeamPlayersState(playerId: s.playerId, players: s.players, sort: newSort, query: newQuery);
    }
    if (s is ErrorTeamPlayersState) {
      return ErrorTeamPlayersState(errorMessage: s.errorMessage, players: s.players, sort: newSort, query: newQuery);
    }
    return SuccessTeamPlayersState(players: s.players, sort: newSort, query: newQuery);
  }

  /// Soma [delta] aos gols (nunca abaixo de zero).
  Future<void> changeGoals(PlayerDTO player, int delta) {
    final current = state.playerById(player.id, player);
    return _save(current.copyWith(goals: max(0, current.goals + delta)));
  }

  /// Soma [delta] às assistências (nunca abaixo de zero).
  Future<void> changeAssists(PlayerDTO player, int delta) {
    final current = state.playerById(player.id, player);
    return _save(current.copyWith(assists: max(0, current.assists + delta)));
  }

  Future<void> rename(PlayerDTO player, String name) {
    final current = state.playerById(player.id, player);
    return _save(current.copyWith(name: name.trim()));
  }

  Future<void> changePhoto(PlayerDTO player, File image) async {
    final current = state.playerById(player.id, player);
    emit(SavingTeamPlayersState(playerId: current.id, players: state.players, sort: state.sort, query: state.query));
    await _save(current, image: image);
  }

  /// Sem foto, atualiza a lista na hora (o stream confirma depois); com foto,
  /// espera o upload. Grava o documento inteiro, como o app antigo.
  Future<void> _save(PlayerDTO updated, {File? image}) async {
    if (image == null) emit(SuccessTeamPlayersState(players: _replace(updated), sort: state.sort, query: state.query));
    final response = await updatePlayerUseCase(player: updated, image: image, season: _season);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorTeamPlayersState(
        errorMessage: failure.toString(),
        players: state.players,
        sort: state.sort,
        query: state.query,
      )),
      (saved) => emit(SuccessTeamPlayersState(players: _replace(saved), sort: state.sort, query: state.query)),
    );
  }

  List<PlayerDTO> _replace(PlayerDTO updated) =>
      state.players.map((player) => player.id == updated.id ? updated : player).toList();

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
