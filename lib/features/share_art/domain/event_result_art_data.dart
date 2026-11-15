import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

/// Uma opção já apurada: posição (empate = mesma posição), votos e %.
class EventResultEntry extends Equatable {
  final EventPollOption option;

  /// Número da opção no evento (1, 2, 3…), para o quadro sem foto.
  final int number;
  final int position;
  final int votes;
  final int percent;

  /// Fração (0–1) para as barras.
  final double share;
  final bool winner;

  const EventResultEntry({
    required this.option,
    required this.number,
    required this.position,
    required this.votes,
    required this.percent,
    required this.share,
    required this.winner,
  });

  @override
  List<Object?> get props => [option, number, position, votes, percent, share, winner];
}

/// Dados da arte do resultado do evento de votação (sem leitura: o card e a
/// apuração que a página já tem).
class EventResultArtData extends Equatable {
  final String eventId;
  final String title;
  final String description;
  final DateTime? closedAt;

  /// Opções da mais votada para a menos (empate: a ordem do evento).
  final List<EventResultEntry> entries;
  final int total;

  /// Link do evento (QR e texto de compartilhar).
  final String link;

  const EventResultArtData({
    required this.eventId,
    required this.title,
    this.description = '',
    this.closedAt,
    this.entries = const [],
    this.total = 0,
    this.link = '',
  });

  /// Vencedoras (empate = várias); sem votos, nenhuma.
  List<EventResultEntry> get winners => entries.where((e) => e.winner).toList();

  bool get tie => winners.length > 1;

  factory EventResultArtData.of(NewsDTO news, EventTally tally) {
    final event = news.event ?? const EventPoll();
    final winners = tally.winners();
    final numbered = [
      for (var i = 0; i < event.options.length; i++) (option: event.options[i], number: i + 1),
    ];
    // Mais votos primeiro; empate fica na ordem do evento (sort estável pelo número).
    numbered.sort((a, b) {
      final byVotes = tally.votesOf(b.option.id).compareTo(tally.votesOf(a.option.id));
      return byVotes != 0 ? byVotes : a.number.compareTo(b.number);
    });
    final entries = <EventResultEntry>[];
    for (var i = 0; i < numbered.length; i++) {
      final item = numbered[i];
      final votes = tally.votesOf(item.option.id);
      // Posição de competição: empatados dividem a posição (1, 1, 3).
      final position = i > 0 && votes == entries[i - 1].votes ? entries[i - 1].position : i + 1;
      entries.add(EventResultEntry(
        option: item.option,
        number: item.number,
        position: position,
        votes: votes,
        percent: tally.percentOf(item.option.id),
        share: tally.shareOf(item.option.id),
        winner: winners.contains(item.option.id),
      ));
    }
    return EventResultArtData(
      eventId: news.id,
      title: news.title,
      description: news.description,
      closedAt: event.closesAt,
      entries: entries,
      total: tally.total,
      link: news.id.isEmpty ? '' : newsLink(news.id),
    );
  }

  @override
  List<Object?> get props => [eventId, title, description, closedAt, entries, total, link];
}
