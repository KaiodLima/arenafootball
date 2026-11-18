import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/fantasy/data/datasources/fantasy_datasource.dart';
import 'package:arena_soccer/features/fantasy/data/repositories/fantasy_repository_impl.dart';
import 'package:arena_soccer/features/fantasy/domain/repositories/fantasy_repository_interface.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_config_usecases.dart';

final _sl = GetIt.instance;

void registerFantasyDependencies() {
  // DataSource
  _sl.registerLazySingleton<FantasyDataSource>(() => FantasyDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IFantasyRepository>(() => FantasyRepositoryImpl(_sl()));

  // UseCases
  _sl.registerLazySingleton(() => WatchFantasyConfigUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveFantasyConfigUseCase(_sl()));
}
