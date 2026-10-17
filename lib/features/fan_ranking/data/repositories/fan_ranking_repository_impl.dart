import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/fan_ranking/data/datasources/fan_ranking_datasource.dart';
import 'package:arena_soccer/features/fan_ranking/data/dtos/fan_ranking_dto.dart';
import 'package:arena_soccer/features/fan_ranking/domain/repositories/fan_ranking_repository_interface.dart';

class FanRankingRepositoryImpl implements IFanRankingRepository {
  final FanRankingDataSource _dataSource;
  final CacheStore _cache;

  FanRankingRepositoryImpl(this._dataSource, this._cache);

  @override
  Future<Either<Failure, FanRankingDTO>> getRanking(String season) => _dataSource.getRanking(season);

  @override
  Future<Either<Failure, CachedValue<FanRankingDTO>?>> getCachedRanking(String season) => _cache.read<FanRankingDTO>(
        CacheKeys.fanRanking(season),
        (json) => FanRankingDTO.fromCache(Map<String, dynamic>.from(json as Map)),
      );

  @override
  Future<Either<Failure, void>> saveRankingCache(FanRankingDTO ranking) =>
      _cache.save(CacheKeys.fanRanking(ranking.season), ranking.toCache());
}
