import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_match_dto.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';

abstract class IGlobalResultsRepository {
  Future<Either<Failure, List<ScrapedMatchDTO>>> getMatches(ResultsDay day);

  Future<Either<Failure, List<ScrapedGoalDTO>>> getMatchGoals(String url);

  /// Cache local das partidas do [day] (do dia de hoje no aparelho). Nunca
  /// falha: sem cache = `Right(null)`.
  Future<Either<Failure, CachedValue<List<ScrapedMatchDTO>>?>> getCachedMatches(ResultsDay day);

  Future<Either<Failure, void>> saveMatchesCache(ResultsDay day, List<ScrapedMatchDTO> matches);

  /// Cache local dos gols de um jogo (pela [url] da análise).
  Future<Either<Failure, CachedValue<List<ScrapedGoalDTO>>?>> getCachedMatchGoals(String url);

  Future<Either<Failure, void>> saveMatchGoalsCache(String url, List<ScrapedGoalDTO> goals);

  /// Apaga o cache dos resultados e dos gols.
  Future<void> deleteGlobalResultsCache();
}
