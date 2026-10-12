import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_player_goal_cards_usecase.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/delete_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/remove_player_from_squad_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/update_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_player_usecase.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_profile_state.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_stats_ranking_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

/// Tela do atleta: o jogador em tempo real, o time dele, a posição na
/// artilharia/assistências da região e os cards de gol em que participou.
/// Para o admin, edita nome, foto e números; exclui o jogador, ou, se ele
/// tem conta vinculada, só o tira do elenco.
class PlayerProfileCubit extends Cubit<PlayerProfileState> {
  final WatchPlayerUseCase watchPlayerUseCase;
  final GetTeamsUseCase getTeamsUseCase;
  final GetStatsRankingUseCase getStatsRankingUseCase;
  final GetPlayerGoalCardsUseCase getPlayerGoalCardsUseCase;
  final UpdatePlayerUseCase updatePlayerUseCase;
  final DeletePlayerUseCase deletePlayerUseCase;
  final RemovePlayerFromSquadUseCase removePlayerFromSquadUseCase;
  StreamSubscription<Either<Failure, PlayerDTO?>>? _subscription;
  String? _season;

  /// Números com que as posições foram calculadas (recalcula se mudarem).
  ({int goals, int assists, String team})? _rankedFor;

  PlayerProfileCubit(
    this.watchPlayerUseCase,
    this.getTeamsUseCase,
    this.getStatsRankingUseCase,
    this.getPlayerGoalCardsUseCase,
    this.updatePlayerUseCase,
    this.deletePlayerUseCase,
    this.removePlayerFromSquadUseCase,
  ) : super(const PlayerProfileState());

  /// [initial] (opcional) aparece enquanto o stream não chega.
  void watch({required String playerId, String? season, PlayerDTO? initial}) {
    _season = season;
    if (initial != null) emit(state.copyWith(player: initial));
    _subscription?.cancel();
    _subscription = watchPlayerUseCase(id: playerId, season: season).listen((response) {
      response.fold(
        (failure) => emit(ErrorPlayerProfileState(state, failure.toString())),
        (player) {
          if (player == null) {
            emit(state.copyWith(notFound: true));
            return;
          }
          emit(state.copyWith(player: player, notFound: false));
          _refreshTeamAndRanks(player);
        },
      );
    });
    _loadParticipations(playerId);
  }

  Future<void> _loadParticipations(String playerId) async {
    final response = await getPlayerGoalCardsUseCase(playerId);
    if (isClosed || response.isLeft) return;
    emit(state.copyWith(participations: response.right));
  }

  /// Time (para escudo e região) e posições nos rankings. Só refaz quando
  /// os números ou o time mudam.
  Future<void> _refreshTeamAndRanks(PlayerDTO player) async {
    final key = (goals: player.goals, assists: player.assists, team: player.team);
    if (_rankedFor == key) return;
    _rankedFor = key;

    // Sem time (tirado do elenco): sem escudo e fora dos rankings da região.
    if (player.team.isEmpty) {
      emit(state.copyWith(clearTeam: true, clearRanks: true));
      return;
    }

    var team = state.team;
    if (team == null || team.name != player.team) {
      final teams = await getTeamsUseCase(season: _season);
      if (isClosed) return;
      team = teams.fold((_) => null, (list) => _byName(list, player.team));
      if (team != null) emit(state.copyWith(team: team));
    }
    if (team == null || team.region.isEmpty) return;

    final goals = await getStatsRankingUseCase(type: StatsRankingType.goals, region: team.region, season: _season);
    final assists = await getStatsRankingUseCase(type: StatsRankingType.assists, region: team.region, season: _season);
    if (isClosed || _rankedFor != key) return;
    emit(state.copyWith(
      clearRanks: true,
    ).copyWith(
      goalsRank: goals.fold((_) => null, (ranking) => positionOf(ranking.entries, player.id)),
      assistsRank: assists.fold((_) => null, (ranking) => positionOf(ranking.entries, player.id)),
    ));
  }

  static TeamDTO? _byName(List<TeamDTO> teams, String name) {
    for (final team in teams) {
      if (team.name == name) return team;
    }
    return null;
  }

  /// Posição do jogador no ranking (empates dividem a posição); nulo se não
  /// está nele.
  static int? positionOf(List<RankingEntry> entries, String playerId) {
    for (final entry in entries) {
      if (entry.player.id == playerId) return entry.position;
    }
    return null;
  }

  // ---- Edição (admin) ----

  Future<void> rename(String name) {
    final player = state.player;
    if (player == null || name.trim().length < 3) return Future.value();
    return _save(player.copyWith(name: name.trim()));
  }

  Future<void> adjustGoals(int delta) {
    final player = state.player;
    if (player == null) return Future.value();
    return _save(player.copyWith(goals: max(0, player.goals + delta)));
  }

  Future<void> adjustAssists(int delta) {
    final player = state.player;
    if (player == null) return Future.value();
    return _save(player.copyWith(assists: max(0, player.assists + delta)));
  }

  Future<void> changePhoto(File image) {
    final player = state.player;
    if (player == null) return Future.value();
    return _save(player, image: image);
  }

  /// Sem foto, mostra na hora (o stream confirma); com foto, espera o envio.
  Future<void> _save(PlayerDTO updated, {File? image}) async {
    emit(state.copyWith(player: image == null ? updated : null, saving: true));
    final response = await updatePlayerUseCase(player: updated, image: image, season: _season);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorPlayerProfileState(state.copyWith(saving: false), failure.toString())),
      (saved) => emit(state.copyWith(player: saved, saving: false)),
    );
  }

  Future<void> delete() async {
    final player = state.player;
    if (player == null || state.saving) return;
    emit(state.copyWith(saving: true));
    // Sem isso, o stream avisa "não encontrado" antes do aviso de excluído.
    await _subscription?.cancel();
    _subscription = null;
    final response = await deletePlayerUseCase(player, season: _season);
    if (isClosed) return;
    response.fold(
      (failure) {
        emit(ErrorPlayerProfileState(state.copyWith(saving: false), failure.toString()));
        // Volta a acompanhar o jogador, que continua existindo.
        watch(playerId: player.id, season: _season, initial: player);
      },
      (_) => emit(DeletedPlayerProfileState(name: player.name, teamName: player.team)),
    );
  }

  /// Só para jogador com conta vinculada; o stream mostra ele sem time.
  Future<void> removeFromSquad() async {
    final player = state.player;
    if (player == null || state.saving || player.team.isEmpty) return;
    emit(state.copyWith(saving: true));
    final response = await removePlayerFromSquadUseCase(player, season: _season);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorPlayerProfileState(state.copyWith(saving: false), failure.toString())),
      (_) => emit(RemovedFromSquadPlayerProfileState(
        state.copyWith(saving: false),
        name: player.name,
        teamName: player.team,
      )),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
