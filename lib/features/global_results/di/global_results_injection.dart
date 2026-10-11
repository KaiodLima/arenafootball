import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/global_results/data/datasources/global_results_datasource.dart';
import 'package:arena_soccer/features/global_results/data/parsers/soccer_stats_parser.dart';
import 'package:arena_soccer/features/global_results/data/repositories/global_results_repository_impl.dart';
import 'package:arena_soccer/features/global_results/domain/repositories/global_results_repository_interface.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_global_results_usecase.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_match_goals_usecase.dart';

final _sl = GetIt.instance;

void registerGlobalResultsDependencies() {
  // DataSource
  _sl.registerLazySingleton(() => SoccerStatsParser());
  _sl.registerLazySingleton<GlobalResultsDataSource>(() => GlobalResultsDataSource(_sl(), _sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IGlobalResultsRepository>(() => GlobalResultsRepositoryImpl(_sl()));

  // UseCases
  _sl.registerLazySingleton(() => GetGlobalResultsUseCase(_sl()));
  _sl.registerLazySingleton(() => GetMatchGoalsUseCase(_sl()));
}
