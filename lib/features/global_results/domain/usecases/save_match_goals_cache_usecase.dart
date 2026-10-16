import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_match_dto.dart';
import 'package:arena_soccer/features/global_results/domain/repositories/global_results_repository_interface.dart';

class SaveMatchGoalsCacheUseCase {
  final IGlobalResultsRepository _repository;

  SaveMatchGoalsCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(String url, List<ScrapedGoalDTO> goals) =>
      _repository.saveMatchGoalsCache(url, goals);
}
