import 'dart:async';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_cache_first_usecase.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/approve_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/reject_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/watch_team_player_requests_usecase.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/create_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/my_team_state.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_team_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/update_team_details_usecase.dart';

/// Área do dono aprovado: elenco do time em tempo real, pedidos "Sou jogador"
/// para o time (aprovar/rejeitar), jogador novo e edição do escudo/descrição.
/// O que o dono pode gravar é garantido pelas regras do Firestore.
class MyTeamCubit extends Cubit<MyTeamState> {
  final GetTeamUseCase getTeamUseCase;
  final UpdateTeamDetailsUseCase updateTeamDetailsUseCase;
  final WatchTeamPlayersUseCase watchTeamPlayersUseCase;
  final WatchTeamPlayerRequestsUseCase watchTeamPlayerRequestsUseCase;
  final ApprovePlayerRequestUseCase approvePlayerRequestUseCase;
  final RejectPlayerRequestUseCase rejectPlayerRequestUseCase;
  final CreatePlayerUseCase createPlayerUseCase;
  final GetRegionChampionshipsCacheFirstUseCase? getRegionChampionshipsCacheFirstUseCase;

  StreamSubscription<Either<Failure, List<PlayerDTO>>>? _players;
  StreamSubscription<Either<Failure, List<PlayerRequestDTO>>>? _requests;

  MyTeamCubit(
    this.getTeamUseCase,
    this.updateTeamDetailsUseCase,
    this.watchTeamPlayersUseCase,
    this.watchTeamPlayerRequestsUseCase,
    this.approvePlayerRequestUseCase,
    this.rejectPlayerRequestUseCase,
    this.createPlayerUseCase, [
    this.getRegionChampionshipsCacheFirstUseCase,
  ]) : super(const MyTeamState());

  /// [teamId]/[teamName] vêm do pedido aprovado. Sem o time na temporada
  /// atual (ex.: temporada nova sem cópia), mostra só o nome.
  Future<void> load({required String teamId, required String teamName}) async {
    final fallback = TeamDTO(id: teamId, name: teamName);
    emit(state.copyWith(team: fallback, loading: true));

    _players?.cancel();
    _players = watchTeamPlayersUseCase(teamId: teamId, teamName: teamName).listen((response) {
      response.fold(
        (failure) => emit(ErrorMyTeamState(state, errorMessage: failure.toString())),
        (players) => emit(state.copyWith(players: [...players]..sort((a, b) => a.name.compareTo(b.name)))),
      );
    });
    _requests?.cancel();
    _requests = watchTeamPlayerRequestsUseCase(teamId: teamId, teamName: teamName).listen((response) {
      response.fold(
        (failure) => emit(ErrorMyTeamState(state, errorMessage: failure.toString())),
        (requests) => emit(state.copyWith(requests: requests)),
      );
    });

    final team = await getTeamUseCase(teamId);
    if (isClosed) return;
    final loaded = team.fold((_) => null, (t) => t) ?? fallback;
    emit(state.copyWith(team: loaded, loading: false));
    await _loadChampionships(loaded);
  }

  /// Competições da temporada atual que o time joga.
  Future<void> _loadChampionships(TeamDTO team) async {
    final useCase = getRegionChampionshipsCacheFirstUseCase;
    if (useCase == null || team.region.isEmpty) return;
    await for (final response in useCase(region: team.region, season: SeasonCollection.currentSeason)) {
      if (isClosed) return;
      if (response.isLeft) continue;
      final mine = response.right.where((c) => c.hasTeam(id: team.id, name: team.name)).toList()
        ..sort((a, b) => a.championshipId.compareTo(b.championshipId));
      emit(state.copyWith(championships: mine));
    }
  }

  Future<void> saveDetails({
    required String description,
    required String primaryColor,
    required String secondaryColor,
    File? crest,
  }) async {
    final team = state.team;
    if (team == null || state.saving) return;
    emit(state.copyWith(saving: true));
    final response = await updateTeamDetailsUseCase(
      team.copyWith(description: description, primaryColor: primaryColor, secondaryColor: secondaryColor),
      crest: crest,
    );
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorMyTeamState(state, errorMessage: failure.toString())),
      (updated) => emit(MyTeamNoticeState(state.copyWith(team: updated, saving: false), notice: MyTeamNotice.saved)),
    );
  }

  /// Jogador cadastrado pelo dono, sempre no time dele (inscrito na
  /// competição [championshipId], quando o time joga alguma).
  Future<void> addPlayer({required String name, String position = '', File? photo, int? championshipId}) async {
    final team = state.team;
    if (team == null || state.saving || name.trim().length < 3) return;
    emit(state.copyWith(saving: true));
    final response = await createPlayerUseCase(
      PlayerDTO(
        name: name,
        team: team.name,
        teamId: team.id,
        position: position,
        enrollments: [
          if (championshipId != null)
            PlayerEnrollment(championshipId: championshipId, teamId: team.id, team: team.name),
        ],
      ),
      photo: photo,
    );
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorMyTeamState(state, errorMessage: failure.toString())),
      (player) => emit(MyTeamNoticeState(
        state.copyWith(saving: false),
        notice: MyTeamNotice.playerAdded,
        name: player.name,
      )),
    );
  }

  void _setBusy(String userId, bool busy) {
    final ids = {...state.busy};
    busy ? ids.add(userId) : ids.remove(userId);
    emit(state.copyWith(busy: ids));
  }

  Future<void> approve(PlayerRequestDTO request) async {
    _setBusy(request.userId, true);
    final response = await approvePlayerRequestUseCase(request);
    if (isClosed) return;
    _setBusy(request.userId, false);
    response.fold(
      (failure) => emit(ErrorMyTeamState(state, errorMessage: failure.toString())),
      (_) => emit(MyTeamNoticeState(state, notice: MyTeamNotice.requestApproved, name: request.name)),
    );
  }

  Future<void> reject(PlayerRequestDTO request, {String reason = ''}) async {
    _setBusy(request.userId, true);
    final response = await rejectPlayerRequestUseCase(userId: request.userId, reason: reason);
    if (isClosed) return;
    _setBusy(request.userId, false);
    response.fold(
      (failure) => emit(ErrorMyTeamState(state, errorMessage: failure.toString())),
      (_) => emit(MyTeamNoticeState(state, notice: MyTeamNotice.requestRejected, name: request.name)),
    );
  }

  @override
  Future<void> close() {
    _players?.cancel();
    _requests?.cancel();
    return super.close();
  }
}
