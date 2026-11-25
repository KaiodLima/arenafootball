import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';

abstract class IPredictionsRepository {
  Stream<Either<Failure, PredictionDTO?>> watchMine({required String matchId, required String uid, String? season});

  Future<Either<Failure, void>> save({
    required String matchId,
    required String uid,
    required String name,
    required int home,
    required int away,
    String? season,
  });

  Future<Either<Failure, int>> count({required String matchId, String? season});

  Future<Either<Failure, Map<String, PredictionDTO>>> getMine({
    required List<String> matchIds,
    required String uid,
    String? season,
  });

  Future<Either<Failure, List<PredictionRankingEntry>>> topOfRegion({required String regionId, String? season});

  Future<Either<Failure, PredictionRankingEntry?>> mine(
      {required String regionId, required String uid, String? season});

  Future<Either<Failure, int>> aheadOf({required String regionId, required int points, String? season});

  // ---- Cache local (ler nunca falha: sem cache = `Right(null)`) ----

  /// Top 50 da região (sem ordenar).
  Future<Either<Failure, CachedValue<List<PredictionRankingEntry>>?>> getCachedRankingTop(
      {required String regionId, String? season});

  Future<Either<Failure, void>> saveRankingTopCache(List<PredictionRankingEntry> entries,
      {required String regionId, String? season});

  /// Linha e posição da conta fora do top 50.
  Future<Either<Failure, CachedValue<PredictionStanding>?>> getCachedStanding(
      {required String regionId, required String uid, String? season});

  Future<Either<Failure, void>> saveStandingCache(PredictionStanding standing,
      {required String regionId, required String uid, String? season});

  /// Palpite da conta na partida (`data` nulo = sem palpite).
  Future<Either<Failure, CachedValue<PredictionDTO?>?>> getCachedMine(
      {required String matchId, required String uid, String? season});

  Future<Either<Failure, void>> saveMineCache(PredictionDTO? prediction,
      {required String matchId, required String uid, String? season});

  /// Quantas pessoas palpitaram na partida.
  Future<Either<Failure, CachedValue<int>?>> getCachedCount({required String matchId, String? season});

  Future<Either<Failure, void>> saveCountCache(int count, {required String matchId, String? season});
}
