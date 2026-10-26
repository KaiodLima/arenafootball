import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/predictions/data/datasources/predictions_datasource.dart';
import 'package:arena_soccer/features/predictions/data/repositories/predictions_repository_impl.dart';
import 'package:arena_soccer/features/predictions/domain/repositories/predictions_repository_interface.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/count_predictions_usecase.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/get_prediction_ranking_usecase.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/save_prediction_usecase.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/watch_my_prediction_usecase.dart';

final _sl = GetIt.instance;

void registerPredictionsDependencies() {
  // DataSource
  _sl.registerLazySingleton<PredictionsDataSource>(() => PredictionsDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IPredictionsRepository>(() => PredictionsRepositoryImpl(_sl()));

  // UseCases
  _sl.registerLazySingleton(() => WatchMyPredictionUseCase(_sl()));
  _sl.registerLazySingleton(() => SavePredictionUseCase(_sl()));
  _sl.registerLazySingleton(() => CountPredictionsUseCase(_sl()));
  _sl.registerLazySingleton(() => GetPredictionRankingUseCase(_sl()));
}
