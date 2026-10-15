import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/preferences_service.dart';
import 'package:arena_soccer/features/regions/data/datasources/regions_datasource.dart';
import 'package:arena_soccer/features/regions/domain/region_usage.dart';
import 'package:arena_soccer/features/regions/domain/repositories/regions_repository_interface.dart';

class RegionsRepositoryImpl implements IRegionsRepository {
  final RegionsDataSource _dataSource;
  final PreferencesService _preferences;

  RegionsRepositoryImpl(this._dataSource, this._preferences);

  @override
  Future<Either<Failure, List<String>>> getRegions() => _dataSource.getRegions();

  @override
  Future<Either<Failure, void>> createRegion(String name) => _dataSource.createRegion(name);

  @override
  Future<Either<Failure, void>> renameRegion({required String id, required String name}) =>
      _dataSource.renameRegion(id: id, name: name);

  @override
  Future<Either<Failure, void>> deleteRegion(String id) => _dataSource.deleteRegion(id);

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
    await _preferences.setRegion(region);
    await _preferences.setRegionId(RegionRegistry.idOf(region));
  }

  @override
  Future<String?> getSavedSeason() => _preferences.getSeason();

  @override
  Future<void> saveSeason(String season) => _preferences.setSeason(season);
}
