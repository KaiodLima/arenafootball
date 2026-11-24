import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/scoring/data/datasources/scoring_datasource.dart';
import 'package:arena_soccer/features/scoring/data/repositories/scoring_repository_impl.dart';
import 'package:arena_soccer/features/scoring/domain/repositories/scoring_repository_interface.dart';
import 'package:arena_soccer/features/scoring/domain/usecases/scoring_usecases.dart';

final _sl = GetIt.instance;

void registerScoringDependencies() {
  // DataSource
  _sl.registerLazySingleton<ScoringDataSource>(() => ScoringDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IScoringRepository>(() => ScoringRepositoryImpl(_sl()));

  // UseCases
  _sl.registerLazySingleton(() => WatchFantasyScoringTableUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchPredictionRulesUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveFantasyScoringTableUseCase(_sl()));
  _sl.registerLazySingleton(() => SavePredictionRulesUseCase(_sl()));
}
