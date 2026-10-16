import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_cached_goal_cards_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_player_goal_cards_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/save_goal_cards_cache_usecase.dart';

/// Participações do jogador (cards de gol) pelo fluxo [cacheFirst] (validade
/// [CacheTtl.ranking], a mesma dos números do jogador).
class GetPlayerGoalCardsCacheFirstUseCase {
  final GetPlayerGoalCardsUseCase _getGoalCards;
  final GetCachedGoalCardsUseCase _getCached;
  final SaveGoalCardsCacheUseCase _saveCache;

  GetPlayerGoalCardsCacheFirstUseCase(this._getGoalCards, this._getCached, this._saveCache);

  Stream<Either<Failure, List<NewsDTO>>> call(String playerId, {bool force = false}) => cacheFirst<List<NewsDTO>>(
        readCache: () => _getCached(playerId),
        fetchRemote: () => _getGoalCards(playerId),
        saveCache: (cards) => _saveCache(playerId, cards),
        ttl: CacheTtl.ranking,
        force: force,
        logName: 'GetPlayerGoalCardsCacheFirstUseCase',
      );
}
