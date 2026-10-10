import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/preferences_service.dart';
import 'package:arena_soccer/features/regions/data/datasources/regions_datasource.dart';
import 'package:arena_soccer/features/regions/domain/repositories/regions_repository_interface.dart';

class RegionsRepositoryImpl implements IRegionsRepository {
  final RegionsDataSource _dataSource;
  final PreferencesService _preferences;

  RegionsRepositoryImpl(this._dataSource, this._preferences);

  @override
  Future<Either<Failure, List<String>>> getRegions() => _dataSource.getRegions();

  @override
  Future<String?> getSavedRegion() => _preferences.getRegion();

  @override
  Future<void> saveRegion(String region) => _preferences.setRegion(region);

  @override
  Future<String?> getSavedSeason() => _preferences.getSeason();

  @override
  Future<void> saveSeason(String season) => _preferences.setSeason(season);
}
