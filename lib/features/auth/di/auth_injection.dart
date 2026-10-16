import 'package:get_it/get_it.dart';
import 'package:arena_soccer/features/auth/data/datasources/auth_datasource.dart';
import 'package:arena_soccer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:arena_soccer/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:arena_soccer/features/auth/domain/usecases/clear_cache_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/delete_user_cache_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/get_account_created_at_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/get_cached_user_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/save_user_cache_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/update_user_photo_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/send_password_reset_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/update_favorite_team_usecase.dart';

final _sl = GetIt.instance;

void registerAuthDependencies() {
  // DataSource
  _sl.registerLazySingleton<AuthDataSource>(() => AuthDataSource(_sl(), _sl(), _sl()));

  // Repository (interface -> impl)
  _sl.registerLazySingleton<IAuthRepository>(() => AuthRepositoryImpl(_sl(), _sl()));

  // UseCases
  _sl.registerLazySingleton(() => SignInUseCase(_sl()));
  _sl.registerLazySingleton(() => SignInWithGoogleUseCase(_sl()));
  _sl.registerLazySingleton(() => SignUpUseCase(_sl()));
  _sl.registerLazySingleton(() => SignOutUseCase(_sl()));
  _sl.registerLazySingleton(() => GetCurrentUserUseCase(_sl()));
  _sl.registerLazySingleton(() => SendPasswordResetUseCase(_sl()));
  _sl.registerLazySingleton(() => UpdateFavoriteTeamUseCase(_sl()));
  _sl.registerLazySingleton(() => UpdateUserPhotoUseCase(_sl(), _sl()));
  _sl.registerLazySingleton(() => GetAccountCreatedAtUseCase(_sl()));

  // Cache local
  _sl.registerLazySingleton(() => GetCachedUserUseCase(_sl()));
  _sl.registerLazySingleton(() => SaveUserCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => DeleteUserCacheUseCase(_sl()));
  _sl.registerLazySingleton(() => ClearCacheUseCase(_sl()));
}
