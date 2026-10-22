import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_progress_dto.dart';
import 'package:arena_soccer/features/achievements/domain/repositories/achievements_repository_interface.dart';

/// Conquistas que o servidor desbloqueou para o usuário.
class WatchAchievementUnlocksUseCase {
  final IAchievementsRepository _repository;

  WatchAchievementUnlocksUseCase(this._repository);

  Stream<Either<Failure, List<AchievementUnlockDTO>>> call(String uid) => _repository.watchUnlocks(uid);
}
