import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_match_dto.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';
import 'package:arena_soccer/features/global_results/domain/repositories/global_results_repository_interface.dart';

class SaveGlobalResultsCacheUseCase {
  final IGlobalResultsRepository _repository;

  SaveGlobalResultsCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(ResultsDay day, List<ScrapedMatchDTO> matches) =>
      _repository.saveMatchesCache(day, matches);
}
