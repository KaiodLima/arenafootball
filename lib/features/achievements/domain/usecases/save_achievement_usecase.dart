import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/domain/repositories/achievements_repository_interface.dart';

/// Admin cria (sem id) ou edita uma conquista.
class SaveAchievementUseCase {
  final IAchievementsRepository _repository;

  SaveAchievementUseCase(this._repository);

  Future<Either<Failure, void>> call(AchievementDTO achievement) => _repository.saveAchievement(achievement);
}
