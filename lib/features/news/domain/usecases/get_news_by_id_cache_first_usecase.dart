import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_cached_news_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_news_by_id_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/save_news_cache_usecase.dart';

/// Notícia de um deep link pelo fluxo [cacheFirst] (validade
/// [CacheTtl.highlights]). `null` = não existe mais.
class GetNewsByIdCacheFirstUseCase {
  final GetNewsByIdUseCase _getNews;
  final GetCachedNewsUseCase _getCached;
  final SaveNewsCacheUseCase _saveCache;

  GetNewsByIdCacheFirstUseCase(this._getNews, this._getCached, this._saveCache);

  Stream<Either<Failure, NewsDTO?>> call(String id, {bool force = false}) => cacheFirst<NewsDTO?>(
        readCache: () => _getCached(id),
        fetchRemote: () => _getNews(id),
        saveCache: (news) => _saveCache(id, news),
        ttl: CacheTtl.highlights,
        force: force,
        logName: 'GetNewsByIdCacheFirstUseCase',
      );
}
