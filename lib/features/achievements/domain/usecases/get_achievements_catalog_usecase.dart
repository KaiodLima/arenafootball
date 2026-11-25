import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/domain/repositories/achievements_repository_interface.dart';

/// Catálogo de conquistas numa leitura só (sem cache).
class GetAchievementsCatalogUseCase {
  final IAchievementsRepository _repository;

  GetAchievementsCatalogUseCase(this._repository);

  Future<Either<Failure, List<AchievementDTO>>> call() => _repository.getCatalog();
}
