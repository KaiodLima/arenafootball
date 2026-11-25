import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_progress_dto.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/features/achievements/data/datasources/achievements_datasource.dart';
import 'package:arena_soccer/features/achievements/domain/repositories/achievements_repository_interface.dart';

class AchievementsRepositoryImpl implements IAchievementsRepository {
  final AchievementsDataSource _dataSource;
  final CacheStore _cache;

  AchievementsRepositoryImpl(this._dataSource, this._cache);

  @override
  Stream<Either<Failure, List<AchievementDTO>>> watchCatalog() => _dataSource.watchCatalog();

  @override
  Future<Either<Failure, List<AchievementDTO>>> getCatalog() => _dataSource.getCatalog();

  @override
  Future<Either<Failure, CachedValue<List<AchievementDTO>>?>> getCachedCatalog() => _cache.read(
        CacheKeys.achievementsCatalog,
        (json) => [for (final item in json as List) AchievementDTO.fromCache(Map<String, dynamic>.from(item as Map))],
      );

  @override
  Future<Either<Failure, void>> saveCatalogCache(List<AchievementDTO> catalog) =>
      _cache.save(CacheKeys.achievementsCatalog, [for (final achievement in catalog) achievement.toCache()]);

  @override
  Future<void> deleteCatalogCache() => _cache.delete(CacheKeys.achievementsCatalog);

  @override
  Stream<Either<Failure, AchievementProgressDTO>> watchProgress(String uid) => _dataSource.watchProgress(uid);

  @override
  Stream<Either<Failure, List<AchievementUnlockDTO>>> watchUnlocks(String uid) => _dataSource.watchUnlocks(uid);

  @override
  Future<Either<Failure, void>> saveAchievement(AchievementDTO achievement) async =>
      _invalidate(await _dataSource.saveAchievement(achievement));

  @override
  Future<Either<Failure, void>> deleteAchievement(String id) async =>
      _invalidate(await _dataSource.deleteAchievement(id));

  @override
  Future<Either<Failure, void>> createAchievements(List<AchievementDTO> achievements) async =>
      _invalidate(await _dataSource.createAchievements(achievements));

  @override
  Future<Either<Failure, void>> increment(String uid, AchievementMetric metric) => _dataSource.increment(uid, metric);

  @override
  Future<Either<Failure, void>> recordVisit(
    String uid, {
    required int activeDays,
    required int streak,
    required int bestStreak,
  }) =>
      _dataSource.recordVisit(uid, activeDays: activeDays, streak: streak, bestStreak: bestStreak);

  @override
  Future<Either<Failure, void>> markSeen(String uid, String achievementId) => _dataSource.markSeen(uid, achievementId);

  /// Depois de o admin gravar o catálogo: o cache fica velho.
  Future<Either<Failure, void>> _invalidate(Either<Failure, void> response) async {
    if (response.isRight) await deleteCatalogCache();
    return response;
  }
}
