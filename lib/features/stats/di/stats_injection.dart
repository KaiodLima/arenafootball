import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_stats_ranking_usecase.dart';

final _sl = GetIt.instance;

/// Stats não tem DataSource próprio: usa os UseCases de times e jogadores.
/// Precisa ser registrado depois de `registerTeamsDependencies()` e
/// `registerPlayersDependencies()`.
void registerStatsDependencies() {
  // UseCases
  _sl.registerLazySingleton(() => GetStatsRankingUseCase(_sl(), _sl()));
}
