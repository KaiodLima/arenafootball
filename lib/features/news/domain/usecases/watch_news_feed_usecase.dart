import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

/// Feed de notícias da região, já filtrado para exibição.
class WatchNewsFeedUseCase {
  final INewsRepository _repository;

  WatchNewsFeedUseCase(this._repository);

  Stream<Either<Failure, List<NewsDTO>>> call({String? region}) {
    return _repository.watchNews(region: region).map((response) => response.map(_visibleInFeed));
  }

  /// Cards de gol e de publicidade só aparecem com `exibir == "true"`.
  /// Notícias comuns aparecem sempre (comportamento do app antigo).
  static List<NewsDTO> _visibleInFeed(List<NewsDTO> news) {
    return news.where((item) => (item.isGoal || item.isAd) ? item.isVisible : true).toList();
  }
}
