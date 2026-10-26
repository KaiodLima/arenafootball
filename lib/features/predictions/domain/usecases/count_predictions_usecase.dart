import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/predictions/domain/repositories/predictions_repository_interface.dart';

/// Quantas pessoas palpitaram na partida.
class CountPredictionsUseCase {
  final IPredictionsRepository _repository;

  CountPredictionsUseCase(this._repository);

  Future<Either<Failure, int>> call({required String matchId, String? season}) =>
      _repository.count(matchId: matchId, season: season);
}
