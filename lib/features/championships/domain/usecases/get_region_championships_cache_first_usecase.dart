import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_cached_region_championships_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/save_region_championships_cache_usecase.dart';

/// Campeonatos da região pelo fluxo [cacheFirst] (validade
/// [CacheTtl.championships]).
class GetRegionChampionshipsCacheFirstUseCase {
  final GetRegionChampionshipsUseCase _getChampionships;
  final GetCachedRegionChampionshipsUseCase _getCached;
  final SaveRegionChampionshipsCacheUseCase _saveCache;

  GetRegionChampionshipsCacheFirstUseCase(this._getChampionships, this._getCached, this._saveCache);

  Stream<Either<Failure, List<ChampionshipDTO>>> call({
    required String region,
    required String season,
    bool force = false,
  }) =>
      cacheFirst<List<ChampionshipDTO>>(
        readCache: () => _getCached(region: region, season: season),
        fetchRemote: () => _getChampionships(region: region, season: season),
        saveCache: (championships) => _saveCache(championships, region: region, season: season),
        ttl: CacheTtl.championships,
        force: force,
        logName: 'GetRegionChampionshipsCacheFirstUseCase',
      );
}
