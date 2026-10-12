import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/highlights/data/datasources/highlights_datasource.dart';
import 'package:arena_soccer/features/highlights/data/repositories/highlights_repository_impl.dart';
import 'package:arena_soccer/features/highlights/domain/repositories/highlights_repository_interface.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/create_highlight_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/delete_highlight_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/get_highlights_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/reorder_highlights_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/set_highlight_visible_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/update_highlight_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/watch_all_highlights_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/watch_highlights_usecase.dart';

final _sl = GetIt.instance;

void registerHighlightsDependencies() {
  // DataSource
  _sl.registerLazySingleton<HighlightsDataSource>(() => HighlightsDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IHighlightsRepository>(() => HighlightsRepositoryImpl(_sl()));

  // UseCases
  _sl.registerLazySingleton(() => WatchHighlightsUseCase(_sl()));
  _sl.registerLazySingleton(() => CreateHighlightUseCase(_sl(), _sl()));
  _sl.registerLazySingleton(() => GetHighlightsUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchAllHighlightsUseCase(_sl()));
  _sl.registerLazySingleton(() => UpdateHighlightUseCase(_sl(), _sl()));
  _sl.registerLazySingleton(() => DeleteHighlightUseCase(_sl()));
  _sl.registerLazySingleton(() => ReorderHighlightsUseCase(_sl()));
  _sl.registerLazySingleton(() => SetHighlightVisibleUseCase(_sl()));
}
