import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';

/// Stats não lê o Firestore direto (usa os UseCases de times e jogadores):
/// o repositório só guarda o ranking montado no cache local.
abstract class IStatsRepository {
  /// Nunca falha: sem cache = `Right(null)`.
  Future<Either<Failure, CachedValue<StatsRanking>?>> getCachedRanking({
    required StatsRankingType type,
    required String region,
    String? season,
  });

  Future<Either<Failure, void>> saveRankingCache(
    StatsRanking ranking, {
    required StatsRankingType type,
    required String region,
    String? season,
  });

  /// Apaga todos os rankings (qualquer quesito, região e temporada).
  Future<void> deleteRankingCache();
}
