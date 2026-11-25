import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/app_version/domain/app_update.dart';

abstract class IAppVersionRepository {
  Future<Either<Failure, AppVersionConfig>> getConfig();

  Future<Either<Failure, void>> saveConfig(AppVersionConfig config);

  Future<int> installedBuild();

  Future<String> installedVersionName();

  /// Config do cache local (nunca falha: sem cache = `Right(null)`).
  Future<Either<Failure, CachedValue<AppVersionConfig>?>> getCachedConfig();

  Future<Either<Failure, void>> saveConfigCache(AppVersionConfig config);

  Future<void> deleteConfigCache();
}
