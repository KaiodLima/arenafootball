import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/event_polls/domain/usecases/event_poll_usecase.dart';
import 'package:arena_soccer/features/event_polls/presentation/bloc/event_poll_state.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

/// Página do evento de votação: ouve o card (encerrar/prazo mudam na hora),
/// o voto da conta e, quando pode ser lida, a apuração.
class EventPollCubit extends Cubit<EventPollState> {
  final EventPollUseCase eventPollUseCase;

  /// Relógio (teste).
  final DateTime Function() now;

  EventPollCubit(this.eventPollUseCase, {DateTime Function()? now})
      : now = now ?? DateTime.now,
        super(const EventPollState());

  StreamSubscription<Either<Failure, NewsDTO?>>? _cardSub;
  StreamSubscription<Either<Failure, String?>>? _voteSub;
  StreamSubscription<Either<Failure, EventTally>>? _tallySub;
  bool _isAdmin = false;

  /// [initial] (do feed) aparece na hora, antes do primeiro dado.
  void start({required String id, NewsDTO? initial, String? userId, bool isAdmin = false}) {
    _isAdmin = isAdmin;
    if (initial != null) emit(state.copyWith(news: initial, loading: false));
    _cardSub?.cancel();
    _cardSub = eventPollUseCase.watch(id).listen((response) {
      if (isClosed) return;
      response.fold(
        (failure) =>
            emit(state.copyWith(loading: false).withNotice(EventPollNotice.error, message: failure.toString())),
        (news) {
          if (news == null) {
            emit(state.copyWith(loading: false, notFound: true));
            return;
          }
          emit(state.copyWith(news: news, loading: false));
          _followTally(id);
        },
      );
    });
    _voteSub?.cancel();
    if (userId != null && userId.isNotEmpty) {
      _voteSub = eventPollUseCase.watchMyVote(eventId: id, userId: userId).listen((response) {
        if (isClosed) return;
        response.fold((_) {}, (vote) {
          if (vote != null) emit(state.copyWith(myVote: vote));
        });
      });
    }
    if (initial != null) _followTally(id);
  }

  /// A apuração só é ouvida quando as regras deixam ler (parcial ligado,
  /// encerrado ou admin): sem leitura negada à toa.
  void _followTally(String id) {
    if (_tallySub != null) return;
    if (!_isAdmin && !state.event.resultVisibleAt(now())) return;
    _tallySub = eventPollUseCase.watchTally(id).listen((response) {
      if (isClosed) return;
      response.fold((_) {}, (tally) => emit(state.copyWith(tally: tally)));
    });
  }

  /// Voto único na opção [optionId].
  Future<void> vote({required String optionId, required String userId, required String name}) async {
    final news = state.news;
    if (news == null || state.voting || state.hasVoted || !state.event.isOpenAt(now())) return;
    emit(state.copyWith(voting: true));
    final response = await eventPollUseCase.vote(eventId: news.id, userId: userId, optionId: optionId, name: name);
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.withNotice(EventPollNotice.error, message: failure.toString())),
      (_) => emit(state.copyWith(myVote: optionId).withNotice(EventPollNotice.voted)),
    );
  }

  /// "Encerrar agora" (admin).
  Future<void> closeEvent() async {
    final news = state.news;
    if (news == null) return;
    final response = await eventPollUseCase.close(news.id);
    if (isClosed) return;
    response.fold(
      (failure) => emit(state.withNotice(EventPollNotice.error, message: failure.toString())),
      (_) => emit(state.withNotice(EventPollNotice.closed)),
    );
  }

  /// O prazo passou com a tela aberta: passa a ouvir a apuração.
  void tick() {
    final id = state.news?.id;
    if (id != null) _followTally(id);
  }

  @override
  Future<void> close() async {
    await _cardSub?.cancel();
    await _voteSub?.cancel();
    await _tallySub?.cancel();
    return super.close();
  }
}
