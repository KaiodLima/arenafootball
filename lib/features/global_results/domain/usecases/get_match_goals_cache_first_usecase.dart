import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_match_dto.dart';
import 'package:arena_soccer/features/global_results/domain/entities/global_match.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_cached_match_goals_usecase.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_global_results_usecase.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_match_goals_usecase.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/save_match_goals_cache_usecase.dart';

/// Gols de um jogo encerrado pelo fluxo [cacheFirst] (validade
/// [CacheTtl.globalResults]).
class GetMatchGoalsCacheFirstUseCase {
  final GetMatchGoalsUseCase _getGoals;
  final GetCachedMatchGoalsUseCase _getCached;
  final SaveMatchGoalsCacheUseCase _saveCache;

  GetMatchGoalsCacheFirstUseCase(this._getGoals, this._getCached, this._saveCache);

  Stream<Either<Failure, List<GoalEvent>>> call(String url, {bool force = false}) => cacheFirst<List<ScrapedGoalDTO>>(
        readCache: () => _getCached(url),
        fetchRemote: () => _getGoals.scrape(url),
        saveCache: (goals) => _saveCache(url, goals),
        ttl: CacheTtl.globalResults,
        force: force,
        logName: 'GetMatchGoalsCacheFirstUseCase',
      ).map((response) => response.map(GetGlobalResultsUseCase.goalsOf));
}
