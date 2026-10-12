import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/player_requests/data/datasources/player_requests_datasource.dart';
import 'package:arena_soccer/features/player_requests/data/repositories/player_requests_repository_impl.dart';
import 'package:arena_soccer/features/player_requests/domain/repositories/player_requests_repository_interface.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/approve_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/cancel_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/reject_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/submit_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/update_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/watch_my_player_request_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/watch_pending_player_requests_count_usecase.dart';
import 'package:arena_soccer/features/player_requests/domain/usecases/watch_player_requests_usecase.dart';

final _sl = GetIt.instance;

void registerPlayerRequestsDependencies() {
  // DataSource
  _sl.registerLazySingleton<PlayerRequestsDataSource>(() => PlayerRequestsDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IPlayerRequestsRepository>(() => PlayerRequestsRepositoryImpl(_sl()));

  // UseCases
  _sl.registerLazySingleton(() => WatchMyPlayerRequestUseCase(_sl()));
  _sl.registerLazySingleton(() => SubmitPlayerRequestUseCase(_sl(), _sl()));
  _sl.registerLazySingleton(() => CancelPlayerRequestUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchPlayerRequestsUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchPendingPlayerRequestsCountUseCase(_sl()));
  _sl.registerLazySingleton(() => UpdatePlayerRequestUseCase(_sl()));
  _sl.registerLazySingleton(() => ApprovePlayerRequestUseCase(_sl()));
  _sl.registerLazySingleton(() => RejectPlayerRequestUseCase(_sl()));
}
