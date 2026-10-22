import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_progress_dto.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';

abstract class IAchievementsRepository {
  Stream<Either<Failure, List<AchievementDTO>>> watchCatalog();

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
