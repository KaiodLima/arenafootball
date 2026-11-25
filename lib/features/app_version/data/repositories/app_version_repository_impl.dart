import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/app_version/data/datasources/app_version_datasource.dart';
import 'package:arena_soccer/features/app_version/domain/app_update.dart';
import 'package:arena_soccer/features/app_version/domain/repositories/app_version_repository_interface.dart';

class AppVersionRepositoryImpl implements IAppVersionRepository {
  final AppVersionDataSource _dataSource;
  final CacheStore _cache;

  AppVersionRepositoryImpl(this._dataSource, this._cache);

  @override
  Future<Either<Failure, AppVersionConfig>> getConfig() => _dataSource.getConfig();

  @override
  Future<Either<Failure, void>> saveConfig(AppVersionConfig config) async {
    final response = await _dataSource.saveConfig(config);
    // O aviso deste aparelho passa a ler a config nova.
    if (response.isRight) await deleteConfigCache();
    return response;
  }

  @override
  Future<int> installedBuild() => _dataSource.installedBuild();

  @override
  Future<String> installedVersionName() => _dataSource.installedVersionName();

  @override
  Future<Either<Failure, CachedValue<AppVersionConfig>?>> getCachedConfig() => _cache.read(
        CacheKeys.appVersion,
        (json) => AppVersionConfig.fromCache(Map<String, dynamic>.from(json as Map)),
      );

  @override
  Future<Either<Failure, void>> saveConfigCache(AppVersionConfig config) =>
      _cache.save(CacheKeys.appVersion, config.toCache());

  @override
  Future<void> deleteConfigCache() => _cache.delete(CacheKeys.appVersion);
}
