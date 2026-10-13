import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/approve_team_request_usecase.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/reject_team_request_usecase.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/update_team_request_usecase.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/watch_team_requests_usecase.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/team_requests_panel_state.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

/// Painel do admin: pedidos de time em tempo real; aprovar (cria o time com
/// o dono), rejeitar (com motivo) ou editar antes de responder.
class TeamRequestsPanelCubit extends Cubit<TeamRequestsPanelState> {
  final WatchTeamRequestsUseCase watchTeamRequestsUseCase;
  final ApproveTeamRequestUseCase approveTeamRequestUseCase;
  final RejectTeamRequestUseCase rejectTeamRequestUseCase;
  final UpdateTeamRequestUseCase updateTeamRequestUseCase;
  final GetTeamsUseCase getTeamsUseCase;
  StreamSubscription<Either<Failure, List<TeamRequestDTO>>>? _subscription;

  TeamRequestsPanelCubit(
    this.watchTeamRequestsUseCase,
    this.approveTeamRequestUseCase,
    this.rejectTeamRequestUseCase,
    this.updateTeamRequestUseCase,
    this.getTeamsUseCase,
  ) : super(const TeamRequestsPanelState());

  void watch() {
    _subscription?.cancel();
    _subscription = watchTeamRequestsUseCase().listen((response) {
      response.fold(
        (failure) => emit(ErrorTeamRequestsPanelState(state, errorMessage: failure.toString())),
        (requests) => emit(state.copyWith(requests: requests, loading: false)),
      );
    });
    _loadTeams();
  }

  /// Times da temporada atual (aviso de nome repetido). Falha só tira o aviso.
  Future<void> _loadTeams() async {
    final response = await getTeamsUseCase();
    if (isClosed || response.isLeft) return;
    emit(state.copyWith(teams: response.right));
  }

  void _setBusy(String userId, bool busy) {
    final ids = {...state.busy};
    busy ? ids.add(userId) : ids.remove(userId);
    emit(state.copyWith(busy: ids));
  }

  Future<void> approve(TeamRequestDTO request) async {
    _setBusy(request.userId, true);
    final response = await approveTeamRequestUseCase(request);
    if (isClosed) return;
    _setBusy(request.userId, false);
    response.fold(
      (failure) => emit(ErrorTeamRequestsPanelState(state, errorMessage: failure.toString())),
      (team) {
        emit(NoticeTeamRequestsPanelState(state, notice: TeamRequestsNotice.approved, name: team.name));
        _loadTeams();
      },
    );
  }

  Future<void> reject(TeamRequestDTO request, {String reason = ''}) async {
    _setBusy(request.userId, true);
    final response = await rejectTeamRequestUseCase(userId: request.userId, reason: reason);
    if (isClosed) return;
    _setBusy(request.userId, false);
    response.fold(
      (failure) => emit(ErrorTeamRequestsPanelState(state, errorMessage: failure.toString())),
      (_) => emit(NoticeTeamRequestsPanelState(state, notice: TeamRequestsNotice.rejected, name: request.name)),
    );
  }

  Future<void> update(TeamRequestDTO request) async {
    _setBusy(request.userId, true);
    final response = await updateTeamRequestUseCase(request);
    if (isClosed) return;
    _setBusy(request.userId, false);
    response.fold(
      (failure) => emit(ErrorTeamRequestsPanelState(state, errorMessage: failure.toString())),
      (_) => emit(NoticeTeamRequestsPanelState(state, notice: TeamRequestsNotice.updated, name: request.name)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
