import 'dart:async';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/cancel_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/submit_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/watch_my_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/player_request_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

/// "Sou jogador": acompanha o pedido do usuário em tempo real e cuida do
/// formulário (enviar, editar enquanto pendente, reenviar após rejeição).
class PlayerRequestCubit extends Cubit<PlayerRequestState> {
  final WatchMyPlayerRequestUseCase watchMyPlayerRequestUseCase;
  final SubmitPlayerRequestUseCase submitPlayerRequestUseCase;
  final CancelPlayerRequestUseCase cancelPlayerRequestUseCase;
  final GetRegionsUseCase getRegionsUseCase;
  final GetTeamsUseCase getTeamsUseCase;

  StreamSubscription<Either<Failure, PlayerRequestDTO?>>? _subscription;
  late String _userId;
  late String _userName;
  late String _email;
  late String _initialRegion;

  PlayerRequestCubit(
    this.watchMyPlayerRequestUseCase,
    this.submitPlayerRequestUseCase,
    this.cancelPlayerRequestUseCase,
    this.getRegionsUseCase,
    this.getTeamsUseCase,
  ) : super(const LoadingPlayerRequestState());

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
    emit(const LoadingPlayerRequestState());
    final regions = await getRegionsUseCase();
    if (isClosed) return;
    if (regions.isLeft || regions.right.isEmpty) {
      emit(LoadErrorPlayerRequestState(errorMessage: regions.isLeft ? regions.left.toString() : ''));
      return;
    }
    final list = regions.right;
    final region = list.contains(_initialRegion) ? _initialRegion : list.first;
    emit(ReadyPlayerRequestState(form: PlayerRequestForm(regions: list, selectedRegion: region, name: _userName)));

    _subscription?.cancel();
    _subscription = watchMyPlayerRequestUseCase(_userId).listen(_onRequest);
    await _loadTeams(region);
  }

  void _onRequest(Either<Failure, PlayerRequestDTO?> response) {
    if (response.isLeft) {
      if (state is LoadingPlayerRequestState) {
        emit(LoadErrorPlayerRequestState(errorMessage: response.left.toString()));
      } else {
        emit(ErrorPlayerRequestState(state, errorMessage: response.left.toString()));
      }
      return;
    }
    final request = response.right;
    // Editando: o pedido muda por baixo (ex.: admin respondeu), mas o
    // formulário em edição fica como está.
    if (state.editing) {
      _emitReady(request: request, form: state.form, editing: true);
      return;
    }
    final regionChanged = request != null && request.region.isNotEmpty && request.region != state.form.selectedRegion;
    _emitReady(request: request, form: request == null ? state.form : _formFrom(request, state.form), editing: false);
    // Escudo do time do pedido: precisa dos times da região dele.
    if (regionChanged) _loadTeams(request.region);
  }

  /// Formulário preenchido com o pedido (para mostrar o escudo e para editar).
  PlayerRequestForm _formFrom(PlayerRequestDTO request, PlayerRequestForm form) {
    return form.copyWith(
      selectedRegion: request.region.isEmpty ? null : request.region,
      selectedTeam: () => request.team,
      name: request.name,
      position: request.position,
      message: request.message,
      photo: () => null,
      imageUrl: request.imageUrl,
    );
  }

  void _emitReady({PlayerRequestDTO? request, required PlayerRequestForm form, required bool editing}) {
    emit(ReadyPlayerRequestState(request: request, form: form, editing: editing));
  }

  void _updateForm(PlayerRequestForm form) => _emitReady(request: state.request, form: form, editing: state.editing);

  Future<void> _loadTeams(String region) async {
    _updateForm(state.form.copyWith(selectedRegion: region, loadingTeams: true));
    final response = await getTeamsUseCase(region: region);
    // Só aplica se a região não mudou enquanto carregava.
    if (isClosed || state.form.selectedRegion != region) return;
    response.fold(
      (failure) {
        _updateForm(state.form.copyWith(teams: const [], loadingTeams: false));
        emit(ErrorPlayerRequestState(state, errorMessage: failure.toString()));
      },
      (teams) {
        final keep = teams.any((t) => t.name == state.form.selectedTeam);
        _updateForm(state.form.copyWith(
          teams: teams,
          loadingTeams: false,
          selectedTeam: keep ? null : () => null,
        ));
      },
    );
  }

  /// Abre o formulário sobre o pedido atual (corrigir pendente ou reenviar).
  void startEditing() {
    final request = state.request;
    final form = request == null ? state.form : _formFrom(request, state.form);
    _emitReady(request: request, form: form, editing: true);
  }

  void stopEditing() {
    final request = state.request;
    _emitReady(request: request, form: request == null ? state.form : _formFrom(request, state.form), editing: false);
  }

  Future<void> selectRegion(String region) async {
    if (region == state.form.selectedRegion) return;
    _updateForm(state.form.copyWith(selectedTeam: () => null));
    await _loadTeams(region);
  }

  void selectTeam(String team) => _updateForm(state.form.copyWith(selectedTeam: () => team));

  void changeName(String name) => _updateForm(state.form.copyWith(name: name));

  void selectPosition(PlayerPosition position) => _updateForm(state.form.copyWith(position: position));

  void changeMessage(String message) => _updateForm(state.form.copyWith(message: message));

  void setPhoto(File photo) => _updateForm(state.form.copyWith(photo: () => photo));

  void clearPhoto() => _updateForm(state.form.copyWith(photo: () => null, imageUrl: ''));

  Future<void> submit() async {
    final form = state.form;
    if (form.error != null || state is SubmittingPlayerRequestState) return;
    final current = state;
    emit(SubmittingPlayerRequestState(current));

    final request = PlayerRequestDTO(
      userId: _userId,
      userName: _userName,
      email: _email,
      name: form.name,
      team: form.selectedTeam!,
      teamId: form.selectedTeamId,
      region: form.selectedRegion ?? '',
      season: SeasonCollection.currentSeason,
      position: form.position,
      message: form.message,
      imageUrl: form.imageUrl,
    );
    final response = await submitPlayerRequestUseCase(request, photo: form.photo);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorPlayerRequestState(current, errorMessage: failure.toString())),
      (_) => emit(SubmittedPlayerRequestState(current)),
    );
  }

  Future<void> cancelRequest() async {
    if (state is SubmittingPlayerRequestState) return;
    final current = state;
    emit(SubmittingPlayerRequestState(current));
    final response = await cancelPlayerRequestUseCase(_userId);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorPlayerRequestState(current, errorMessage: failure.toString())),
      (_) => emit(CancelledPlayerRequestState(current)),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
