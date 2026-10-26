import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/domain/repositories/predictions_repository_interface.dart';

/// Palpite da conta na partida, ao vivo (nulo = ainda não palpitou).
class WatchMyPredictionUseCase {
  final IPredictionsRepository _repository;

  WatchMyPredictionUseCase(this._repository);

  Stream<Either<Failure, PredictionDTO?>> call({required String matchId, required String uid, String? season}) =>
      _repository.watchMine(matchId: matchId, uid: uid, season: season);
}
