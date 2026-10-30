import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/preferences_service.dart';
import 'package:arena_soccer/features/regions/data/datasources/regions_datasource.dart';
import 'package:arena_soccer/features/regions/domain/region_usage.dart';
import 'package:arena_soccer/features/regions/domain/region_choices.dart';
import 'package:arena_soccer/features/regions/domain/repositories/regions_repository_interface.dart';

class RegionsRepositoryImpl implements IRegionsRepository {
  final RegionsDataSource _dataSource;
  final PreferencesService _preferences;
  final CacheStore _cache;

  RegionsRepositoryImpl(this._dataSource, this._preferences, this._cache);

  @override
  Future<Either<Failure, List<String>>> getRegions() => _dataSource.getRegions();

  @override
  Future<Either<Failure, List<RegionRef>>> getRegionRefs() => _dataSource.getRegionRefs();

  @override
  Future<Either<Failure, CachedValue<List<RegionRef>>?>> getCachedRegions() async {
    final response = await _cache.read<List<RegionRef>>(
      CacheKeys.regions,
      (json) => [for (final item in json as List) RegionRef.fromCache(Map<String, dynamic>.from(item as Map))],
    );
    // Igual ao remoto: o vínculo id ↔ nome passa a valer também sem rede.
    final cached = response.isRight ? response.right : null;
    if (cached != null && cached.data.isNotEmpty) RegionRegistry.configure(cached.data);
    return response;
  }

  @override
  Future<Either<Failure, void>> saveRegionsCache(List<RegionRef> regions) =>
      _cache.save(CacheKeys.regions, [for (final region in regions) region.toCache()]);

  @override
  Future<Either<Failure, void>> deleteRegionsCache() => _cache.delete(CacheKeys.regions);

  /// Depois de gravar uma região: o próximo carregamento busca a lista nova.
  Future<Either<Failure, void>> _invalidate(Either<Failure, void> response) async {
    if (response.isRight) await deleteRegionsCache();
    return response;
  }

  @override
  Future<Either<Failure, void>> createRegion(String name) async => _invalidate(await _dataSource.createRegion(name));

  @override
  Future<Either<Failure, void>> renameRegion({required String id, required String name}) async =>
      _invalidate(await _dataSource.renameRegion(id: id, name: name));

  @override
  Future<Either<Failure, void>> deleteRegion(String id) async => _invalidate(await _dataSource.deleteRegion(id));

  @override
  Future<Either<Failure, RegionUsage>> regionUsage({required String id, required String name}) =>
      _dataSource.regionUsage(id: id, name: name);

  @override
  Future<Either<Failure, RegionLinkReport>> linkRegions() => _dataSource.linkRegions();

  @override

  /// Pelo id salvo (nome atual, mesmo depois de renomear); sem id, o nome
  /// salvo pelas versões antigas.
  Future<String?> getSavedRegion() async {
    final id = await _preferences.getRegionId() ?? '';
    final byId = RegionRegistry.nameOf(id);
    if (byId.isNotEmpty) return byId;
    return _preferences.getRegion();
  }

  @override
  Future<void> saveRegion(String region) async {
    final id = RegionRegistry.idOf(region);
    await _preferences.setRegion(region);
    await _preferences.setRegionId(id);
    // Recentes pelo id: a região renomeada continua lá, com o nome novo.
    if (id.isNotEmpty) {
      await _preferences.setRecentRegionIds(RegionChoices.push(await _preferences.getRecentRegionIds(), id));
    }
  }

  @override
  Future<List<String>> getRecentRegions() async => [
        for (final id in await _preferences.getRecentRegionIds())
          if (RegionRegistry.nameOf(id).isNotEmpty) RegionRegistry.nameOf(id),
      ];

  @override
  Future<String?> getSavedSeason() => _preferences.getSeason();

  @override
  Future<void> saveSeason(String season) => _preferences.setSeason(season);
}
