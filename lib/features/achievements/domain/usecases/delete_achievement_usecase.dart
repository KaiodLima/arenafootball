import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/domain/repositories/achievements_repository_interface.dart';

/// Admin exclui uma conquista do catálogo.
class DeleteAchievementUseCase {
  final IAchievementsRepository _repository;

  DeleteAchievementUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) => _repository.deleteAchievement(id);
}
