import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/predictions/domain/repositories/predictions_repository_interface.dart';

/// Grava o palpite (0 a 99 gols de cada lado). O prazo a regra e a function conferem.
class SavePredictionUseCase {
  final IPredictionsRepository _repository;

  SavePredictionUseCase(this._repository);

  static const int maxGoals = 99;

  Future<Either<Failure, void>> call({
    required String matchId,
    required String uid,
    required String name,
    required int home,
    required int away,
    String? season,
  }) =>
      _repository.save(
        matchId: matchId,
        uid: uid,
        name: name.trim(),
        home: home.clamp(0, maxGoals),
        away: away.clamp(0, maxGoals),
        season: season,
      );
}
