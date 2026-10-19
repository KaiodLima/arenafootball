import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/stats/data/repositories/stats_repository_impl.dart';
import 'package:arena_soccer/features/stats/domain/repositories/stats_repository_interface.dart';
import 'package:arena_soccer/features/stats/domain/usecases/delete_stats_ranking_cache_usecase.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_cached_stats_ranking_usecase.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_stats_ranking_cache_first_usecase.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_stats_ranking_usecase.dart';
import 'package:arena_soccer/features/stats/domain/usecases/save_stats_ranking_cache_usecase.dart';

final _sl = GetIt.instance;

/// Stats não tem DataSource próprio: usa os UseCases de times e jogadores
/// (o repositório só guarda o ranking no cache local). Precisa ser
/// registrado depois de `registerTeamsDependencies()` e
/// `registerPlayersDependencies()`.
void registerStatsDependencies() {
  // Repository (interface -> impl)
  _sl.registerLazySingleton<IStatsRepository>(() => StatsRepositoryImpl(_sl()));

  // UseCases
  _sl.registerLazySingleton(() => GetStatsRankingUseCase(_sl(), _sl(), _sl()));

  // Cache local (ver `cacheFirst`)
  _sl.registerLazySingleton(() => GetCachedStatsRankingUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveStatsRankingCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => DeleteStatsRankingCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => GetStatsRankingCacheFirstUseCase(_sl(), _sl(), _sl()));
}
