import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

class SaveGoalCardsCacheUseCase {
  final INewsRepository _repository;

  SaveGoalCardsCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(String playerId, List<NewsDTO> cards) =>
      _repository.saveGoalCardsCache(playerId, cards);
}
