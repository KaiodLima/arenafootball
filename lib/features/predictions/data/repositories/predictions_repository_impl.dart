import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/data/datasources/predictions_datasource.dart';
import 'package:arena_soccer/features/predictions/domain/repositories/predictions_repository_interface.dart';

class PredictionsRepositoryImpl implements IPredictionsRepository {
  final PredictionsDataSource _dataSource;

  PredictionsRepositoryImpl(this._dataSource);

  @override
  Stream<Either<Failure, PredictionDTO?>> watchMine({required String matchId, required String uid, String? season}) =>
      _dataSource.watchMine(matchId: matchId, uid: uid, season: season);

  @override
  Future<Either<Failure, void>> save({
    required String matchId,
    required String uid,
    required String name,
    required int home,
    required int away,
    String? season,
  }) =>
      _dataSource.save(matchId: matchId, uid: uid, name: name, home: home, away: away, season: season);

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
}
