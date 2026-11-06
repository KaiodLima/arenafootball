import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/organizer_requests/data/dtos/organizer_request_dto.dart';
import 'package:arena_soccer/features/organizer_requests/domain/usecases/organizer_request_usecases.dart';

/// Painel do admin com os pedidos "Sou organizador de campeonato".
class OrganizerRequestsPanelState extends Equatable {
  final List<OrganizerRequestDTO> requests;

  /// Pedidos com resposta em andamento (uid).
  final Set<String> busy;
  final bool loading;

  const OrganizerRequestsPanelState({this.requests = const [], this.busy = const {}, this.loading = true});

  List<OrganizerRequestDTO> get pending => requests.where((r) => r.isPending).toList();

  List<OrganizerRequestDTO> get answered => requests.where((r) => !r.isPending).toList();

  OrganizerRequestsPanelState copyWith({List<OrganizerRequestDTO>? requests, Set<String>? busy, bool? loading}) {
    return OrganizerRequestsPanelState(
      requests: requests ?? this.requests,
      busy: busy ?? this.busy,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [requests, busy, loading];
}

enum OrganizerRequestsNotice { approved, rejected, updated }

class NoticeOrganizerRequestsPanelState extends OrganizerRequestsPanelState {
  final OrganizerRequestsNotice notice;
  final String name;

  NoticeOrganizerRequestsPanelState(OrganizerRequestsPanelState from, {required this.notice, this.name = ''})
      : super(requests: from.requests, busy: from.busy, loading: from.loading);

  @override
  List<Object?> get props => [...super.props, notice, name];
}

class ErrorOrganizerRequestsPanelState extends OrganizerRequestsPanelState {
  final String errorMessage;

  ErrorOrganizerRequestsPanelState(OrganizerRequestsPanelState from, {required this.errorMessage})
      : super(requests: from.requests, busy: from.busy, loading: false);

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

/// Pedidos em tempo real; aprovar (cria o campeonato com o organizador),
/// rejeitar (com motivo) ou editar antes de responder.
class OrganizerRequestsPanelCubit extends Cubit<OrganizerRequestsPanelState> {
  final WatchOrganizerRequestsUseCase watchOrganizerRequestsUseCase;
  final ApproveOrganizerRequestUseCase approveOrganizerRequestUseCase;
  final RejectOrganizerRequestUseCase rejectOrganizerRequestUseCase;
  final UpdateOrganizerRequestUseCase updateOrganizerRequestUseCase;
  final EnsureOrganizerIndexesUseCase? ensureOrganizerIndexesUseCase;
  StreamSubscription<Either<Failure, List<OrganizerRequestDTO>>>? _subscription;

  OrganizerRequestsPanelCubit(
    this.watchOrganizerRequestsUseCase,
    this.approveOrganizerRequestUseCase,
    this.rejectOrganizerRequestUseCase,
    this.updateOrganizerRequestUseCase, [
    this.ensureOrganizerIndexesUseCase,
  ]) : super(const OrganizerRequestsPanelState());

  void watch() {
    _subscription?.cancel();
    // Campeonatos aprovados antes do índice: cria os que faltam (em segundo
    // plano; falha não atrapalha o painel).
    unawaited(ensureOrganizerIndexesUseCase?.call());
    _subscription = watchOrganizerRequestsUseCase().listen((response) {
      if (isClosed) return;
      response.fold(
        (failure) => emit(ErrorOrganizerRequestsPanelState(state, errorMessage: failure.toString())),
        (requests) => emit(state.copyWith(requests: requests, loading: false)),
      );
    });
  }

  void _setBusy(String userId, bool busy) {
    final ids = {...state.busy};
    busy ? ids.add(userId) : ids.remove(userId);
    emit(state.copyWith(busy: ids));
  }

  Future<void> approve(OrganizerRequestDTO request) async {
    _setBusy(request.userId, true);
    final response = await approveOrganizerRequestUseCase(request);
    if (isClosed) return;
    _setBusy(request.userId, false);
    response.fold(
      (failure) => emit(ErrorOrganizerRequestsPanelState(state, errorMessage: failure.toString())),
      (championship) => emit(
        NoticeOrganizerRequestsPanelState(state, notice: OrganizerRequestsNotice.approved, name: championship.title),
      ),
    );
  }

  Future<void> reject(OrganizerRequestDTO request, {String reason = ''}) async {
    _setBusy(request.userId, true);
    final response = await rejectOrganizerRequestUseCase(userId: request.userId, reason: reason);
    if (isClosed) return;
    _setBusy(request.userId, false);
    response.fold(
      (failure) => emit(ErrorOrganizerRequestsPanelState(state, errorMessage: failure.toString())),
      (_) => emit(NoticeOrganizerRequestsPanelState(state, notice: OrganizerRequestsNotice.rejected)),
    );
  }

  Future<void> update(OrganizerRequestDTO request) async {
    _setBusy(request.userId, true);
    final response = await updateOrganizerRequestUseCase(request);
    if (isClosed) return;
    _setBusy(request.userId, false);
    response.fold(
      (failure) => emit(ErrorOrganizerRequestsPanelState(state, errorMessage: failure.toString())),
      (_) => emit(NoticeOrganizerRequestsPanelState(state, notice: OrganizerRequestsNotice.updated)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
