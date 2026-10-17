import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/fan_ranking/data/datasources/fan_ranking_datasource.dart';
import 'package:arena_soccer/features/fan_ranking/data/repositories/fan_ranking_repository_impl.dart';
import 'package:arena_soccer/features/fan_ranking/domain/repositories/fan_ranking_repository_interface.dart';
import 'package:arena_soccer/features/fan_ranking/domain/usecases/get_fan_ranking_cache_first_usecase.dart';

final _sl = GetIt.instance;

void registerFanRankingDependencies() {
  // DataSource
  _sl.registerLazySingleton<FanRankingDataSource>(() => FanRankingDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IFanRankingRepository>(() => FanRankingRepositoryImpl(_sl(), _sl()));

  // UseCases
  _sl.registerLazySingleton(() => GetFanRankingCacheFirstUseCase(_sl()));
}
