import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/teams/data/datasources/teams_datasource.dart';
import 'package:arena_soccer/features/teams/data/repositories/teams_repository_impl.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';
import 'package:arena_soccer/features/teams/domain/usecases/delete_team_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/delete_teams_cache_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_cached_team_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_cached_teams_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_team_by_name_cache_first_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/save_team_cache_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/save_teams_cache_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_team_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/update_team_details_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/create_team_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_next_team_number_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_team_by_name_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/watch_teams_usecase.dart';

final _sl = GetIt.instance;

void registerTeamsDependencies() {
  // DataSource
  _sl.registerLazySingleton<TeamsDataSource>(() => TeamsDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<ITeamsRepository>(() => TeamsRepositoryImpl(_sl(), _sl()));

  // UseCases
  _sl.registerLazySingleton(() => GetTeamsUseCase(_sl()));
  _sl.registerLazySingleton(() => GetTeamByNameUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchTeamsUseCase(_sl()));
  _sl.registerLazySingleton(() => GetNextTeamNumberUseCase(_sl()));
  _sl.registerLazySingleton(() => CreateTeamUseCase(_sl(), _sl(), _sl()));
  _sl.registerLazySingleton(() => GetTeamUseCase(_sl()));
  _sl.registerLazySingleton(() => UpdateTeamDetailsUseCase(_sl(), _sl()));
  _sl.registerLazySingleton(() => DeleteTeamUseCase(_sl()));

  // Cache local (ver `cacheFirst`)
  _sl.registerLazySingleton(() => GetCachedTeamsUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveTeamsCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => GetCachedTeamUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveTeamCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => DeleteTeamsCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => GetTeamsCacheFirstUseCase(_sl(), _sl(), _sl()));
  _sl.registerLazySingleton(() => GetTeamByNameCacheFirstUseCase(_sl(), _sl(), _sl()));
}
