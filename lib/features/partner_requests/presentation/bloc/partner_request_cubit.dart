import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/news/data/dtos/pending_news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/pending_news_usecase.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/delete_highlight_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/watch_all_highlights_usecase.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/cancel_partner_request_usecase.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/get_partner_slots_usecase.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/partner_highlight_links_usecase.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/submit_partner_request_usecase.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/watch_my_partner_request_usecase.dart';
import 'package:arena_soccer/features/partner_requests/presentation/bloc/partner_request_state.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';

/// "Sou parceiro": acompanha o pedido em tempo real e cuida do formulário
/// (enviar, editar enquanto pendente, reenviar após rejeição ou remoção).
/// Aprovado, mostra as vagas usadas e os destaques do parceiro. Antes e
/// depois, lista os destaques sem dono para o pedido de vínculo.
class PartnerRequestCubit extends Cubit<PartnerRequestState> {
  final WatchMyPartnerRequestUseCase watchMyPartnerRequestUseCase;
  final SubmitPartnerRequestUseCase submitPartnerRequestUseCase;
  final CancelPartnerRequestUseCase cancelPartnerRequestUseCase;
  final GetRegionsUseCase getRegionsUseCase;
  final GetPartnerSlotsUseCase getPartnerSlotsUseCase;
  final WatchAllHighlightsUseCase watchAllHighlightsUseCase;
  final DeleteHighlightUseCase deleteHighlightUseCase;
  final PartnerHighlightLinksUseCase partnerHighlightLinksUseCase;
  final PendingNewsUseCase pendingNewsUseCase;

  StreamSubscription<Either<Failure, PartnerRequestDTO?>>? _subscription;
  StreamSubscription<Either<Failure, List<HighlightDTO>>>? _highlights;
  StreamSubscription<Either<Failure, List<PendingNewsDTO>>>? _pendingNews;
  late String _userId;
  late String _userName;
  late String _email;
  late String _initialRegion;

  PartnerRequestCubit(
    this.watchMyPartnerRequestUseCase,
    this.submitPartnerRequestUseCase,
    this.cancelPartnerRequestUseCase,
    this.getRegionsUseCase,
    this.getPartnerSlotsUseCase,
    this.watchAllHighlightsUseCase,
    this.deleteHighlightUseCase,
    this.partnerHighlightLinksUseCase,
    this.pendingNewsUseCase,
  ) : super(const LoadingPartnerRequestState());

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
    emit(const LoadingPartnerRequestState());
    final regions = await getRegionsUseCase();
    if (isClosed) return;
    if (regions.isLeft || regions.right.isEmpty) {
      emit(LoadErrorPartnerRequestState(errorMessage: regions.isLeft ? regions.left.toString() : ''));
      return;
    }
    final list = regions.right;
    final region = list.contains(_initialRegion) ? _initialRegion : list.first;
    _emitReady(form: PartnerRequestForm(regions: list, selectedRegion: region));

    _subscription?.cancel();
    _subscription = watchMyPartnerRequestUseCase(_userId).listen(_onRequest);
    _watchHighlights();
  }

  void _onRequest(Either<Failure, PartnerRequestDTO?> response) {
    if (response.isLeft) {
      if (state is LoadingPartnerRequestState) {
        emit(LoadErrorPartnerRequestState(errorMessage: response.left.toString()));
      } else {
        emit(ErrorPartnerRequestState(state, errorMessage: response.left.toString()));
      }
      return;
    }
    final request = response.right;
    final wasApproved = state.request?.isApproved ?? false;
    final permissionsChanged = state.request?.permissions != request?.permissions;
    if (state.editing) {
      _emitReady(request: request, form: state.form, editing: true);
    } else {
      _emitReady(request: request, form: request == null ? state.form : _formFrom(request, state.form));
    }
    final approved = request?.isApproved ?? false;
    if (approved && (!wasApproved || permissionsChanged)) refreshSlots();
    if (approved && _pendingNews == null) _watchPendingNews();
  }

  PartnerRequestForm _formFrom(PartnerRequestDTO request, PartnerRequestForm form) => form.copyWith(
        selectedRegion: request.region.isEmpty ? null : request.region,
        name: request.name,
        contact: request.contact,
        message: request.message,
        claimedHighlightIds: request.claimedHighlightIds,
      );

  void _emitReady({PartnerRequestDTO? request, required PartnerRequestForm form, bool editing = false}) {
    emit(ReadyPartnerRequestState(
      request: request,
      form: form,
      editing: editing,
      slots: state.slots,
      highlights: state.highlights,
      unlinkedHighlights: state.unlinkedHighlights,
      pendingNews: state.pendingNews,
    ));
  }

  void _updateForm(PartnerRequestForm form) => _emitReady(request: state.request, form: form, editing: state.editing);

  /// Destaques do parceiro e os sem dono (a coleção é pequena; filtra no app).
  void _watchHighlights() {
    _highlights?.cancel();
    _highlights = watchAllHighlightsUseCase().listen((response) {
      if (isClosed || response.isLeft) return;
      final mine = response.right.where((h) => h.authorId == _userId).toList();
      // Só os visíveis no app podem ser pedidos no vínculo.
      final unlinked = response.right.where((h) => h.authorId.isEmpty && h.isVisible).toList();
      emit(ReadyPartnerRequestState(
        request: state.request,
        form: state.form,
        editing: state.editing,
        slots: state.slots,
        highlights: mine,
        unlinkedHighlights: unlinked,
        pendingNews: state.pendingNews,
      ));
    });
  }

  /// Notícias do parceiro esperando o admin (as aprovadas já estão no feed).
  void _watchPendingNews() {
    _pendingNews = pendingNewsUseCase.watchMine(_userId).listen((response) {
      if (isClosed || response.isLeft) return;
      emit(ReadyPartnerRequestState(
        request: state.request,
        form: state.form,
        editing: state.editing,
        slots: state.slots,
        highlights: state.highlights,
        unlinkedHighlights: state.unlinkedHighlights,
        pendingNews: response.right.where((n) => n.status != PendingNewsStatus.approved).toList(),
      ));
    });
  }

  Future<void> deletePendingNews(PendingNewsDTO pending) async {
    final current = state;
    final response = await pendingNewsUseCase.delete(pending.id);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorPartnerRequestState(current, errorMessage: failure.toString())),
      (_) => emit(NoticePartnerRequestState(state, notice: PartnerRequestNotice.pendingNewsDeleted)),
    );
  }

  /// Vagas usadas (ao abrir e ao voltar das telas de publicar). Falha só
  /// esconde o contador.
  Future<void> refreshSlots() async {
    final partner = state.request;
    if (partner == null || !partner.isApproved) return;
    final response = await getPartnerSlotsUseCase(partner);
    if (isClosed || response.isLeft) return;
    emit(ReadyPartnerRequestState(
      request: state.request,
      form: state.form,
      editing: state.editing,
      slots: response.right,
      highlights: state.highlights,
      unlinkedHighlights: state.unlinkedHighlights,
      pendingNews: state.pendingNews,
    ));
  }

  void startEditing() {
    final request = state.request;
    _emitReady(request: request, form: request == null ? state.form : _formFrom(request, state.form), editing: true);
  }

  void stopEditing() {
    final request = state.request;
    _emitReady(request: request, form: request == null ? state.form : _formFrom(request, state.form));
  }

  void selectRegion(String region) => _updateForm(state.form.copyWith(selectedRegion: region));

  void changeName(String value) => _updateForm(state.form.copyWith(name: value));

  void changeContact(String value) => _updateForm(state.form.copyWith(contact: value));

  void changeMessage(String value) => _updateForm(state.form.copyWith(message: value));

  /// Formulário: marca/desmarca um destaque sem dono como "é meu".
  void toggleClaim(String highlightId) =>
      _updateForm(state.form.copyWith(claimedHighlightIds: toggled(state.form.claimedHighlightIds, highlightId)));

  /// Parceiro aprovado: pede (ou desfaz o pedido de) vínculo de um destaque.
  Future<void> toggleLinkRequest(String highlightId) async {
    final request = state.request;
    if (request == null) return;
    final ids = toggled(request.claimedHighlightIds, highlightId);
    final current = state;
    final response = await partnerHighlightLinksUseCase.request(_userId, ids);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorPartnerRequestState(current, errorMessage: failure.toString())),
      (_) {
        if (ids.length > request.claimedHighlightIds.length) {
          emit(NoticePartnerRequestState(state, notice: PartnerRequestNotice.linkRequested));
        }
      },
    );
  }

  /// [ids] com [id] acrescentado ou tirado.
  static List<String> toggled(List<String> ids, String id) =>
      ids.contains(id) ? ids.where((item) => item != id).toList() : [...ids, id];

  Future<void> submit() async {
    final form = state.form;
    if (form.error != null || state is SubmittingPartnerRequestState) return;
    final current = state;
    emit(SubmittingPartnerRequestState(current));
    final response = await submitPartnerRequestUseCase(PartnerRequestDTO(
      userId: _userId,
      userName: _userName,
      email: _email,
      name: form.name,
      region: form.selectedRegion ?? '',
      contact: form.contact,
      message: form.message,
      // Só os que continuam sem dono.
      claimedHighlightIds: form.claimedHighlightIds
          .where((id) => state.unlinkedHighlights.any((h) => h.id == id))
          .toList(),
    ));
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorPartnerRequestState(current, errorMessage: failure.toString())),
      (_) => emit(NoticePartnerRequestState(current, notice: PartnerRequestNotice.submitted)),
    );
  }

  Future<void> cancelRequest() async {
    if (state is SubmittingPartnerRequestState) return;
    final current = state;
    emit(SubmittingPartnerRequestState(current));
    final response = await cancelPartnerRequestUseCase(_userId);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorPartnerRequestState(current, errorMessage: failure.toString())),
      (_) => emit(NoticePartnerRequestState(current, notice: PartnerRequestNotice.cancelled)),
    );
  }

  /// Apaga um destaque do parceiro (libera a vaga; desmarca só as notícias dele).
  Future<void> deleteHighlight(HighlightDTO highlight) async {
    final current = state;
    final response = await deleteHighlightUseCase(highlight, newsAuthorId: _userId);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorPartnerRequestState(current, errorMessage: failure.toString())),
      (_) => emit(NoticePartnerRequestState(state, notice: PartnerRequestNotice.highlightDeleted)),
    );
    await refreshSlots();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _highlights?.cancel();
    _pendingNews?.cancel();
    return super.close();
  }
}
