import 'package:either_dart/either.dart';
import 'package:arena_soccer/features/news/data/dtos/pending_news_dto.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/datasources/news_datasource.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

class NewsRepositoryImpl implements INewsRepository {
  final NewsDataSource _dataSource;
  final CacheStore _cache;

  NewsRepositoryImpl(this._dataSource, this._cache);

  @override
  Stream<Either<Failure, List<NewsDTO>>> watchNews({String? region, int limit = 20}) =>
      _dataSource.watchNews(region: region, limit: limit);

  @override
  Future<Either<Failure, List<NewsDTO>>> getNewsPage({String? region, required String afterNewsId, int limit = 20}) =>
      _dataSource.getNewsPage(region: region, afterNewsId: afterNewsId, limit: limit);

  @override
  Stream<Either<Failure, List<NewsDTO>>> watchNewsByTag(String tag) => _dataSource.watchNewsByTag(tag);

  @override
  Future<Either<Failure, NewsDTO?>> getNewsById(String id) => _dataSource.getNewsById(id);

  @override
  Future<Either<Failure, void>> createNews(NewsDTO news) async => _invalidate(await _dataSource.createNews(news));

  @override
  Future<Either<Failure, void>> createPendingNews(NewsDTO news) => _dataSource.createPendingNews(news);

  @override
  Stream<Either<Failure, List<PendingNewsDTO>>> watchMyPendingNews(String authorId) =>
      _dataSource.watchMyPendingNews(authorId);

  @override
  Stream<Either<Failure, List<PendingNewsDTO>>> watchPendingNews() => _dataSource.watchPendingNews();

  @override
  Future<Either<Failure, void>> approvePendingNews(PendingNewsDTO pending) async =>
      _invalidate(await _dataSource.approvePendingNews(pending));

  @override
  Future<Either<Failure, void>> rejectPendingNews({required String id, required String reason}) =>
      _dataSource.rejectPendingNews(id: id, reason: reason);

  @override
  Future<Either<Failure, void>> deletePendingNews(String id) => _dataSource.deletePendingNews(id);

  @override
  Future<Either<Failure, void>> updateNews(NewsDTO news) async =>
      _invalidate(await _dataSource.updateNews(news), newsId: news.id);

  @override
  Future<Either<Failure, void>> deleteNews(String id) async =>
      _invalidate(await _dataSource.deleteNews(id), newsId: id);

  @override
  Future<Either<Failure, List<NewsDTO>>> getGoalCardsByPlayer(String playerId) =>
      _dataSource.getGoalCardsByPlayer(playerId);

  @override
  Future<Either<Failure, CachedValue<List<NewsDTO>>?>> getCachedGoalCards(String playerId) => _cache.read(
        CacheKeys.goalCards(playerId),
        (json) => [for (final item in json as List) NewsDTO.fromCache(Map<String, dynamic>.from(item as Map))],
      );

  @override
  Future<Either<Failure, void>> saveGoalCardsCache(String playerId, List<NewsDTO> cards) =>
      _cache.save(CacheKeys.goalCards(playerId), [for (final card in cards) card.toCache()]);

  @override
  Future<void> deleteGoalCardsCache() => _cache.deleteWhere(CacheKeys.isGoalCardsKey);

  @override
  Future<Either<Failure, CachedValue<NewsDTO?>?>> getCachedNews(String id) => _cache.read(
        CacheKeys.news(id),
        (json) => json == null ? null : NewsDTO.fromCache(Map<String, dynamic>.from(json as Map)),
      );

  @override
  Future<Either<Failure, void>> saveNewsCache(String id, NewsDTO? news) =>
      _cache.save(CacheKeys.news(id), news?.toCache());

  @override
  Future<void> deleteNewsCache(String id) async {
    await _cache.delete(CacheKeys.news(id));
  }

  /// Depois de gravar uma notícia: os cards de gol por jogador (e a própria
  /// notícia, em edição/exclusão) ficam velhos no cache.
  Future<Either<Failure, void>> _invalidate(Either<Failure, void> response, {String newsId = ''}) async {
    if (response.isRight) {
      await deleteGoalCardsCache();
      if (newsId.isNotEmpty) await deleteNewsCache(newsId);
    }
    return response;
  }
}
