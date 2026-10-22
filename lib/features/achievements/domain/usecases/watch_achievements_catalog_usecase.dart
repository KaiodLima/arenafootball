import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/domain/repositories/achievements_repository_interface.dart';

/// Catálogo de conquistas (todas, ativas ou não; a tela filtra as ativas).
class WatchAchievementsCatalogUseCase {
  final IAchievementsRepository _repository;

  WatchAchievementsCatalogUseCase(this._repository);

  Stream<Either<Failure, List<AchievementDTO>>> call() => _repository.watchCatalog();
}
