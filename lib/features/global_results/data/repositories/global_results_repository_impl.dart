import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/global_results/data/datasources/global_results_datasource.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_match_dto.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';
import 'package:arena_soccer/features/global_results/domain/repositories/global_results_repository_interface.dart';

class GlobalResultsRepositoryImpl implements IGlobalResultsRepository {
  final GlobalResultsDataSource _dataSource;
  final CacheStore _cache;
  final DateTime Function() _now;

  GlobalResultsRepositoryImpl(this._dataSource, this._cache, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  @override
  Future<Either<Failure, List<ScrapedMatchDTO>>> getMatches(ResultsDay day) => _dataSource.getMatches(day);

  @override
  Future<Either<Failure, List<ScrapedGoalDTO>>> getMatchGoals(String url) => _dataSource.getMatchGoals(url);

  @override
  Future<Either<Failure, CachedValue<List<ScrapedMatchDTO>>?>> getCachedMatches(ResultsDay day) => _cache.read(
        _matchesKey(day),
        (json) => [for (final item in json as List) ScrapedMatchDTO.fromCache(Map<String, dynamic>.from(item as Map))],
      );

  @override
  Future<Either<Failure, void>> saveMatchesCache(ResultsDay day, List<ScrapedMatchDTO> matches) =>
      _cache.save(_matchesKey(day), [for (final match in matches) match.toCache()]);

  @override
  Future<Either<Failure, CachedValue<List<ScrapedGoalDTO>>?>> getCachedMatchGoals(String url) => _cache.read(
        CacheKeys.matchGoals(url),
        (json) => [for (final item in json as List) ScrapedGoalDTO.fromCache(Map<String, dynamic>.from(item as Map))],
      );

  @override
  Future<Either<Failure, void>> saveMatchGoalsCache(String url, List<ScrapedGoalDTO> goals) =>
      _cache.save(CacheKeys.matchGoals(url), [for (final goal in goals) goal.toCache()]);

  @override
  Future<void> deleteGlobalResultsCache() => _cache.deleteWhere(CacheKeys.isGlobalResultsKey);

  String _matchesKey(ResultsDay day) => CacheKeys.globalResults(day: day.name, date: _now());
}
