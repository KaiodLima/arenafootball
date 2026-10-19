import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_season_championships_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/set_team_championships_usecase.dart';
import 'package:arena_soccer/features/championships/data/datasources/championships_datasource.dart';
import 'package:arena_soccer/features/championships/data/repositories/championships_repository_impl.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';
import 'package:arena_soccer/features/championships/domain/usecases/delete_championship_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/delete_championships_cache_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_cached_region_championship_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_cached_region_championships_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championship_cache_first_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_cache_first_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championship_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/save_championship_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/save_region_championship_cache_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/save_region_championships_cache_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_championships_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_groups_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/watch_standings_usecase.dart';

final _sl = GetIt.instance;

void registerChampionshipsDependencies() {
  // DataSource
  _sl.registerLazySingleton<ChampionshipsDataSource>(() => ChampionshipsDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IChampionshipsRepository>(() => ChampionshipsRepositoryImpl(_sl(), _sl()));

  // UseCases
  _sl.registerLazySingleton(() => WatchChampionshipsUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchGroupsUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchStandingsUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveChampionshipUseCase(_sl(), _sl()));
  _sl.registerLazySingleton(() => DeleteChampionshipUseCase(_sl()));
  _sl.registerLazySingleton(() => GetRegionChampionshipUseCase(_sl()));
  _sl.registerLazySingleton(() => GetRegionChampionshipsUseCase(_sl()));

  // Cache local (ver `cacheFirst`)
  _sl.registerLazySingleton(() => GetCachedRegionChampionshipsUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveRegionChampionshipsCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => GetCachedRegionChampionshipUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveRegionChampionshipCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => DeleteChampionshipsCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => GetRegionChampionshipsCacheFirstUseCase(_sl(), _sl(), _sl()));
  _sl.registerLazySingleton(() => GetRegionChampionshipCacheFirstUseCase(_sl(), _sl(), _sl()));
  _sl.registerLazySingleton(() => GetSeasonChampionshipsUseCase(_sl()));
  _sl.registerLazySingleton(() => SetTeamChampionshipsUseCase(_sl()));
}
