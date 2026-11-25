import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/get_achievements_catalog_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/get_cached_achievements_catalog_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/save_achievements_catalog_cache_usecase.dart';

/// Catálogo de conquistas pelo fluxo [cacheFirst] (validade
/// [CacheTtl.achievementsCatalog]): o catálogo quase não muda, então o app
/// não fica ouvindo a coleção inteira. Gravar/apagar pelo admin apaga o cache.
class GetAchievementsCatalogCacheFirstUseCase {
  final GetAchievementsCatalogUseCase _getCatalog;
  final GetCachedAchievementsCatalogUseCase _getCached;
  final SaveAchievementsCatalogCacheUseCase _saveCache;

  GetAchievementsCatalogCacheFirstUseCase(this._getCatalog, this._getCached, this._saveCache);

  Stream<Either<Failure, List<AchievementDTO>>> call({bool force = false}) => cacheFirst<List<AchievementDTO>>(
        readCache: _getCached.call,
        fetchRemote: _getCatalog.call,
        saveCache: _saveCache.call,
        ttl: CacheTtl.achievementsCatalog,
        force: force,
        logName: 'GetAchievementsCatalogCacheFirstUseCase',
      );
}
