import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/stats/domain/repositories/stats_repository_interface.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';

/// Ranking do cache local (nunca falha: sem cache = `Right(null)`).
class GetCachedStatsRankingUseCase {
  final IStatsRepository _repository;

  GetCachedStatsRankingUseCase(this._repository);

  Future<Either<Failure, CachedValue<StatsRanking>?>> call({
    required StatsRankingType type,
    required String region,
    String? season,
  }) =>
      _repository.getCachedRanking(type: type, region: region, season: season);
}
