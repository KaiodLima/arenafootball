import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/stats/domain/repositories/stats_repository_interface.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';

class StatsRepositoryImpl implements IStatsRepository {
  final CacheStore _cache;

  StatsRepositoryImpl(this._cache);

  @override
  Future<Either<Failure, CachedValue<StatsRanking>?>> getCachedRanking({
    required StatsRankingType type,
    required String region,
    String? season,
  }) =>
      _cache.read(
        CacheKeys.ranking(type: type.name, region: region, season: season),
        (json) => StatsRanking.fromCache(Map<String, dynamic>.from(json as Map)),
      );

  @override
  Future<Either<Failure, void>> saveRankingCache(
    StatsRanking ranking, {
    required StatsRankingType type,
    required String region,
    String? season,
  }) =>
      _cache.save(CacheKeys.ranking(type: type.name, region: region, season: season), ranking.toCache());

  @override
  Future<void> deleteRankingCache() => _cache.deleteWhere(CacheKeys.isRankingKey);
}
