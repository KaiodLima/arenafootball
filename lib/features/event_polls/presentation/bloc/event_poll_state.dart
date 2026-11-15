import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

/// Avisos de uma vez só (snackbar): voto registrado, evento encerrado, erro.
enum EventPollNotice { voted, closed, error }

class EventPollState extends Equatable {
  /// O card do evento (notícia `tag: "evento"`); nulo enquanto carrega.
  final NewsDTO? news;

  /// Id da opção em que a conta votou; nulo = ainda não votou.
  final String? myVote;

  /// Apuração; nula enquanto não pode ser lida (parcial desligado e aberto).
  final EventTally? tally;
  final bool loading;
  final bool notFound;
  final bool voting;

  final EventPollNotice? notice;
  final String errorMessage;

  /// Muda a cada aviso (dois avisos iguais seguidos também disparam).
  final int noticeSeq;

  const EventPollState({
    this.news,
    this.myVote,
    this.tally,
    this.loading = true,
    this.notFound = false,
    this.voting = false,
    this.notice,
    this.errorMessage = '',
    this.noticeSeq = 0,
  });

  EventPoll get event => news?.event ?? const EventPoll();

  bool get hasVoted => myVote != null;

  EventPollState copyWith({
    NewsDTO? news,
    String? myVote,
    EventTally? tally,
    bool? loading,
    bool? notFound,
    bool? voting,
  }) =>
      EventPollState(
        news: news ?? this.news,
        myVote: myVote ?? this.myVote,
        tally: tally ?? this.tally,
        loading: loading ?? this.loading,
        notFound: notFound ?? this.notFound,
        voting: voting ?? this.voting,
        errorMessage: errorMessage,
        noticeSeq: noticeSeq,
      );

  /// O mesmo estado com um aviso novo.
  EventPollState withNotice(EventPollNotice notice, {String message = ''}) => EventPollState(
        news: news,
        myVote: myVote,
        tally: tally,
        loading: loading,
        notFound: notFound,
        voting: false,
        notice: notice,
        errorMessage: message,
        noticeSeq: noticeSeq + 1,
      );

  @override
  List<Object?> get props => [news, myVote, tally, loading, notFound, voting, notice, errorMessage, noticeSeq];
}
