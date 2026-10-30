import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/features/regions/domain/region_usage.dart';

abstract class IRegionsRepository {
  Future<Either<Failure, List<String>>> getRegions();

  /// Regiões com o id (remoto). Carrega o `RegionRegistry`.
  Future<Either<Failure, List<RegionRef>>> getRegionRefs();

  /// Cache local das regiões; ao ler, carrega o `RegionRegistry` (app offline).
  Future<Either<Failure, CachedValue<List<RegionRef>>?>> getCachedRegions();

  Future<Either<Failure, void>> saveRegionsCache(List<RegionRef> regions);

  Future<Either<Failure, void>> deleteRegionsCache();

  Future<Either<Failure, void>> createRegion(String name);

  Future<Either<Failure, void>> renameRegion({required String id, required String name});

  Future<Either<Failure, void>> deleteRegion(String id);

  Future<Either<Failure, RegionUsage>> regionUsage({required String id, required String name});

  Future<Either<Failure, RegionLinkReport>> linkRegions();

  Future<String?> getSavedRegion();

  Future<void> saveRegion(String region);

  /// Regiões escolhidas por último (nomes atuais), a mais recente primeiro.
  Future<List<String>> getRecentRegions();

  Future<String?> getSavedSeason();

  Future<void> saveSeason(String season);
}
