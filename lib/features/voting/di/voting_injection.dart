import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/voting/data/datasources/voting_datasource.dart';
import 'package:arena_soccer/features/voting/data/repositories/voting_repository_impl.dart';
import 'package:arena_soccer/features/voting/domain/repositories/voting_repository_interface.dart';
import 'package:arena_soccer/features/voting/domain/usecases/calculate_best_player_usecase.dart';
import 'package:arena_soccer/features/voting/domain/usecases/cast_vote_usecase.dart';
import 'package:arena_soccer/features/voting/domain/usecases/get_elected_player_usecase.dart';
import 'package:arena_soccer/features/voting/domain/usecases/get_my_vote_usecase.dart';

final _sl = GetIt.instance;

/// Depende de teams e players (registrar depois deles).
void registerVotingDependencies() {
  // DataSource
  _sl.registerLazySingleton<VotingDataSource>(() => VotingDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IVotingRepository>(() => VotingRepositoryImpl(_sl()));

  // UseCases
  _sl.registerLazySingleton(() => CastVoteUseCase(_sl()));
  _sl.registerLazySingleton(() => CalculateBestPlayerUseCase(_sl()));
  _sl.registerLazySingleton(() => GetMyVoteUseCase(_sl()));
  _sl.registerLazySingleton(() => GetElectedPlayerUseCase(_sl(), _sl(), _sl()));
}
