import 'package:either_dart/either.dart';
import 'package:arena_soccer/features/news/data/dtos/pending_news_dto.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

abstract class INewsRepository {
  /// Primeira página do feed, ao vivo (mais recentes primeiro).
  Stream<Either<Failure, List<NewsDTO>>> watchNews({String? region, int limit = 20});

  /// Página seguinte do feed (leitura única), depois da notícia [afterNewsId].
  Future<Either<Failure, List<NewsDTO>>> getNewsPage({String? region, required String afterNewsId, int limit = 20});

  Stream<Either<Failure, List<NewsDTO>>> watchNewsByTag(String tag);

  Future<Either<Failure, NewsDTO?>> getNewsById(String id);

  Future<Either<Failure, void>> createNews(NewsDTO news);

  Future<Either<Failure, void>> updateNews(NewsDTO news);

  Future<Either<Failure, void>> deleteNews(String id);

  Future<Either<Failure, void>> createPendingNews(NewsDTO news);

  Stream<Either<Failure, List<PendingNewsDTO>>> watchMyPendingNews(String authorId);

  Stream<Either<Failure, List<PendingNewsDTO>>> watchPendingNews();

  Future<Either<Failure, void>> approvePendingNews(PendingNewsDTO pending);

  Future<Either<Failure, void>> rejectPendingNews({required String id, required String reason});

  Future<Either<Failure, void>> deletePendingNews(String id);

  Future<Either<Failure, List<NewsDTO>>> getGoalCardsByPlayer(String playerId);

  /// Cache local dos cards de gol do jogador. Nunca falha: sem cache = `Right(null)`.
  Future<Either<Failure, CachedValue<List<NewsDTO>>?>> getCachedGoalCards(String playerId);

  Future<Either<Failure, void>> saveGoalCardsCache(String playerId, List<NewsDTO> cards);

  /// Apaga o cache de cards de gol de todos os jogadores.
  Future<void> deleteGoalCardsCache();

  /// Cache local de uma notícia pelo id (`data` nulo = não existe).
  Future<Either<Failure, CachedValue<NewsDTO?>?>> getCachedNews(String id);

  Future<Either<Failure, void>> saveNewsCache(String id, NewsDTO? news);

  Future<void> deleteNewsCache(String id);
}
