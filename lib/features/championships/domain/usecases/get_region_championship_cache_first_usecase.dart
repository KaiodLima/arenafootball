import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_cached_region_championship_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championship_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/save_region_championship_cache_usecase.dart';

/// Campeonato da região pelo fluxo [cacheFirst] (validade
/// [CacheTtl.championships]). `null` = a região não tem campeonato.
class GetRegionChampionshipCacheFirstUseCase {
  final GetRegionChampionshipUseCase _getChampionship;
  final GetCachedRegionChampionshipUseCase _getCached;
  final SaveRegionChampionshipCacheUseCase _saveCache;

  GetRegionChampionshipCacheFirstUseCase(this._getChampionship, this._getCached, this._saveCache);

  Stream<Either<Failure, ChampionshipDTO?>> call({required String region, required String season, bool force = false}) =>
      cacheFirst<ChampionshipDTO?>(
        readCache: () => _getCached(region: region, season: season),
        fetchRemote: () => _getChampionship(region: region, season: season),
        saveCache: (championship) => _saveCache(championship, region: region, season: season),
        ttl: CacheTtl.championships,
        force: force,
        logName: 'GetRegionChampionshipCacheFirstUseCase',
      );
}
