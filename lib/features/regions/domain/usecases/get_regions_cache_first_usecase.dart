import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/features/regions/domain/repositories/regions_repository_interface.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_cached_regions_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/save_regions_cache_usecase.dart';

/// Regiões pelo fluxo [cacheFirst] (validade [CacheTtl.regions]). O
/// `RegionRegistry` é carregado tanto pelo cache quanto pelo remoto.
/// [force] ignora a validade (admin acabou de mudar as regiões).
class GetRegionsCacheFirstUseCase {
  final IRegionsRepository _repository;
  final GetCachedRegionsUseCase _getCached;
  final SaveRegionsCacheUseCase _saveCache;

  GetRegionsCacheFirstUseCase(this._repository, this._getCached, this._saveCache);

  Stream<Either<Failure, List<RegionRef>>> call({bool force = false}) => cacheFirst<List<RegionRef>>(
        readCache: _getCached.call,
        fetchRemote: _repository.getRegionRefs,
        saveCache: _saveCache.call,
        ttl: CacheTtl.regions,
        force: force,
        logName: 'GetRegionsCacheFirstUseCase',
      );
}
