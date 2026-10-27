import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/news/data/dtos/pending_news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/pending_news_usecase.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/watch_all_highlights_usecase.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/answer_partner_request_usecase.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/partner_highlight_links_usecase.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/update_partner_permissions_usecase.dart';
import 'package:arena_soccer/features/partner_requests/domain/usecases/watch_partner_requests_usecase.dart';
import 'package:arena_soccer/features/partner_requests/presentation/bloc/partner_requests_panel_state.dart';

/// Painel do admin: pedidos "Sou parceiro" em tempo real; aprovar, rejeitar,
/// ajustar as permissões, vincular os destaques pedidos e remover o parceiro.
class PartnerRequestsPanelCubit extends Cubit<PartnerRequestsPanelState> {
  final WatchPartnerRequestsUseCase watchPartnerRequestsUseCase;
  final AnswerPartnerRequestUseCase answerPartnerRequestUseCase;
  final UpdatePartnerPermissionsUseCase updatePartnerPermissionsUseCase;
  final PartnerHighlightLinksUseCase partnerHighlightLinksUseCase;
  final WatchAllHighlightsUseCase watchAllHighlightsUseCase;
  final PendingNewsUseCase pendingNewsUseCase;
  StreamSubscription<Either<Failure, List<PartnerRequestDTO>>>? _subscription;
  StreamSubscription<Either<Failure, List<HighlightDTO>>>? _highlights;
  StreamSubscription<Either<Failure, List<PendingNewsDTO>>>? _pendingNews;

  PartnerRequestsPanelCubit(
    this.watchPartnerRequestsUseCase,
    this.answerPartnerRequestUseCase,
    this.updatePartnerPermissionsUseCase,
    this.partnerHighlightLinksUseCase,
    this.watchAllHighlightsUseCase,
    this.pendingNewsUseCase,
  ) : super(const PartnerRequestsPanelState());

  void watch() {
    _subscription?.cancel();
    _subscription = watchPartnerRequestsUseCase().listen((response) {
      if (isClosed) return;
      response.fold(
        (failure) => emit(ErrorPartnerRequestsPanelState(state, errorMessage: failure.toString())),
        (requests) => emit(state.copyWith(requests: requests, loading: false)),
      );
    });
    // Títulos dos destaques pedidos no vínculo. Falha só mostra a quantidade.
    _highlights?.cancel();
    _highlights = watchAllHighlightsUseCase().listen((response) {
      if (isClosed || response.isLeft) return;
      emit(state.copyWith(highlightTitles: {for (final h in response.right) h.id: h.title}));
    });
    _pendingNews?.cancel();
    _pendingNews = pendingNewsUseCase.watchPending().listen((response) {
      if (isClosed) return;
      response.fold(
        (failure) => emit(ErrorPartnerRequestsPanelState(state, errorMessage: failure.toString())),
        (pending) => emit(state.copyWith(pendingNews: pending)),
      );
    });
  }

  /// Publica a notícia pendente no feed.
  Future<void> approveNews(PendingNewsDTO pending) => _runNews(
      pending, PartnerRequestsNotice.newsApproved, () => pendingNewsUseCase.approve(pending));

  Future<void> rejectNews(PendingNewsDTO pending, {String reason = ''}) => _runNews(
      pending, PartnerRequestsNotice.newsRejected, () => pendingNewsUseCase.reject(pending.id, reason: reason));

  Future<void> _runNews(
    PendingNewsDTO pending,
    PartnerRequestsNotice notice,
    Future<Either<Failure, void>> Function() action,
  ) async {
    _setBusy(pending.id, true);
    final response = await action();
    if (isClosed) return;
    _setBusy(pending.id, false);
    response.fold(
      (failure) => emit(ErrorPartnerRequestsPanelState(state, errorMessage: failure.toString())),
      (_) => emit(NoticePartnerRequestsPanelState(state, notice: notice, name: pending.news.title)),
    );
  }

  /// Aprova e, se pediu, já vincula os destaques.
  Future<void> approve(PartnerRequestDTO request) async {
    await _run(request, PartnerRequestsNotice.approved, () => answerPartnerRequestUseCase.approve(request.userId));
    if (!isClosed && state is! ErrorPartnerRequestsPanelState && request.claimedHighlightIds.isNotEmpty) {
      await linkHighlights(request);
    }
  }

  Future<void> linkHighlights(PartnerRequestDTO request) async {
    _setBusy(request.userId, true);
    final response = await partnerHighlightLinksUseCase.link(request);
    if (isClosed) return;
    _setBusy(request.userId, false);
    response.fold(
      (failure) => emit(ErrorPartnerRequestsPanelState(state, errorMessage: failure.toString())),
      (count) => emit(NoticePartnerRequestsPanelState(state, notice: PartnerRequestsNotice.linked, name: request.name, count: count)),
    );
  }

  Future<void> clearHighlightLinks(PartnerRequestDTO request) => _run(
      request, PartnerRequestsNotice.linksCleared, () => partnerHighlightLinksUseCase.clear(request.userId));

  Future<void> reject(PartnerRequestDTO request, {String reason = ''}) => _run(
      request, PartnerRequestsNotice.rejected, () => answerPartnerRequestUseCase.reject(request.userId, reason: reason));

  Future<void> revoke(PartnerRequestDTO request, {String reason = ''}) => _run(
      request, PartnerRequestsNotice.revoked, () => answerPartnerRequestUseCase.revoke(request.userId, reason: reason));

  Future<void> savePermissions(PartnerRequestDTO request, PartnerPermissions permissions) => _run(
        request,
        PartnerRequestsNotice.permissionsSaved,
        () => updatePartnerPermissionsUseCase(userId: request.userId, permissions: permissions),
      );

  Future<void> _run(
    PartnerRequestDTO request,
    PartnerRequestsNotice notice,
    Future<Either<Failure, void>> Function() action,
  ) async {
    _setBusy(request.userId, true);
    final response = await action();
    if (isClosed) return;
    _setBusy(request.userId, false);
    response.fold(
      (failure) => emit(ErrorPartnerRequestsPanelState(state, errorMessage: failure.toString())),
      (_) => emit(NoticePartnerRequestsPanelState(state, notice: notice, name: request.name)),
    );
  }

  void _setBusy(String userId, bool busy) {
    final ids = {...state.busy};
    busy ? ids.add(userId) : ids.remove(userId);
    emit(state.copyWith(busy: ids));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _highlights?.cancel();
    _pendingNews?.cancel();
    return super.close();
  }
}
