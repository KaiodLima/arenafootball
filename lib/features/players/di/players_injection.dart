import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/players/data/datasources/players_datasource.dart';
import 'package:arena_soccer/features/players/data/repositories/players_repository_impl.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';
import 'package:arena_soccer/features/players/domain/usecases/add_player_stats_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/create_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/delete_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/get_players_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/remove_player_from_squad_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/update_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';

final _sl = GetIt.instance;

void registerPlayersDependencies() {
  // DataSource
  _sl.registerLazySingleton<PlayersDataSource>(() => PlayersDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IPlayersRepository>(() => PlayersRepositoryImpl(_sl()));

  // UseCases
  _sl.registerLazySingleton(() => WatchTeamPlayersUseCase(_sl()));
  _sl.registerLazySingleton(() => GetPlayersUseCase(_sl()));
  _sl.registerLazySingleton(() => CreatePlayerUseCase(_sl(), _sl()));
  _sl.registerLazySingleton(() => AddPlayerStatsUseCase(_sl()));
  _sl.registerLazySingleton(() => UpdatePlayerUseCase(_sl(), _sl()));
  _sl.registerLazySingleton(() => WatchPlayerUseCase(_sl()));
  _sl.registerLazySingleton(() => DeletePlayerUseCase(_sl()));
  _sl.registerLazySingleton(() => RemovePlayerFromSquadUseCase(_sl()));
}
