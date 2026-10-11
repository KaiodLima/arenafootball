import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/matches/data/datasources/matches_datasource.dart';
import 'package:arena_soccer/features/matches/data/repositories/matches_repository_impl.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/matches/domain/usecases/create_match_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/delete_match_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/toggle_match_voting_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_region_matches_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_today_matches_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/update_match_score_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/watch_matches_usecase.dart';

final _sl = GetIt.instance;

void registerMatchesDependencies() {
  // DataSource
  _sl.registerLazySingleton<MatchesDataSource>(() => MatchesDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IMatchesRepository>(() => MatchesRepositoryImpl(_sl()));

  // UseCases
  _sl.registerLazySingleton(() => WatchMatchesUseCase(_sl()));
  _sl.registerLazySingleton(() => CreateMatchUseCase(_sl()));
  _sl.registerLazySingleton(() => UpdateMatchScoreUseCase(_sl()));
  _sl.registerLazySingleton(() => GetTodayMatchesUseCase(_sl()));
  _sl.registerLazySingleton(() => GetRegionMatchesUseCase(_sl()));
  _sl.registerLazySingleton(() => ToggleMatchVotingUseCase(_sl()));
  _sl.registerLazySingleton(() => DeleteMatchUseCase(_sl()));
}
