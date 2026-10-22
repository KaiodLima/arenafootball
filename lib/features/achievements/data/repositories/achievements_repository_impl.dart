import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_progress_dto.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/features/achievements/data/datasources/achievements_datasource.dart';
import 'package:arena_soccer/features/achievements/domain/repositories/achievements_repository_interface.dart';

class AchievementsRepositoryImpl implements IAchievementsRepository {
  final AchievementsDataSource _dataSource;

  AchievementsRepositoryImpl(this._dataSource);

  @override
  Stream<Either<Failure, List<AchievementDTO>>> watchCatalog() => _dataSource.watchCatalog();

  @override
  Stream<Either<Failure, AchievementProgressDTO>> watchProgress(String uid) => _dataSource.watchProgress(uid);

  @override
  Stream<Either<Failure, List<AchievementUnlockDTO>>> watchUnlocks(String uid) => _dataSource.watchUnlocks(uid);

  @override
  Future<Either<Failure, void>> saveAchievement(AchievementDTO achievement) => _dataSource.saveAchievement(achievement);

  @override
  Future<Either<Failure, void>> deleteAchievement(String id) => _dataSource.deleteAchievement(id);

  @override
  Future<Either<Failure, void>> createAchievements(List<AchievementDTO> achievements) =>
      _dataSource.createAchievements(achievements);

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
}
