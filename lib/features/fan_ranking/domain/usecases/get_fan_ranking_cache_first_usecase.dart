import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/fan_ranking/data/dtos/fan_ranking_dto.dart';
import 'package:arena_soccer/features/fan_ranking/domain/repositories/fan_ranking_repository_interface.dart';

/// Ranking de torcidas da [season] pelo fluxo [cacheFirst] (validade
/// [CacheTtl.fanRanking]; o servidor atualiza de hora em hora). [force] ignora
/// a validade (puxar para atualizar).
class GetFanRankingCacheFirstUseCase {
  final IFanRankingRepository _repository;

  GetFanRankingCacheFirstUseCase(this._repository);

  Stream<Either<Failure, FanRankingDTO>> call({required String season, bool force = false}) =>
      cacheFirst<FanRankingDTO>(
        readCache: () => _repository.getCachedRanking(season),
        fetchRemote: () => _repository.getRanking(season),
        saveCache: _repository.saveRankingCache,
        ttl: CacheTtl.fanRanking,
        force: force,
        logName: 'GetFanRankingCacheFirstUseCase',
      );
}
