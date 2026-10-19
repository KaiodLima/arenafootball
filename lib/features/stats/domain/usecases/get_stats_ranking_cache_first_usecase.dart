import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_cached_stats_ranking_usecase.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_stats_ranking_usecase.dart';
import 'package:arena_soccer/features/stats/domain/usecases/save_stats_ranking_cache_usecase.dart';

/// Ranking pelo fluxo [cacheFirst] (validade [CacheTtl.ranking]).
class GetStatsRankingCacheFirstUseCase {
  final GetStatsRankingUseCase _getRanking;
  final GetCachedStatsRankingUseCase _getCached;
  final SaveStatsRankingCacheUseCase _saveCache;

  GetStatsRankingCacheFirstUseCase(this._getRanking, this._getCached, this._saveCache);

  Stream<Either<Failure, StatsRanking>> call({
    required StatsRankingType type,
    required String region,
    String? season,
    int? championshipId,
    bool force = false,
  }) =>
      cacheFirst<StatsRanking>(
        readCache: () => _getCached(type: type, region: region, season: season, championshipId: championshipId),
        fetchRemote: () => _getRanking(type: type, region: region, season: season, championshipId: championshipId),
        saveCache: (ranking) =>
            _saveCache(ranking, type: type, region: region, season: season, championshipId: championshipId),
        ttl: CacheTtl.ranking,
        force: force,
        logName: 'GetStatsRankingCacheFirstUseCase',
      );
}
