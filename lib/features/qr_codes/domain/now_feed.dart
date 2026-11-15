import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/predictions/domain/prediction_hub.dart';

/// O que vai em destaque no topo de "Acontecendo agora" (nesta ordem de
/// prioridade): votação do craque aberta, partida ao vivo, evento de votação
/// aberto, próxima partida (palpite) e, sem nada disso, o bolão.
enum NowHighlight { vote, live, event, upcoming, pool }

/// O que está ativo agora numa região (QR fixo `/agora/<idRegiao>`).
class NowFeed extends Equatable {
  final List<MatchDTO> votes;
  final List<MatchDTO> live;
  final List<NewsDTO> events;
  final List<MatchDTO> upcoming;

  const NowFeed({this.votes = const [], this.live = const [], this.events = const [], this.upcoming = const []});

  /// Separa e ordena (votações e ao vivo: as mais recentes; próximas: as mais
  /// cedo, até 6). Só os eventos da [region] abertos e visíveis.
  factory NowFeed.of({
    required List<MatchDTO> matches,
    required List<NewsDTO> news,
    required String region,
    required DateTime now,
  }) {
    final votes = PredictionHub.byKickoff(matches.where((m) => m.isVotingOpen), now, descending: true);
    final live = PredictionHub.byKickoff(
      matches.where((m) {
        final status = MatchCardStatus.of(m, now);
        return status.live || status.halfTime;
      }),
      now,
      descending: true,
    );
    final upcoming = PredictionHub.byKickoff(
      matches.where((m) => MatchCardStatus.of(m, now).upcoming && PredictionHub.kickoffOf(m, now) != null),
      now,
    ).take(PredictionHub.upcomingLimit).toList();
    final events =
        news.where((n) => n.isEvent && n.isVisible && n.region == region && (n.event?.isOpenAt(now) ?? false)).toList();
    return NowFeed(votes: votes, live: live, events: events, upcoming: upcoming);
  }

  NowHighlight get highlight {
    if (votes.isNotEmpty) return NowHighlight.vote;
    if (live.isNotEmpty) return NowHighlight.live;
    if (events.isNotEmpty) return NowHighlight.event;
    if (upcoming.isNotEmpty) return NowHighlight.upcoming;
    return NowHighlight.pool;
  }

  /// Nada de votação, jogo ao vivo nem evento (só bolão/próximos).
  bool get quiet => votes.isEmpty && live.isEmpty && events.isEmpty;

  @override
  List<Object?> get props => [votes, live, events, upcoming];
}
