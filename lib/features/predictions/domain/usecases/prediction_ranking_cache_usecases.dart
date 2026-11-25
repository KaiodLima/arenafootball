import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/domain/repositories/predictions_repository_interface.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/get_prediction_ranking_usecase.dart';

/// Ranking do bolão salvo no cache local: o top 50 da região (de todas as
/// contas) e, com a conta fora dele, a linha e a posição dela (chave com o
/// uid). Falta uma das partes = sem cache; vale a gravação mais antiga.
class GetCachedPredictionRankingUseCase {
  final IPredictionsRepository _repository;

  GetCachedPredictionRankingUseCase(this._repository);

  Future<Either<Failure, CachedValue<PredictionRanking>?>> call({
    required String regionId,
    String uid = '',
    String? season,
  }) async {
    final top = await _repository.getCachedRankingTop(regionId: regionId, season: season);
    final cachedTop = top.isRight ? top.right : null;
    if (cachedTop == null) return const Right(null);
    final sorted = [...cachedTop.data]..sort(PredictionRankingEntry.compare);
    if (uid.isEmpty) return Right(CachedValue((top: sorted, mine: null, myPosition: null), cachedTop.savedAt));
    final index = sorted.indexWhere((e) => e.uid == uid);
    if (index >= 0) {
      return Right(CachedValue((top: sorted, mine: sorted[index], myPosition: index + 1), cachedTop.savedAt));
    }
    final standing = await _repository.getCachedStanding(regionId: regionId, uid: uid, season: season);
    final cachedStanding = standing.isRight ? standing.right : null;
    if (cachedStanding == null) return const Right(null);
    final savedAt = cachedStanding.savedAt.isBefore(cachedTop.savedAt) ? cachedStanding.savedAt : cachedTop.savedAt;
    return Right(CachedValue(
      (top: sorted, mine: cachedStanding.data.entry, myPosition: cachedStanding.data.position),
      savedAt,
    ));
  }

  /// O top 50 do cache ainda dentro da validade (nulo = sem cache ou vencido),
  /// para outra conta da região não ler o top de novo.
  Future<List<PredictionRankingEntry>?> freshTop({required String regionId, String? season, DateTime? now}) async {
    final top = await _repository.getCachedRankingTop(regionId: regionId, season: season);
    final cached = top.isRight ? top.right : null;
    return cached != null && cached.isFresh(CacheTtl.predictionRanking, now: now) ? cached.data : null;
  }
}

/// Salva o ranking do bolão: o top 50 e, com a conta fora dele, a linha e a
/// posição dela.
class SavePredictionRankingCacheUseCase {
  final IPredictionsRepository _repository;

  SavePredictionRankingCacheUseCase(this._repository);

  /// [saveTop] falso = o top veio do cache válido (não renova a validade dele).
  /// [saveStanding] falso = a leitura da linha da conta falhou (falha nunca
  /// vai para o cache; "sem linha" de verdade vai).
  Future<Either<Failure, void>> call(
    PredictionRanking ranking, {
    required String regionId,
    String uid = '',
    String? season,
    bool saveTop = true,
    bool saveStanding = true,
  }) async {
    final top = saveTop
        ? await _repository.saveRankingTopCache(ranking.top, regionId: regionId, season: season)
        : const Right<Failure, void>(null);
    if (top.isLeft || !saveStanding || uid.isEmpty || ranking.top.any((e) => e.uid == uid)) return top;
    return _repository.saveStandingCache(
      PredictionStanding(entry: ranking.mine, position: ranking.myPosition),
      regionId: regionId,
      uid: uid,
      season: season,
    );
  }
}

/// Ranking do bolão pelo fluxo [cacheFirst] (validade
/// [CacheTtl.predictionRanking]): mesma entrada do
/// [GetPredictionRankingUseCase]; [force] (puxar para atualizar) ignora a
/// validade. Palpitar não muda os pontos (as functions pontuam depois), então
/// nenhuma gravação do app apaga este cache.
class GetPredictionRankingCacheFirstUseCase {
  final GetPredictionRankingUseCase _getRanking;
  final GetCachedPredictionRankingUseCase _getCached;
  final SavePredictionRankingCacheUseCase _saveCache;

  GetPredictionRankingCacheFirstUseCase(this._getRanking, this._getCached, this._saveCache);

  Stream<Either<Failure, PredictionRanking>> call({
    required String regionId,
    String uid = '',
    String? season,
    bool force = false,
  }) {
    // Top válido no cache (só falta a linha desta conta): não lê o top de novo.
    var topFromCache = false;
    // Linha/posição da conta lidas sem falha (falha não vai para o cache).
    var complete = true;
    return cacheFirst<PredictionRanking>(
      readCache: () => _getCached(regionId: regionId, uid: uid, season: season),
      fetchRemote: () async {
        final knownTop = force ? null : await _getCached.freshTop(regionId: regionId, season: season);
        topFromCache = knownTop != null;
        final result = await _getRanking.withStatus(regionId: regionId, uid: uid, season: season, knownTop: knownTop);
        if (result.isLeft) return Left(result.left);
        complete = result.right.complete;
        return Right(result.right.ranking);
      },
      saveCache: (ranking) => _saveCache(ranking,
          regionId: regionId, uid: uid, season: season, saveTop: !topFromCache, saveStanding: complete),
      ttl: CacheTtl.predictionRanking,
      force: force,
      equals: (a, b) => cacheEquals(a.top, b.top) && a.mine == b.mine && a.myPosition == b.myPosition,
      logName: 'GetPredictionRankingCacheFirstUseCase',
    );
  }
}
