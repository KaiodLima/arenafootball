import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/domain/repositories/achievements_repository_interface.dart';
import 'package:arena_soccer/features/achievements/domain/suggested_achievements.dart';

/// Admin cria as conquistas sugeridas ([suggestedAchievements]) de uma vez.
class CreateSuggestedAchievementsUseCase {
  final IAchievementsRepository _repository;

  CreateSuggestedAchievementsUseCase(this._repository);

  Future<Either<Failure, void>> call() => _repository.createAchievements(suggestedAchievements());
}
