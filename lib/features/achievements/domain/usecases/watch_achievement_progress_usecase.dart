import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_progress_dto.dart';
import 'package:arena_soccer/features/achievements/domain/repositories/achievements_repository_interface.dart';

/// Contadores do usuário (doc ausente = tudo zero).
class WatchAchievementProgressUseCase {
  final IAchievementsRepository _repository;

  WatchAchievementProgressUseCase(this._repository);

  Stream<Either<Failure, AchievementProgressDTO>> call(String uid) => _repository.watchProgress(uid);
}
