import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/domain/repositories/predictions_repository_interface.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/get_my_predictions_usecase.dart';

/// Palpites da conta salvos no cache local, um por partida: id da partida →
/// palpite salvo (`data` nulo = a conta não palpitou). As sem cache ficam de
/// fora do mapa.
class GetCachedMyPredictionsUseCase {
  final IPredictionsRepository _repository;

  GetCachedMyPredictionsUseCase(this._repository);

  Future<Map<String, CachedValue<PredictionDTO?>>> call({
    required List<String> matchIds,
    required String uid,
    String? season,
  }) async {
    final found = <String, CachedValue<PredictionDTO?>>{};
    for (final id in matchIds) {
      final cached = await _repository.getCachedMine(matchId: id, uid: uid, season: season);
      final value = cached.isRight ? cached.right : null;
      if (value != null) found[id] = value;
    }
    return found;
  }
}

/// Salva o palpite de cada uma das [matchIds] (sem palpite em [found] = salvo
/// como "não palpitou", para não ler de novo).
class SaveMyPredictionsCacheUseCase {
  final IPredictionsRepository _repository;

  SaveMyPredictionsCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(
    Map<String, PredictionDTO> found, {
    required List<String> matchIds,
    required String uid,
    String? season,
  }) async {
    Either<Failure, void> result = const Right(null);
    for (final id in matchIds) {
      final saved = await _repository.saveMineCache(found[id], matchId: id, uid: uid, season: season);
      if (saved.isLeft) result = saved;
    }
    return result;
  }
}

/// Palpites da conta nas partidas mostradas, "cache primeiro" por partida
/// (validade [CacheTtl.myPredictions]): emite o que está no cache na hora e
/// lê do Firestore só as partidas sem cache, vencidas ou todas com [force].
/// Palpitar apaga o cache daquela partida (no repositório), então a volta da
/// folha de palpite mostra o novo na hora. Falha no remoto com cache em tela
/// fica com o cache.
class GetMyPredictionsCacheFirstUseCase {
  final GetMyPredictionsUseCase _getMine;
  final GetCachedMyPredictionsUseCase _getCached;
  final SaveMyPredictionsCacheUseCase _saveCache;

  /// Relógio (teste).
  final DateTime Function() _now;

  GetMyPredictionsCacheFirstUseCase(this._getMine, this._getCached, this._saveCache, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  Stream<Either<Failure, Map<String, PredictionDTO>>> call({
    required List<String> matchIds,
    required String uid,
    String? season,
    bool force = false,
  }) async* {
    if (uid.isEmpty || matchIds.isEmpty) {
      yield const Right({});
      return;
    }
    final cached = await _getCached(matchIds: matchIds, uid: uid, season: season);
    final fromCache = <String, PredictionDTO>{
      for (final entry in cached.entries)
        if (entry.value.data != null) entry.key: entry.value.data!,
    };
    if (cached.isNotEmpty) yield Right(fromCache);
    final clock = _now();
    final missing = [
      for (final id in matchIds)
        if (force || !(cached[id]?.isFresh(CacheTtl.myPredictions, now: clock) ?? false)) id,
    ];
    if (missing.isEmpty) return;

    final remote = await _getMine(matchIds: missing, uid: uid, season: season);
    if (remote.isLeft) {
      if (cached.isEmpty) yield Left(remote.left);
      return;
    }
    await _saveCache(remote.right, matchIds: missing, uid: uid, season: season);
    final merged = {...fromCache}
      ..removeWhere((id, _) => missing.contains(id))
      ..addAll(remote.right);
    if (cached.isNotEmpty && cacheEquals(fromCache, merged)) return;
    yield Right(merged);
  }

  /// O valor mais novo numa leitura só.
  Future<Either<Failure, Map<String, PredictionDTO>>> latest({
    required List<String> matchIds,
    required String uid,
    String? season,
    bool force = false,
  }) =>
      call(matchIds: matchIds, uid: uid, season: season, force: force).last;
}
