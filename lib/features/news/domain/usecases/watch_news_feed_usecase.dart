import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/domain/news_feed_page.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

/// Primeira página do feed da região, ao vivo e já filtrada para exibição.
class WatchNewsFeedUseCase {
  final INewsRepository _repository;

  WatchNewsFeedUseCase(this._repository);

  Stream<Either<Failure, NewsFeedPage>> call({String? region, int limit = newsFeedPageSize}) {
    return _repository
        .watchNews(region: region, limit: limit)
        .map((response) => response.map((raw) => NewsFeedPage.fromRaw(raw, limit: limit)));
  }
}
