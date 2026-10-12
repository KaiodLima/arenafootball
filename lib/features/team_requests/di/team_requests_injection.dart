import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/team_requests/data/datasources/team_requests_datasource.dart';
import 'package:arena_soccer/features/team_requests/data/repositories/team_requests_repository_impl.dart';
import 'package:arena_soccer/features/team_requests/domain/repositories/team_requests_repository_interface.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/approve_team_request_usecase.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/cancel_team_request_usecase.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/reject_team_request_usecase.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/submit_team_request_usecase.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/update_team_request_usecase.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/watch_my_team_request_usecase.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/watch_pending_team_requests_count_usecase.dart';
import 'package:arena_soccer/features/team_requests/domain/usecases/watch_team_requests_usecase.dart';

final _sl = GetIt.instance;

void registerTeamRequestsDependencies() {
  // DataSource
  _sl.registerLazySingleton<TeamRequestsDataSource>(() => TeamRequestsDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<ITeamRequestsRepository>(() => TeamRequestsRepositoryImpl(_sl()));

  // UseCases
  _sl.registerLazySingleton(() => WatchMyTeamRequestUseCase(_sl()));
  _sl.registerLazySingleton(() => SubmitTeamRequestUseCase(_sl(), _sl()));
  _sl.registerLazySingleton(() => CancelTeamRequestUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchTeamRequestsUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchPendingTeamRequestsCountUseCase(_sl()));
  _sl.registerLazySingleton(() => UpdateTeamRequestUseCase(_sl()));
  _sl.registerLazySingleton(() => ApproveTeamRequestUseCase(_sl(), _sl()));
  _sl.registerLazySingleton(() => RejectTeamRequestUseCase(_sl()));
}
