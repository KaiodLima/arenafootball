import 'dart:async';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/organizer_requests/data/dtos/organizer_request_dto.dart';
import 'package:arena_soccer/features/organizer_requests/domain/usecases/organizer_request_usecases.dart';
import 'package:arena_soccer/features/organizer_requests/presentation/bloc/organizer_request_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';

/// "Sou organizador de campeonato": acompanha o pedido e os campeonatos da
/// conta em tempo real e cuida do formulário (enviar, corrigir o pendente,
/// reenviar após rejeição, pedir outro depois de aprovado).
class OrganizerRequestCubit extends Cubit<OrganizerRequestState> {
  final WatchMyOrganizerRequestUseCase watchMyOrganizerRequestUseCase;
  final WatchMyChampionshipsUseCase watchMyChampionshipsUseCase;
  final SubmitOrganizerRequestUseCase submitOrganizerRequestUseCase;
  final CancelOrganizerRequestUseCase cancelOrganizerRequestUseCase;
  final GetRegionsUseCase getRegionsUseCase;

  StreamSubscription<Either<Failure, OrganizerRequestDTO?>>? _request;
  StreamSubscription<Either<Failure, List<ChampionshipDTO>>>? _championships;
  late String _userId;
  late String _userName;
  late String _email;
  late String _initialRegion;

  OrganizerRequestCubit(
    this.watchMyOrganizerRequestUseCase,
    this.watchMyChampionshipsUseCase,
    this.submitOrganizerRequestUseCase,
    this.cancelOrganizerRequestUseCase,
    this.getRegionsUseCase,
  ) : super(const LoadingOrganizerRequestState());

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
    emit(const LoadingOrganizerRequestState());
    final regions = await getRegionsUseCase();
    if (isClosed) return;
    if (regions.isLeft || regions.right.isEmpty) {
      emit(LoadErrorOrganizerRequestState(errorMessage: regions.isLeft ? regions.left.toString() : ''));
      return;
    }
    final list = regions.right;
    final region = list.contains(_initialRegion) ? _initialRegion : list.first;
    emit(ReadyOrganizerRequestState(form: OrganizerRequestForm(regions: list, selectedRegion: region)));

    _request?.cancel();
    _request = watchMyOrganizerRequestUseCase(_userId).listen(_onRequest);
    _championships?.cancel();
    _championships = watchMyChampionshipsUseCase(_userId).listen((response) {
      // Falha só esconde a lista ("Meus campeonatos").
      if (isClosed || response.isLeft || state is LoadErrorOrganizerRequestState) return;
      _emitReady(
        request: state.request,
        form: state.form,
        editing: state.editing,
        championships: response.right,
      );
    });
  }

  void _onRequest(Either<Failure, OrganizerRequestDTO?> response) {
    if (isClosed) return;
    if (response.isLeft) {
      if (state is LoadingOrganizerRequestState) {
        emit(LoadErrorOrganizerRequestState(errorMessage: response.left.toString()));
      } else {
        emit(ErrorOrganizerRequestState(state, errorMessage: response.left.toString()));
      }
      return;
    }
    final request = response.right;
    if (state.editing) {
      _emitReady(request: request, form: state.form, editing: true);
      return;
    }
    _emitReady(request: request, form: request == null ? state.form : _formFrom(request, state.form), editing: false);
  }

  OrganizerRequestForm _formFrom(OrganizerRequestDTO request, OrganizerRequestForm form) => form.copyWith(
        selectedRegion: request.region.isEmpty ? null : request.region,
        scope: request.scope,
        name: request.name,
        description: request.description,
        contact: request.contact,
        logo: () => null,
        imageUrl: request.imageUrl,
      );

  void _emitReady({
    OrganizerRequestDTO? request,
    required OrganizerRequestForm form,
    required bool editing,
    List<ChampionshipDTO>? championships,
  }) {
    emit(ReadyOrganizerRequestState(
      request: request,
      form: form,
      editing: editing,
      championships: championships ?? state.championships,
    ));
  }

  void _updateForm(OrganizerRequestForm form) =>
      _emitReady(request: state.request, form: form, editing: state.editing);

  /// Corrige o pendente ou reenvia o rejeitado (com os dados dele).
  void startEditing() {
    final request = state.request;
    _emitReady(request: request, form: request == null ? state.form : _formFrom(request, state.form), editing: true);
  }

  /// Pedido aprovado: um campeonato novo começa do zero (fica o contato).
  void startNewRequest() {
    final form = state.form;
    _emitReady(
      request: state.request,
      form: OrganizerRequestForm(
        regions: form.regions,
        selectedRegion: form.selectedRegion,
        contact: state.request?.contact ?? form.contact,
      ),
      editing: true,
    );
  }

  void stopEditing() {
    final request = state.request;
    _emitReady(request: request, form: request == null ? state.form : _formFrom(request, state.form), editing: false);
  }

  void selectRegion(String region) => _updateForm(state.form.copyWith(selectedRegion: region));

  void selectScope(ChampionshipScope scope) => _updateForm(state.form.copyWith(scope: scope));

  void changeName(String value) => _updateForm(state.form.copyWith(name: value));

  void changeDescription(String value) => _updateForm(state.form.copyWith(description: value));

  void changeContact(String value) => _updateForm(state.form.copyWith(contact: value));

  void setLogo(File file) => _updateForm(state.form.copyWith(logo: () => file));

  void clearLogo() => _updateForm(state.form.copyWith(logo: () => null, imageUrl: ''));

  Future<void> submit() async {
    final form = state.form;
    if (form.error != null || state is SubmittingOrganizerRequestState) return;
    final current = state;
    emit(SubmittingOrganizerRequestState(current));
    final request = OrganizerRequestDTO(
      userId: _userId,
      userName: _userName,
      email: _email,
      name: form.name,
      region: form.selectedRegion ?? '',
      scope: form.scope,
      description: form.description,
      imageUrl: form.imageUrl,
      contact: form.contact,
    );
    final response = await submitOrganizerRequestUseCase(request, logo: form.logo);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorOrganizerRequestState(current, errorMessage: failure.toString())),
      (_) => emit(SubmittedOrganizerRequestState(current)),
    );
  }

  Future<void> cancelRequest() async {
    if (state is SubmittingOrganizerRequestState) return;
    final current = state;
    emit(SubmittingOrganizerRequestState(current));
    final response = await cancelOrganizerRequestUseCase(_userId);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorOrganizerRequestState(current, errorMessage: failure.toString())),
      (_) => emit(CancelledOrganizerRequestState(current)),
    );
  }

  @override
  Future<void> close() {
    _request?.cancel();
    _championships?.cancel();
    return super.close();
  }
}
