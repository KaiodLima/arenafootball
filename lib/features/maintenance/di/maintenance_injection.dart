import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/maintenance/data/datasources/maintenance_datasource.dart';
import 'package:arena_soccer/features/maintenance/data/repositories/maintenance_repository_impl.dart';
import 'package:arena_soccer/features/maintenance/domain/repositories/maintenance_repository_interface.dart';
import 'package:arena_soccer/features/maintenance/domain/usecases/recompress_images_usecase.dart';

final _sl = GetIt.instance;

void registerMaintenanceDependencies() {
  // DataSource
  _sl.registerLazySingleton<MaintenanceDataSource>(() => MaintenanceDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IMaintenanceRepository>(() => MaintenanceRepositoryImpl(_sl()));

  // UseCases
  _sl.registerLazySingleton(() => RecompressImagesUseCase(_sl()));
}
