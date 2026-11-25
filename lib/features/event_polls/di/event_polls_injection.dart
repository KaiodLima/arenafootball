import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/event_polls/data/datasources/event_polls_datasource.dart';
import 'package:arena_soccer/features/event_polls/data/repositories/event_polls_repository_impl.dart';
import 'package:arena_soccer/features/event_polls/domain/repositories/event_polls_repository_interface.dart';
import 'package:arena_soccer/features/event_polls/domain/usecases/event_poll_usecase.dart';
import 'package:arena_soccer/features/event_polls/domain/usecases/manage_event_poll_usecase.dart';

final _sl = GetIt.instance;

void registerEventPollsDependencies() {
  // DataSource
  _sl.registerLazySingleton<EventPollsDataSource>(() => EventPollsDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IEventPollsRepository>(() => EventPollsRepositoryImpl(_sl(), _sl()));

  // UseCases
  _sl.registerLazySingleton(() => EventPollUseCase(_sl()));
  _sl.registerLazySingleton(() => ManageEventPollUseCase(_sl(), _sl()));
}
