import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/organizer_requests/data/datasources/organizer_requests_datasource.dart';
import 'package:arena_soccer/features/organizer_requests/data/repositories/organizer_requests_repository_impl.dart';
import 'package:arena_soccer/features/organizer_requests/domain/repositories/organizer_requests_repository_interface.dart';
import 'package:arena_soccer/features/organizer_requests/domain/usecases/organizer_request_usecases.dart';

final _sl = GetIt.instance;

void registerOrganizerRequestsDependencies() {
  // DataSource
  _sl.registerLazySingleton<OrganizerRequestsDataSource>(() => OrganizerRequestsDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IOrganizerRequestsRepository>(() => OrganizerRequestsRepositoryImpl(_sl(), _sl()));

  // UseCases
  _sl.registerLazySingleton(() => WatchMyOrganizerRequestUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchMyChampionshipsUseCase(_sl()));
  _sl.registerLazySingleton(() => SubmitOrganizerRequestUseCase(_sl(), _sl()));
  _sl.registerLazySingleton(() => CancelOrganizerRequestUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchOrganizerRequestsUseCase(_sl()));
  _sl.registerLazySingleton(() => UpdateOrganizerRequestUseCase(_sl()));
  _sl.registerLazySingleton(() => ApproveOrganizerRequestUseCase(_sl()));
  _sl.registerLazySingleton(() => RejectOrganizerRequestUseCase(_sl()));
  _sl.registerLazySingleton(() => EnsureOrganizerIndexesUseCase(_sl()));
  _sl.registerLazySingleton(() => EnsureMyOrganizerIndexesUseCase(_sl()));
}
