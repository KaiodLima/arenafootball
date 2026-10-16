import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/regions/data/datasources/regions_datasource.dart';
import 'package:arena_soccer/features/regions/data/repositories/regions_repository_impl.dart';
import 'package:arena_soccer/features/regions/domain/repositories/regions_repository_interface.dart';
import 'package:arena_soccer/features/regions/domain/usecases/create_region_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/delete_regions_cache_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_cached_regions_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_cache_first_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/save_regions_cache_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/manage_region_usecases.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_region_preferences_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/save_region_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/save_season_usecase.dart';

final _sl = GetIt.instance;

void registerRegionsDependencies() {
  // DataSource
  _sl.registerLazySingleton<RegionsDataSource>(() => RegionsDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IRegionsRepository>(() => RegionsRepositoryImpl(_sl(), _sl(), _sl()));

  // UseCases
  _sl.registerLazySingleton(() => GetRegionsUseCase(_sl()));
  _sl.registerLazySingleton(() => GetCachedRegionsUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveRegionsCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => DeleteRegionsCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => GetRegionsCacheFirstUseCase(_sl(), _sl(), _sl()));
  _sl.registerLazySingleton(() => CreateRegionUseCase(_sl()));
  _sl.registerLazySingleton(() => RenameRegionUseCase(_sl()));
  _sl.registerLazySingleton(() => DeleteRegionUseCase(_sl()));
  _sl.registerLazySingleton(() => LinkRegionsByIdUseCase(_sl()));
  _sl.registerLazySingleton(() => GetRegionPreferencesUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveRegionUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveSeasonUseCase(_sl()));
}
