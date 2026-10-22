import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/achievements/data/datasources/achievements_datasource.dart';
import 'package:arena_soccer/features/achievements/data/repositories/achievements_repository_impl.dart';
import 'package:arena_soccer/features/achievements/domain/repositories/achievements_repository_interface.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/watch_achievements_catalog_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/watch_achievement_progress_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/watch_achievement_unlocks_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/save_achievement_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/delete_achievement_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/create_suggested_achievements_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/record_achievement_action_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/record_daily_visit_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/mark_achievement_seen_usecase.dart';

final _sl = GetIt.instance;

void registerAchievementsDependencies() {
  // DataSource
  _sl.registerLazySingleton<AchievementsDataSource>(() => AchievementsDataSource(_sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IAchievementsRepository>(() => AchievementsRepositoryImpl(_sl()));

  // UseCases
  _sl.registerLazySingleton(() => WatchAchievementsCatalogUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchAchievementProgressUseCase(_sl()));
  _sl.registerLazySingleton(() => WatchAchievementUnlocksUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveAchievementUseCase(_sl()));
  _sl.registerLazySingleton(() => DeleteAchievementUseCase(_sl()));
  _sl.registerLazySingleton(() => CreateSuggestedAchievementsUseCase(_sl()));
  _sl.registerLazySingleton(() => RecordAchievementActionUseCase(_sl()));
  _sl.registerLazySingleton(() => RecordDailyVisitUseCase(_sl()));
  _sl.registerLazySingleton(() => MarkAchievementSeenUseCase(_sl()));
}
