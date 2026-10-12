import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/approve_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/reject_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/update_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/watch_player_requests_usecase.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/player_requests_panel_state.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/get_players_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

/// Painel do admin: pedidos "Sou jogador" em tempo real; aprovar (cria o
/// jogador), rejeitar (com motivo) ou editar antes de responder.
class PlayerRequestsPanelCubit extends Cubit<PlayerRequestsPanelState> {
  final WatchPlayerRequestsUseCase watchPlayerRequestsUseCase;
  final ApprovePlayerRequestUseCase approvePlayerRequestUseCase;
  final RejectPlayerRequestUseCase rejectPlayerRequestUseCase;
  final UpdatePlayerRequestUseCase updatePlayerRequestUseCase;
  final GetTeamsUseCase getTeamsUseCase;
  final GetPlayersUseCase getPlayersUseCase;
  StreamSubscription<Either<Failure, List<PlayerRequestDTO>>>? _subscription;

  PlayerRequestsPanelCubit(
    this.watchPlayerRequestsUseCase,
    this.approvePlayerRequestUseCase,
    this.rejectPlayerRequestUseCase,
    this.updatePlayerRequestUseCase,
    this.getTeamsUseCase,
    this.getPlayersUseCase,
  ) : super(const LoadingPlayerRequestsPanelState());

  void watch() {
    _subscription?.cancel();
    _subscription = watchPlayerRequestsUseCase().listen((response) {
      response.fold(
        (failure) => emit(ErrorPlayerRequestsPanelState(state, errorMessage: failure.toString())),
        (requests) => emit(_ready(requests: requests)),
      );
    });
    _loadReferences();
  }

  /// Escudos e elenco: só enfeitam os cards, então uma falha aqui não trava o painel.
  Future<void> _loadReferences() async {
    final teams = await getTeamsUseCase();
    final players = await getPlayersUseCase();
    if (isClosed) return;
    emit(_ready(
      teams: teams.isRight ? teams.right : null,
      players: players.isRight ? players.right : null,
    ));
  }

  ReadyPlayerRequestsPanelState _ready({
    List<PlayerRequestDTO>? requests,
    List<TeamDTO>? teams,
    List<PlayerDTO>? players,
    Set<String>? busy,
  }) {
    return ReadyPlayerRequestsPanelState(
      requests: requests ?? state.requests,
      teams: teams ?? state.teams,
      players: players ?? state.players,
      busy: busy ?? state.busy,
    );
  }

  void _setBusy(String userId, bool busy) {
    final ids = {...state.busy};
    busy ? ids.add(userId) : ids.remove(userId);
    emit(_ready(busy: ids));
  }

  Future<void> approve(PlayerRequestDTO request) async {
    _setBusy(request.userId, true);
    final response = await approvePlayerRequestUseCase(request);
    if (isClosed) return;
    _setBusy(request.userId, false);
    response.fold(
      (failure) => emit(ErrorPlayerRequestsPanelState(state, errorMessage: failure.toString())),
      (_) => emit(ApprovedPlayerRequestsPanelState(state, name: request.name, team: request.team)),
    );
    // O novo jogador entra no aviso de nome repetido.
    if (response.isRight) _loadReferences();
  }

  Future<void> reject(PlayerRequestDTO request, {String reason = ''}) async {
    _setBusy(request.userId, true);
    final response = await rejectPlayerRequestUseCase(userId: request.userId, reason: reason);
    if (isClosed) return;
    _setBusy(request.userId, false);
    response.fold(
      (failure) => emit(ErrorPlayerRequestsPanelState(state, errorMessage: failure.toString())),
      (_) => emit(RejectedPlayerRequestsPanelState(state)),
    );
  }

  Future<void> update(PlayerRequestDTO request) async {
    _setBusy(request.userId, true);
    final response = await updatePlayerRequestUseCase(request);
    if (isClosed) return;
    _setBusy(request.userId, false);
    response.fold(
      (failure) => emit(ErrorPlayerRequestsPanelState(state, errorMessage: failure.toString())),
      (_) => emit(UpdatedPlayerRequestsPanelState(state)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
