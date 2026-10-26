import 'package:either_dart/either.dart';
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

  Future<Either<Failure, List<PredictionRankingEntry>>> topOfRegion({required String regionId, String? season});

  Future<Either<Failure, PredictionRankingEntry?>> mine(
      {required String regionId, required String uid, String? season});

  Future<Either<Failure, int>> aheadOf({required String regionId, required int points, String? season});
}
