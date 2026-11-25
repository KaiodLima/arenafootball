import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/fantasy/data/datasources/fantasy_datasource.dart';
import 'package:arena_soccer/features/fantasy/data/repositories/fantasy_repository_impl.dart';
import 'package:arena_soccer/features/fantasy/domain/repositories/fantasy_repository_interface.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_admin_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_config_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_lineup_usecases.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_ranking_usecases.dart';

final _sl = GetIt.instance;

void registerFantasyDependencies() {
  // DataSource
  _sl.registerLazySingleton<FantasyDataSource>(() => FantasyDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IFantasyRepository>(() => FantasyRepositoryImpl(_sl(), _sl()));

  // UseCases
  _sl.registerLazySingleton(() => WatchFantasyConfigUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveFantasyConfigUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchActiveFantasiesUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchFantasyRoundUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchFantasyParticipantUseCase(_sl()));
  _sl.registerLazySingleton(() => JoinFantasyUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchFantasyLineupUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveFantasyLineupUseCase(_sl()));
  _sl.registerLazySingleton(() => GetFantasyAthletesCacheFirstUseCase(_sl()));
  _sl.registerLazySingleton(() => GetFantasyRankingCacheFirstUseCase(_sl()));
  _sl.registerLazySingleton(() => GetFantasyTopAthletesCacheFirstUseCase(_sl()));
  _sl.registerLazySingleton(() => GetFantasyPositionUseCase(_sl()));
  _sl.registerLazySingleton(() => GetFantasyRoundsUseCase(_sl()));
  _sl.registerLazySingleton(() => GetFantasyRoundsCacheFirstUseCase(_sl()));
  _sl.registerLazySingleton(() => GetFantasyPositionCacheFirstUseCase(_sl()));
  _sl.registerLazySingleton(() => GetFantasyRoundRecordUseCase(_sl()));
  _sl.registerLazySingleton(() => GetFantasyAthleteScoreCacheFirstUseCase(_sl()));
  _sl.registerLazySingleton(() => GetFantasyLineupUseCase(_sl()));
  _sl.registerLazySingleton(() => GetFantasyAthleteScoreUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchFantasyRoundsUseCase(_sl()));
  _sl.registerLazySingleton(() => GetFantasyParticipantsUseCase(_sl()));
  _sl.registerLazySingleton(() => RequestFantasyRescoreUseCase(_sl()));
  _sl.registerLazySingleton(() => RequestFantasyResetUseCase(_sl()));
  _sl.registerLazySingleton(() => RequestFantasyTeamsResetUseCase(_sl()));
  _sl.registerLazySingleton(() => RequestFantasyRoundActionUseCase(_sl()));
}
