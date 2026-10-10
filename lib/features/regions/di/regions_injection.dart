import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/regions/data/datasources/regions_datasource.dart';
import 'package:arena_soccer/features/regions/data/repositories/regions_repository_impl.dart';
import 'package:arena_soccer/features/regions/domain/repositories/regions_repository_interface.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_region_preferences_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/save_region_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/save_season_usecase.dart';

final _sl = GetIt.instance;

void registerRegionsDependencies() {
  // DataSource
  _sl.registerLazySingleton<RegionsDataSource>(() => RegionsDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IRegionsRepository>(() => RegionsRepositoryImpl(_sl(), _sl()));

  // UseCases
  _sl.registerLazySingleton(() => GetRegionsUseCase(_sl()));
  _sl.registerLazySingleton(() => GetRegionPreferencesUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveRegionUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveSeasonUseCase(_sl()));
}
