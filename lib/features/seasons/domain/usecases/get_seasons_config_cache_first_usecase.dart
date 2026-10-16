import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/seasons/data/dtos/seasons_config_dto.dart';
import 'package:arena_soccer/features/seasons/domain/repositories/seasons_repository_interface.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/get_cached_seasons_config_usecase.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/save_seasons_config_cache_usecase.dart';

/// Config de temporadas pelo fluxo [cacheFirst] (validade
/// [CacheTtl.seasonsConfig]). Cada valor (cache ou remoto) é aplicado em
/// [SeasonCollection]. Nunca falha: sem cache e sem rede (ou sem config),
/// emite o padrão do código. [force] ignora a validade.
class GetSeasonsConfigCacheFirstUseCase {
  final ISeasonsRepository _repository;
  final GetCachedSeasonsConfigUseCase _getCached;
  final SaveSeasonsConfigCacheUseCase _saveCache;

  GetSeasonsConfigCacheFirstUseCase(this._repository, this._getCached, this._saveCache);

  Stream<SeasonsConfigDTO> call({bool force = false}) async* {
    final stream = cacheFirst<SeasonsConfigDTO>(
      readCache: _getCached.call,
      fetchRemote: _fetchRemote,
      saveCache: _saveCache.call,
      ttl: CacheTtl.seasonsConfig,
      force: force,
      logName: 'GetSeasonsConfigCacheFirstUseCase',
    );
    await for (final response in stream) {
      final config = response.isRight ? response.right : null;
      if (config != null) SeasonCollection.configure(current: config.current, seasons: config.seasons);
      yield SeasonsConfigDTO(current: SeasonCollection.currentSeason, seasons: SeasonCollection.seasons);
    }
  }

  /// Doc ausente ou sem temporada atual não vai para o cache.
  Future<Either<Failure, SeasonsConfigDTO>> _fetchRemote() async {
    final response = await _repository.getConfig();
    if (response.isLeft) return Left(response.left);
    final config = response.right;
    if (config == null || config.current.isEmpty) return Left(ErrorWithMessage('Sem config de temporadas.'));
    return Right(config);
  }
}
