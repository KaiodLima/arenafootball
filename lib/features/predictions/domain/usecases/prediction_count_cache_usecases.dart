import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/predictions/domain/repositories/predictions_repository_interface.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/count_predictions_usecase.dart';

/// Quantas pessoas palpitaram na partida, do cache local.
class GetCachedPredictionCountUseCase {
  final IPredictionsRepository _repository;

  GetCachedPredictionCountUseCase(this._repository);

  Future<Either<Failure, CachedValue<int>?>> call({required String matchId, String? season}) =>
      _repository.getCachedCount(matchId: matchId, season: season);
}

class SavePredictionCountCacheUseCase {
  final IPredictionsRepository _repository;

  SavePredictionCountCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(int count, {required String matchId, String? season}) =>
      _repository.saveCountCache(count, matchId: matchId, season: season);
}

/// Contagem de palpites da partida pelo fluxo [cacheFirst] (validade
/// [CacheTtl.predictionCount]; o número quase não muda depois que o jogo
/// começa). Palpitar apaga a contagem da partida (no repositório).
class CountPredictionsCacheFirstUseCase {
  final CountPredictionsUseCase _count;
  final GetCachedPredictionCountUseCase _getCached;
  final SavePredictionCountCacheUseCase _saveCache;

  CountPredictionsCacheFirstUseCase(this._count, this._getCached, this._saveCache);

  Stream<Either<Failure, int>> call({required String matchId, String? season, bool force = false}) => cacheFirst<int>(
        readCache: () => _getCached(matchId: matchId, season: season),
        fetchRemote: () => _count(matchId: matchId, season: season),
        saveCache: (count) => _saveCache(count, matchId: matchId, season: season),
        ttl: CacheTtl.predictionCount,
        force: force,
        logName: 'CountPredictionsCacheFirstUseCase',
      );
}
