import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/domain/repositories/achievements_repository_interface.dart';

/// O usuário viu a comemoração da conquista.
class MarkAchievementSeenUseCase {
  final IAchievementsRepository _repository;

  MarkAchievementSeenUseCase(this._repository);

  Future<Either<Failure, void>> call(String uid, String achievementId) => _repository.markSeen(uid, achievementId);
}
