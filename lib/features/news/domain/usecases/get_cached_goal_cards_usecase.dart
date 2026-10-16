import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

/// Cards de gol do jogador no cache local (nunca falha: sem cache = `Right(null)`).
class GetCachedGoalCardsUseCase {
  final INewsRepository _repository;

  GetCachedGoalCardsUseCase(this._repository);

  Future<Either<Failure, CachedValue<List<NewsDTO>>?>> call(String playerId) =>
      _repository.getCachedGoalCards(playerId);
}
