import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

/// Tamanho de cada página do feed (a primeira, ao vivo, e as antigas).
const int newsFeedPageSize = 20;

/// Uma página do feed já filtrada para exibição. [lastId] é o último item
/// cru da consulta (cursor da próxima página, mesmo que esteja oculto) e
/// [hasMore] diz se a consulta veio cheia (pode haver mais).
class NewsFeedPage {
  final List<NewsDTO> news;
  final String? lastId;
  final bool hasMore;

  const NewsFeedPage({required this.news, this.lastId, this.hasMore = false});

  factory NewsFeedPage.fromRaw(List<NewsDTO> raw, {required int limit}) {
    return NewsFeedPage(
      news: raw.where(_visibleInFeed).toList(),
      lastId: raw.isEmpty ? null : raw.last.id,
      hasMore: raw.length >= limit,
    );
  }

  /// Cards de gol e de publicidade só aparecem com `exibir == "true"`.
  /// Notícias comuns aparecem sempre (comportamento do app antigo).
  static bool _visibleInFeed(NewsDTO item) => (item.isGoal || item.isAd) ? item.isVisible : true;
}
