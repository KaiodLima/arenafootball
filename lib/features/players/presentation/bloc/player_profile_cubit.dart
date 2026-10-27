import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/players/domain/usecases/assign_unassigned_stats_usecase.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_player_goal_cards_cache_first_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_cache_first_usecase.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/adjust_player_stats_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/delete_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/remove_player_from_squad_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/update_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_player_usecase.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_profile_state.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_stats_ranking_cache_first_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

/// Tela do atleta: o jogador em tempo real, o time dele, a posição na
/// artilharia/assistências da região e os cards de gol em que participou.
/// Para o admin, edita nome, foto e números; exclui o jogador, ou, se ele
/// tem conta vinculada, só o tira do elenco.
class PlayerProfileCubit extends Cubit<PlayerProfileState> {
  final WatchPlayerUseCase watchPlayerUseCase;
  final GetTeamsCacheFirstUseCase getTeamsCacheFirstUseCase;
  final GetStatsRankingCacheFirstUseCase getStatsRankingCacheFirstUseCase;
  final GetPlayerGoalCardsCacheFirstUseCase getPlayerGoalCardsCacheFirstUseCase;
  final UpdatePlayerUseCase updatePlayerUseCase;
  final DeletePlayerUseCase deletePlayerUseCase;
  final RemovePlayerFromSquadUseCase removePlayerFromSquadUseCase;
  final AdjustPlayerStatsUseCase adjustPlayerStatsUseCase;
  final AssignUnassignedStatsUseCase assignUnassignedStatsUseCase;
  final GetRegionChampionshipsCacheFirstUseCase getRegionChampionshipsCacheFirstUseCase;
  StreamSubscription<Either<Failure, PlayerDTO?>>? _subscription;
  String? _season;

  /// Números com que as posições foram calculadas (recalcula se mudarem).
  ({int goals, int assists, String team, String teamId})? _rankedFor;

  PlayerProfileCubit(
    this.watchPlayerUseCase,
    this.getTeamsCacheFirstUseCase,
    this.getStatsRankingCacheFirstUseCase,
    this.getPlayerGoalCardsCacheFirstUseCase,
    this.updatePlayerUseCase,
    this.deletePlayerUseCase,
    this.removePlayerFromSquadUseCase,
    this.adjustPlayerStatsUseCase,
    this.assignUnassignedStatsUseCase,
    this.getRegionChampionshipsCacheFirstUseCase,
  ) : super(const PlayerProfileState());

  /// Região cujas competições já foram carregadas.
  String? _championshipsRegion;

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
    await for (final response in getPlayerGoalCardsCacheFirstUseCase(playerId)) {
      if (isClosed) return;
      if (response.isRight) emit(state.copyWith(participations: response.right));
    }
  }

  /// Time (para escudo e região) e posições nos rankings. Só refaz quando
  /// os números ou o time mudam.
  Future<void> _refreshTeamAndRanks(PlayerDTO player) async {
    final key = (goals: player.goals, assists: player.assists, team: player.team, teamId: player.teamId);
    if (_rankedFor == key) return;
    _rankedFor = key;

    // Sem time (tirado do elenco): sem escudo e fora dos rankings da região.
    if (player.team.isEmpty) {
      emit(state.copyWith(clearTeam: true, clearRanks: true));
      return;
    }

    var team = state.team;
    if (team == null || !sameTeam(idA: team.id, nameA: team.name, idB: player.teamId, nameB: player.team)) {
      // Cache-first: fica com a última emissão (o remoto quando revalidou).
      final teams = await getTeamsCacheFirstUseCase(season: _season).last;
      if (isClosed) return;
      team = teams.fold((_) => null, (list) => TeamDirectory(list).resolve(id: player.teamId, name: player.team));
      emit(state.copyWith(team: team, teams: teams.fold((_) => null, (list) => list)));
    }
    if (team == null || team.region.isEmpty) return;
    unawaited(_loadChampionships(team.region));

    // Rankings pelo cache local: a última emissão (o remoto quando revalidou).
    final goals =
        await getStatsRankingCacheFirstUseCase(type: StatsRankingType.goals, region: team.region, season: _season).last;
    final assists =
        await getStatsRankingCacheFirstUseCase(type: StatsRankingType.assists, region: team.region, season: _season)
            .last;
    if (isClosed || _rankedFor != key) return;
    emit(state
        .copyWith(
          clearRanks: true,
        )
        .copyWith(
          goalsRank: goals.fold((_) => null, (ranking) => positionOf(ranking.entries, player.id)),
          assistsRank: assists.fold((_) => null, (ranking) => positionOf(ranking.entries, player.id)),
        ));
  }

  /// Competições da região (nome de cada inscrição), uma vez por região.
  Future<void> _loadChampionships(String region) async {
    if (_championshipsRegion == region) return;
    _championshipsRegion = region;
    await for (final response in getRegionChampionshipsCacheFirstUseCase(region: region, season: _season ?? '')) {
      if (isClosed) return;
      if (response.isRight) emit(state.copyWith(championships: response.right));
    }
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

  /// Com [championshipId], ajusta a competição (e o Geral junto);
  /// [PlayerDTO.friendlyId], os amistosos (à parte). Sem ela, o Geral só do
  /// atleta antigo: com inscrições, o Geral é a soma das competições e não se
  /// ajusta direto.
  Future<void> adjustGoals(int delta, {int? championshipId}) {
    final player = state.player;
    if (player == null) return Future.value();
    if (championshipId == PlayerDTO.friendlyId) return _adjustFriendly(player, goals: delta);
    if (championshipId != null) return _adjustIn(player, championshipId, goals: delta);
    if (!player.isLegacy) return Future.value();
    return _save(player.copyWith(goals: max(0, player.goals + delta)));
  }

  Future<void> adjustAssists(int delta, {int? championshipId}) {
    final player = state.player;
    if (player == null) return Future.value();
    if (championshipId == PlayerDTO.friendlyId) return _adjustFriendly(player, assists: delta);
    if (championshipId != null) return _adjustIn(player, championshipId, assists: delta);
    if (!player.isLegacy) return Future.value();
    return _save(player.copyWith(assists: max(0, player.assists + delta)));
  }

  /// Admin atribui os números "Sem competição" à competição [championshipId]
  /// do atleta ou, com [PlayerDTO.friendlyId], aos amistosos.
  Future<void> assignUnassigned({required int championshipId, int goals = 0, int assists = 0}) async {
    final player = state.player;
    if (player == null) return;
    final friendly = championshipId == PlayerDTO.friendlyId;
    final enrollment = friendly ? null : player.enrollmentIn(championshipId);
    if (!friendly && enrollment == null) return;
    emit(state.copyWith(saving: true));
    final response = await assignUnassignedStatsUseCase(
      player,
      goals: goals,
      assists: assists,
      enrollment: enrollment,
      season: _season,
    );
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorPlayerProfileState(state.copyWith(saving: false), failure.toString())),
      (_) => emit(state.copyWith(saving: false)),
    );
  }

  /// Ajuste atômico nos amistosos (sem ficar negativo); mostra na hora.
  Future<void> _adjustFriendly(PlayerDTO player, {int goals = 0, int assists = 0}) async {
    final goalsDelta = goals < 0 && -goals > player.friendlyGoals ? -player.friendlyGoals : goals;
    final assistsDelta = assists < 0 && -assists > player.friendlyAssists ? -player.friendlyAssists : assists;
    if (goalsDelta == 0 && assistsDelta == 0) return;
    emit(state.copyWith(
      player: player.copyWith(
        friendlyGoals: player.friendlyGoals + goalsDelta,
        friendlyAssists: player.friendlyAssists + assistsDelta,
      ),
      saving: true,
    ));
    final response = await adjustPlayerStatsUseCase.friendly(
      player,
      goals: goalsDelta,
      assists: assistsDelta,
      season: _season,
    );
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorPlayerProfileState(state.copyWith(player: player, saving: false), failure.toString())),
      (_) => emit(state.copyWith(saving: false)),
    );
  }

  /// Ajuste atômico na competição; mostra na hora (o stream confirma).
  Future<void> _adjustIn(PlayerDTO player, int championshipId, {int goals = 0, int assists = 0}) async {
    final enrollment = player.enrollmentIn(championshipId);
    if (enrollment == null) return;
    final goalsDelta =
        AdjustPlayerStatsUseCase.clampDelta(goals, inChampionship: enrollment.goals, total: player.goals);
    final assistsDelta =
        AdjustPlayerStatsUseCase.clampDelta(assists, inChampionship: enrollment.assists, total: player.assists);
    if (goalsDelta == 0 && assistsDelta == 0) return;
    final updated = player.copyWith(
      goals: player.goals + goalsDelta,
      assists: player.assists + assistsDelta,
      enrollments: [
        for (final e in player.enrollments)
          e.championshipId == championshipId
              ? e.copyWith(goals: e.goals + goalsDelta, assists: e.assists + assistsDelta)
              : e,
      ],
    );
    emit(state.copyWith(player: updated, saving: true));
    final response = await adjustPlayerStatsUseCase(
      player,
      enrollment,
      goals: goalsDelta,
      assists: assistsDelta,
      season: _season,
    );
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorPlayerProfileState(state.copyWith(player: player, saving: false), failure.toString())),
      (_) => emit(state.copyWith(saving: false)),
    );
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

  /// Só para jogador com conta vinculada. Com [championshipId], sai só da
  /// competição; o stream mostra o resultado.
  Future<void> removeFromSquad({int? championshipId}) async {
    final player = state.player;
    if (player == null || state.saving || player.team.isEmpty) return;
    emit(state.copyWith(saving: true));
    final enrollment = championshipId == null ? null : player.enrollmentIn(championshipId);
    final response = await removePlayerFromSquadUseCase(player, championshipId: championshipId, season: _season);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorPlayerProfileState(state.copyWith(saving: false), failure.toString())),
      (_) => emit(RemovedFromSquadPlayerProfileState(
        state.copyWith(saving: false),
        name: player.name,
        teamName: enrollment?.team ?? player.team,
      )),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
