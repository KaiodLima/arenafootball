import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/domain/repositories/predictions_repository_interface.dart';

/// Ranking do bolão da região: o top 50 (desempate por exatos e palpites) e a
/// linha e a posição da conta (mesmo fora do top 50).
class GetPredictionRankingUseCase {
  final IPredictionsRepository _repository;

  GetPredictionRankingUseCase(this._repository);

  Future<Either<Failure, ({List<PredictionRankingEntry> top, PredictionRankingEntry? mine, int? myPosition})>> call({
    required String regionId,
    String uid = '',
    String? season,
  }) async {
    final top = await _repository.topOfRegion(regionId: regionId, season: season);
    if (top.isLeft) return Left(top.left);
    final sorted = [...top.right]..sort(PredictionRankingEntry.compare);
    if (uid.isEmpty) return Right((top: sorted, mine: null, myPosition: null));
    final index = sorted.indexWhere((e) => e.uid == uid);
    if (index >= 0) return Right((top: sorted, mine: sorted[index], myPosition: index + 1));
    final mine = await _repository.mine(regionId: regionId, uid: uid, season: season);
    final entry = mine.fold((_) => null, (value) => value);
    if (entry == null) return Right((top: sorted, mine: null, myPosition: null));
    final ahead = await _repository.aheadOf(regionId: regionId, points: entry.points, season: season);
    return Right((top: sorted, mine: entry, myPosition: ahead.fold((_) => null, (n) => n + 1)));
  }
}
