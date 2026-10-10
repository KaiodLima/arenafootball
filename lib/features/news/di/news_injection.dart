import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/news/data/datasources/news_datasource.dart';
import 'package:arena_soccer/features/news/data/repositories/news_repository_impl.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';
import 'package:arena_soccer/features/news/domain/usecases/create_news_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/delete_news_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/update_news_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/watch_news_by_tag_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/watch_news_feed_usecase.dart';

final _sl = GetIt.instance;

void registerNewsDependencies() {
  // DataSource
  _sl.registerLazySingleton<NewsDataSource>(() => NewsDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<INewsRepository>(() => NewsRepositoryImpl(_sl()));

  // UseCases
  _sl.registerLazySingleton(() => WatchNewsFeedUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchNewsByTagUseCase(_sl()));
  _sl.registerLazySingleton(() => CreateNewsUseCase(_sl(), _sl()));
  _sl.registerLazySingleton(() => UpdateNewsUseCase(_sl(), _sl()));
  _sl.registerLazySingleton(() => DeleteNewsUseCase(_sl()));
}
