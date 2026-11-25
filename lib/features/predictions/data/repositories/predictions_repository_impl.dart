import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/data/datasources/predictions_datasource.dart';
import 'package:arena_soccer/features/predictions/domain/repositories/predictions_repository_interface.dart';

class PredictionsRepositoryImpl implements IPredictionsRepository {
  final PredictionsDataSource _dataSource;
  final CacheStore _cache;

  PredictionsRepositoryImpl(this._dataSource, this._cache);

  @override
  Stream<Either<Failure, PredictionDTO?>> watchMine({required String matchId, required String uid, String? season}) =>
      _dataSource.watchMine(matchId: matchId, uid: uid, season: season);

  /// Grava o palpite e apaga do cache o palpite da conta e a contagem da
  /// partida (mesmo na falha: a gravação pode estar na fila offline).
  @override
  Future<Either<Failure, void>> save({
    required String matchId,
    required String uid,
    required String name,
    required int home,
    required int away,
    String? season,
  }) async {
    final response =
        await _dataSource.save(matchId: matchId, uid: uid, name: name, home: home, away: away, season: season);
    await _cache.delete(CacheKeys.myPrediction(matchId: matchId, uid: uid, season: season));
    await _cache.delete(CacheKeys.predictionCount(matchId: matchId, season: season));
    return response;
  }

  @override
  Future<Either<Failure, int>> count({required String matchId, String? season}) =>
      _dataSource.count(matchId: matchId, season: season);

  @override
  Future<Either<Failure, List<PredictionRankingEntry>>> topOfRegion({required String regionId, String? season}) =>
      _dataSource.topOfRegion(regionId: regionId, season: season);

  @override
  Future<Either<Failure, PredictionRankingEntry?>> mine(
          {required String regionId, required String uid, String? season}) =>
      _dataSource.mine(regionId: regionId, uid: uid, season: season);

  @override
  Future<Either<Failure, int>> aheadOf({required String regionId, required int points, String? season}) =>
      _dataSource.aheadOf(regionId: regionId, points: points, season: season);

  @override
  Future<Either<Failure, Map<String, PredictionDTO>>> getMine({
    required List<String> matchIds,
    required String uid,
    String? season,
  }) =>
      _dataSource.getMine(matchIds: matchIds, uid: uid, season: season);

  // ---- Cache local ----

  @override
  Future<Either<Failure, CachedValue<List<PredictionRankingEntry>>?>> getCachedRankingTop(
          {required String regionId, String? season}) =>
      _cache.read(
        CacheKeys.predictionRanking(regionId: regionId, season: season),
        (json) => [
          for (final item in json as List) PredictionRankingEntry.fromCache(Map<String, dynamic>.from(item as Map)),
        ],
      );

  @override
  Future<Either<Failure, void>> saveRankingTopCache(List<PredictionRankingEntry> entries,
          {required String regionId, String? season}) =>
      _cache.save(
        CacheKeys.predictionRanking(regionId: regionId, season: season),
        [for (final e in entries) e.toCache()],
      );

  @override
  Future<Either<Failure, CachedValue<PredictionStanding>?>> getCachedStanding(
          {required String regionId, required String uid, String? season}) =>
      _cache.read(
        CacheKeys.predictionStanding(regionId: regionId, uid: uid, season: season),
        (json) => PredictionStanding.fromCache(Map<String, dynamic>.from(json as Map)),
      );

  @override
  Future<Either<Failure, void>> saveStandingCache(PredictionStanding standing,
          {required String regionId, required String uid, String? season}) =>
      _cache.save(CacheKeys.predictionStanding(regionId: regionId, uid: uid, season: season), standing.toCache());

  @override
  Future<Either<Failure, CachedValue<PredictionDTO?>?>> getCachedMine(
          {required String matchId, required String uid, String? season}) =>
      _cache.read<PredictionDTO?>(
        CacheKeys.myPrediction(matchId: matchId, uid: uid, season: season),
        (json) => json == null ? null : PredictionDTO.fromCache(Map<String, dynamic>.from(json as Map)),
      );

  @override
  Future<Either<Failure, void>> saveMineCache(PredictionDTO? prediction,
          {required String matchId, required String uid, String? season}) =>
      _cache.save(CacheKeys.myPrediction(matchId: matchId, uid: uid, season: season), prediction?.toCache());

  @override
  Future<Either<Failure, CachedValue<int>?>> getCachedCount({required String matchId, String? season}) =>
      _cache.read(CacheKeys.predictionCount(matchId: matchId, season: season), (json) => (json as num).toInt());

  @override
  Future<Either<Failure, void>> saveCountCache(int count, {required String matchId, String? season}) =>
      _cache.save(CacheKeys.predictionCount(matchId: matchId, season: season), count);
}
