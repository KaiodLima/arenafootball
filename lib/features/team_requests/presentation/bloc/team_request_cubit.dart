import 'dart:async';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/cancel_team_request_usecase.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/submit_team_request_usecase.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/watch_my_team_request_usecase.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/team_request_state.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

/// "Sou dono de time": acompanha o pedido do usuário em tempo real e cuida
/// do formulário (enviar, editar enquanto pendente, reenviar após rejeição).
class TeamRequestCubit extends Cubit<TeamRequestState> {
  final WatchMyTeamRequestUseCase watchMyTeamRequestUseCase;
  final SubmitTeamRequestUseCase submitTeamRequestUseCase;
  final CancelTeamRequestUseCase cancelTeamRequestUseCase;
  final GetRegionsUseCase getRegionsUseCase;
  final GetTeamsUseCase getTeamsUseCase;

  StreamSubscription<Either<Failure, TeamRequestDTO?>>? _subscription;
  late String _userId;
  late String _userName;
  late String _email;
  late String _initialRegion;

  TeamRequestCubit(
    this.watchMyTeamRequestUseCase,
    this.submitTeamRequestUseCase,
    this.cancelTeamRequestUseCase,
    this.getRegionsUseCase,
    this.getTeamsUseCase,
  ) : super(const LoadingTeamRequestState());

  Future<void> start({
    required String userId,
    required String userName,
    required String email,
    required String initialRegion,
  }) async {
    _userId = userId;
    _userName = userName;
    _email = email;
    _initialRegion = initialRegion;
    await _load();
  }

  Future<void> retry() => _load();

  Future<void> _load() async {
    emit(const LoadingTeamRequestState());
    final regions = await getRegionsUseCase();
    if (isClosed) return;
    if (regions.isLeft || regions.right.isEmpty) {
      emit(LoadErrorTeamRequestState(errorMessage: regions.isLeft ? regions.left.toString() : ''));
      return;
    }
    final list = regions.right;
    final region = list.contains(_initialRegion) ? _initialRegion : list.first;
    emit(ReadyTeamRequestState(form: TeamRequestForm(regions: list, selectedRegion: region)));

    _subscription?.cancel();
    _subscription = watchMyTeamRequestUseCase(_userId).listen(_onRequest);
    await _loadExistingTeams(region);
  }

  void _onRequest(Either<Failure, TeamRequestDTO?> response) {
    if (response.isLeft) {
      if (state is LoadingTeamRequestState) {
        emit(LoadErrorTeamRequestState(errorMessage: response.left.toString()));
      } else {
        emit(ErrorTeamRequestState(state, errorMessage: response.left.toString()));
      }
      return;
    }
    final request = response.right;
    if (state.editing) {
      _emitReady(request: request, form: state.form, editing: true);
      return;
    }
    final regionChanged = request != null && request.region.isNotEmpty && request.region != state.form.selectedRegion;
    _emitReady(request: request, form: request == null ? state.form : _formFrom(request, state.form), editing: false);
    if (regionChanged) _loadExistingTeams(request.region);
  }

  TeamRequestForm _formFrom(TeamRequestDTO request, TeamRequestForm form) => form.copyWith(
        selectedRegion: request.region.isEmpty ? null : request.region,
        name: request.name,
        description: request.description,
        contact: request.contact,
        message: request.message,
        crest: () => null,
        primaryColor: request.primaryColor,
        secondaryColor: request.secondaryColor,
        imageUrl: request.imageUrl,
      );

  void _emitReady({TeamRequestDTO? request, required TeamRequestForm form, required bool editing}) {
    emit(ReadyTeamRequestState(request: request, form: form, editing: editing));
  }

  void _updateForm(TeamRequestForm form) => _emitReady(request: state.request, form: form, editing: state.editing);

  /// Times que já existem na região (para o aviso de nome repetido). Sem a
  /// lista, o aviso só não aparece; o admin confere na aprovação.
  Future<void> _loadExistingTeams(String region) async {
    _updateForm(state.form.copyWith(selectedRegion: region, existingTeams: const []));
    final response = await getTeamsUseCase(region: region);
    if (isClosed || state.form.selectedRegion != region) return;
    if (response.isRight) {
      _updateForm(state.form.copyWith(existingTeams: response.right.map((t) => t.name).toList()));
    }
  }

  void startEditing() {
    final request = state.request;
    _emitReady(request: request, form: request == null ? state.form : _formFrom(request, state.form), editing: true);
  }

  void stopEditing() {
    final request = state.request;
    _emitReady(request: request, form: request == null ? state.form : _formFrom(request, state.form), editing: false);
  }

  Future<void> selectRegion(String region) async {
    if (region == state.form.selectedRegion) return;
    await _loadExistingTeams(region);
  }

  void changeName(String value) => _updateForm(state.form.copyWith(name: value));

  void changeDescription(String value) => _updateForm(state.form.copyWith(description: value));

  void changeContact(String value) => _updateForm(state.form.copyWith(contact: value));

  void changeMessage(String value) => _updateForm(state.form.copyWith(message: value));

  void setCrest(File file) => _updateForm(state.form.copyWith(crest: () => file));

  void clearCrest() => _updateForm(state.form.copyWith(crest: () => null, imageUrl: ''));

  void setPrimaryColor(String hex) => _updateForm(state.form.copyWith(primaryColor: hex));

  void setSecondaryColor(String hex) => _updateForm(state.form.copyWith(secondaryColor: hex));

  Future<void> submit() async {
    final form = state.form;
    if (form.error != null || state is SubmittingTeamRequestState) return;
    final current = state;
    emit(SubmittingTeamRequestState(current));
    final request = TeamRequestDTO(
      userId: _userId,
      userName: _userName,
      email: _email,
      name: form.name,
      region: form.selectedRegion ?? '',
      description: form.description,
      imageUrl: form.imageUrl,
      primaryColor: form.primaryColor,
      secondaryColor: form.secondaryColor,
      contact: form.contact,
      message: form.message,
    );
    final response = await submitTeamRequestUseCase(request, crest: form.crest);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorTeamRequestState(current, errorMessage: failure.toString())),
      (_) => emit(SubmittedTeamRequestState(current)),
    );
  }

  Future<void> cancelRequest() async {
    if (state is SubmittingTeamRequestState) return;
    final current = state;
    emit(SubmittingTeamRequestState(current));
    final response = await cancelTeamRequestUseCase(_userId);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorTeamRequestState(current, errorMessage: failure.toString())),
      (_) => emit(CancelledTeamRequestState(current)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
