import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/seasons/data/datasources/seasons_datasource.dart';
import 'package:arena_soccer/features/seasons/data/repositories/seasons_repository_impl.dart';
import 'package:arena_soccer/features/seasons/domain/repositories/seasons_repository_interface.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/delete_seasons_config_cache_usecase.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/get_cached_seasons_config_usecase.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/get_seasons_config_cache_first_usecase.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/get_seasons_config_usecase.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/save_seasons_config_cache_usecase.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/link_teams_by_id_usecase.dart';
import 'package:arena_soccer/features/seasons/domain/usecases/start_season_usecase.dart';

final _sl = GetIt.instance;

void registerSeasonsDependencies() {
  // DataSource
  _sl.registerLazySingleton<SeasonsDataSource>(() => SeasonsDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<ISeasonsRepository>(() => SeasonsRepositoryImpl(_sl(), _sl()));

  // UseCases
  _sl.registerLazySingleton(() => GetSeasonsConfigUseCase(_sl()));
  _sl.registerLazySingleton(() => GetCachedSeasonsConfigUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveSeasonsConfigCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => DeleteSeasonsConfigCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => GetSeasonsConfigCacheFirstUseCase(_sl(), _sl(), _sl()));
  _sl.registerLazySingleton(() => StartSeasonUseCase(_sl()));
  _sl.registerLazySingleton(() => LinkTeamsByIdUseCase(_sl()));
}
