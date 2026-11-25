import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/domain/repositories/achievements_repository_interface.dart';

/// Catálogo de conquistas do cache local (nunca falha: sem cache = `Right(null)`).
class GetCachedAchievementsCatalogUseCase {
  final IAchievementsRepository _repository;

  GetCachedAchievementsCatalogUseCase(this._repository);

  Future<Either<Failure, CachedValue<List<AchievementDTO>>?>> call() => _repository.getCachedCatalog();
}
