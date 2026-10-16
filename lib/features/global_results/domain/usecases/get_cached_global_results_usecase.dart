import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_match_dto.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';
import 'package:arena_soccer/features/global_results/domain/repositories/global_results_repository_interface.dart';

/// Partidas do dia no cache local, ainda cruas (nunca falha: sem cache = `Right(null)`).
class GetCachedGlobalResultsUseCase {
  final IGlobalResultsRepository _repository;

  GetCachedGlobalResultsUseCase(this._repository);

  Future<Either<Failure, CachedValue<List<ScrapedMatchDTO>>?>> call(ResultsDay day) =>
      _repository.getCachedMatches(day);
}
