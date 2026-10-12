import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

/// Cards de gol em que o jogador marcou ou deu o passe (mais recentes
/// primeiro).
class GetPlayerGoalCardsUseCase {
  final INewsRepository _repository;

  GetPlayerGoalCardsUseCase(this._repository);

  Future<Either<Failure, List<NewsDTO>>> call(String playerId) => _repository.getGoalCardsByPlayer(playerId);
}
