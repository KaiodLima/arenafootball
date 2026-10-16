import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/stats/domain/repositories/stats_repository_interface.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';

class SaveStatsRankingCacheUseCase {
  final IStatsRepository _repository;

  SaveStatsRankingCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(
    StatsRanking ranking, {
    required StatsRankingType type,
    required String region,
    String? season,
  }) =>
      _repository.saveRankingCache(ranking, type: type, region: region, season: season);
}
