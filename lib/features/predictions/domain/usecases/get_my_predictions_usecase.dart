import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/domain/repositories/predictions_repository_interface.dart';

/// Palpites da conta num punhado de partidas (central do bolão): id da
/// partida → palpite; as sem palpite ficam de fora. Sem conta ou sem
/// partidas, vazio sem leitura.
class GetMyPredictionsUseCase {
  final IPredictionsRepository _repository;

  GetMyPredictionsUseCase(this._repository);

  Future<Either<Failure, Map<String, PredictionDTO>>> call({
    required List<String> matchIds,
    required String uid,
    String? season,
  }) async {
    if (uid.isEmpty || matchIds.isEmpty) return const Right({});
    return _repository.getMine(matchIds: matchIds, uid: uid, season: season);
  }
}
