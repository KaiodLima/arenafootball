import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/domain/repositories/achievements_repository_interface.dart';

class SaveAchievementsCatalogCacheUseCase {
  final IAchievementsRepository _repository;

  SaveAchievementsCatalogCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(List<AchievementDTO> catalog) => _repository.saveCatalogCache(catalog);
}
