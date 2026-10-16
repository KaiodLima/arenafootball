import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_match_dto.dart';
import 'package:arena_soccer/features/global_results/domain/repositories/global_results_repository_interface.dart';

/// Gols de um jogo no cache local, ainda crus (nunca falha: sem cache = `Right(null)`).
class GetCachedMatchGoalsUseCase {
  final IGlobalResultsRepository _repository;

  GetCachedMatchGoalsUseCase(this._repository);

  Future<Either<Failure, CachedValue<List<ScrapedGoalDTO>>?>> call(String url) => _repository.getCachedMatchGoals(url);
}
