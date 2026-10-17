import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/fan_ranking/data/dtos/fan_ranking_dto.dart';

abstract class IFanRankingRepository {
  Future<Either<Failure, FanRankingDTO>> getRanking(String season);

  Future<Either<Failure, CachedValue<FanRankingDTO>?>> getCachedRanking(String season);

  Future<Either<Failure, void>> saveRankingCache(FanRankingDTO ranking);
}
