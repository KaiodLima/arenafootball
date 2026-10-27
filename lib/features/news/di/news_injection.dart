import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/news/domain/usecases/pending_news_usecase.dart';
import 'package:arena_soccer/features/news/data/datasources/news_datasource.dart';
import 'package:arena_soccer/features/news/data/repositories/news_repository_impl.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';
import 'package:arena_soccer/features/news/domain/usecases/create_news_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/delete_goal_cards_cache_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/delete_news_cache_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/delete_news_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_cached_goal_cards_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_cached_news_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_news_by_id_cache_first_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_news_by_id_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_news_page_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_player_goal_cards_cache_first_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_player_goal_cards_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/save_goal_cards_cache_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/save_news_cache_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/update_news_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/watch_news_by_tag_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/watch_news_feed_usecase.dart';

final _sl = GetIt.instance;

void registerNewsDependencies() {
  // DataSource
  _sl.registerLazySingleton<NewsDataSource>(() => NewsDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<INewsRepository>(() => NewsRepositoryImpl(_sl(), _sl()));

  // UseCases
  _sl.registerLazySingleton(() => WatchNewsFeedUseCase(_sl()));
  _sl.registerLazySingleton(() => GetNewsPageUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchNewsByTagUseCase(_sl()));
  _sl.registerLazySingleton(() => CreateNewsUseCase(_sl(), _sl()));
  _sl.registerLazySingleton(() => UpdateNewsUseCase(_sl(), _sl()));
  _sl.registerLazySingleton(() => DeleteNewsUseCase(_sl()));
  _sl.registerLazySingleton(() => GetPlayerGoalCardsUseCase(_sl()));
  _sl.registerLazySingleton(() => GetNewsByIdUseCase(_sl()));
  _sl.registerLazySingleton(() => PendingNewsUseCase(_sl()));

  // Cache local (ver `cacheFirst`)
  _sl.registerLazySingleton(() => GetCachedGoalCardsUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveGoalCardsCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => DeleteGoalCardsCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => GetPlayerGoalCardsCacheFirstUseCase(_sl(), _sl(), _sl()));
  _sl.registerLazySingleton(() => GetCachedNewsUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveNewsCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => DeleteNewsCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => GetNewsByIdCacheFirstUseCase(_sl(), _sl(), _sl()));
}
