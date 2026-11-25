import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/domain/repositories/predictions_repository_interface.dart';

/// Ranking do bolão: o top 50 ordenado e a linha e a posição da conta.
typedef PredictionRanking = ({List<PredictionRankingEntry> top, PredictionRankingEntry? mine, int? myPosition});

/// Ranking do bolão da região: o top 50 (desempate por exatos e palpites) e a
/// linha e a posição da conta (mesmo fora do top 50). [knownTop] = o top já
/// em mãos (do cache válido): não lê de novo.
class GetPredictionRankingUseCase {
  final IPredictionsRepository _repository;

  GetPredictionRankingUseCase(this._repository);

  Future<Either<Failure, PredictionRanking>> call({
    required String regionId,
    String uid = '',
    String? season,
    List<PredictionRankingEntry>? knownTop,
  }) async {
    final result = await withStatus(regionId: regionId, uid: uid, season: season, knownTop: knownTop);
    return result.isLeft ? Left(result.left) : Right(result.right.ranking);
  }

  /// Igual ao [call], dizendo se a linha e a posição da conta vieram
  /// completas ([complete] falso = a leitura da linha ou do "à frente"
  /// falhou e o ranking saiu sem elas: não vai para o cache).
  Future<Either<Failure, ({PredictionRanking ranking, bool complete})>> withStatus({
    required String regionId,
    String uid = '',
    String? season,
    List<PredictionRankingEntry>? knownTop,
  }) async {
    final top = knownTop != null
        ? Right<Failure, List<PredictionRankingEntry>>(knownTop)
        : await _repository.topOfRegion(regionId: regionId, season: season);
    if (top.isLeft) return Left(top.left);
    final sorted = [...top.right]..sort(PredictionRankingEntry.compare);
    if (uid.isEmpty) return Right((ranking: (top: sorted, mine: null, myPosition: null), complete: true));
    final index = sorted.indexWhere((e) => e.uid == uid);
    if (index >= 0) {
      return Right((ranking: (top: sorted, mine: sorted[index], myPosition: index + 1), complete: true));
    }
    final mine = await _repository.mine(regionId: regionId, uid: uid, season: season);
    if (mine.isLeft) return Right((ranking: (top: sorted, mine: null, myPosition: null), complete: false));
    final entry = mine.right;
    if (entry == null) return Right((ranking: (top: sorted, mine: null, myPosition: null), complete: true));
    final ahead = await _repository.aheadOf(regionId: regionId, points: entry.points, season: season);
    return Right((
      ranking: (top: sorted, mine: entry, myPosition: ahead.fold((_) => null, (n) => n + 1)),
      complete: ahead.isRight,
    ));
  }
}
