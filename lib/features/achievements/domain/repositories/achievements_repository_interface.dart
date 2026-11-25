import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_progress_dto.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';

abstract class IAchievementsRepository {
  Stream<Either<Failure, List<AchievementDTO>>> watchCatalog();

  /// Catálogo numa leitura só (ver [getCachedCatalog]).
  Future<Either<Failure, List<AchievementDTO>>> getCatalog();

  /// Catálogo do cache local (nunca falha: sem cache = `Right(null)`).
  Future<Either<Failure, CachedValue<List<AchievementDTO>>?>> getCachedCatalog();

  Future<Either<Failure, void>> saveCatalogCache(List<AchievementDTO> catalog);

  /// Apaga o catálogo do cache (as gravações do admin já fazem isso).
  Future<void> deleteCatalogCache();

  Stream<Either<Failure, AchievementProgressDTO>> watchProgress(String uid);

  Stream<Either<Failure, List<AchievementUnlockDTO>>> watchUnlocks(String uid);

  Future<Either<Failure, void>> saveAchievement(AchievementDTO achievement);

  Future<Either<Failure, void>> deleteAchievement(String id);

  Future<Either<Failure, void>> createAchievements(List<AchievementDTO> achievements);

  Future<Either<Failure, void>> increment(String uid, AchievementMetric metric);

  Future<Either<Failure, void>> recordVisit(
    String uid, {
    required int activeDays,
    required int streak,
    required int bestStreak,
  });

  Future<Either<Failure, void>> markSeen(String uid, String achievementId);
}
