import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/predictions/data/datasources/predictions_datasource.dart';
import 'package:arena_soccer/features/predictions/data/repositories/predictions_repository_impl.dart';
import 'package:arena_soccer/features/predictions/domain/repositories/predictions_repository_interface.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/count_predictions_usecase.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/get_my_predictions_usecase.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/get_prediction_ranking_usecase.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/my_predictions_cache_usecases.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/prediction_count_cache_usecases.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/prediction_ranking_cache_usecases.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/save_prediction_usecase.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/watch_my_prediction_usecase.dart';

final _sl = GetIt.instance;

void registerPredictionsDependencies() {
  // DataSource
  _sl.registerLazySingleton<PredictionsDataSource>(() => PredictionsDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IPredictionsRepository>(() => PredictionsRepositoryImpl(_sl(), _sl()));

  // UseCases
  _sl.registerLazySingleton(() => WatchMyPredictionUseCase(_sl()));
  _sl.registerLazySingleton(() => SavePredictionUseCase(_sl()));
  _sl.registerLazySingleton(() => CountPredictionsUseCase(_sl()));
  _sl.registerLazySingleton(() => GetPredictionRankingUseCase(_sl()));
  _sl.registerLazySingleton(() => GetMyPredictionsUseCase(_sl()));

  // Cache local (ver `cacheFirst`)
  _sl.registerLazySingleton(() => GetCachedPredictionRankingUseCase(_sl()));
  _sl.registerLazySingleton(() => SavePredictionRankingCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => GetPredictionRankingCacheFirstUseCase(_sl(), _sl(), _sl()));
  _sl.registerLazySingleton(() => GetCachedMyPredictionsUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveMyPredictionsCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => GetMyPredictionsCacheFirstUseCase(_sl(), _sl(), _sl()));
  _sl.registerLazySingleton(() => GetCachedPredictionCountUseCase(_sl()));
  _sl.registerLazySingleton(() => SavePredictionCountCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => CountPredictionsCacheFirstUseCase(_sl(), _sl(), _sl()));
}
