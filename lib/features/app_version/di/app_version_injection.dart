import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/app_version/data/datasources/app_version_datasource.dart';
import 'package:arena_soccer/features/app_version/data/repositories/app_version_repository_impl.dart';
import 'package:arena_soccer/features/app_version/domain/repositories/app_version_repository_interface.dart';
import 'package:arena_soccer/features/app_version/domain/usecases/app_version_usecases.dart';
import 'package:arena_soccer/features/app_version/presentation/app_update_checker.dart';

final _sl = GetIt.instance;

void registerAppVersionDependencies() {
  // DataSource
  _sl.registerLazySingleton<AppVersionDataSource>(() => AppVersionDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IAppVersionRepository>(() => AppVersionRepositoryImpl(_sl(), _sl()));

  // UseCases
  _sl.registerLazySingleton(() => GetAppVersionConfigUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveAppVersionConfigUseCase(_sl()));
  _sl.registerLazySingleton(() => GetInstalledBuildUseCase(_sl()));

  // Cache local (ver `cacheFirst`)
  _sl.registerLazySingleton(() => GetCachedAppVersionConfigUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveAppVersionConfigCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => AppVersionCacheFirstUseCase(_sl(), _sl(), _sl()));

  // Aviso de atualização (home + volta do segundo plano).
  _sl.registerLazySingleton(() => AppUpdateChecker(_sl(), _sl(), _sl()));
}
