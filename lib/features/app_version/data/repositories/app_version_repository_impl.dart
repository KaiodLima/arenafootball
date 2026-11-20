import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/app_version/data/datasources/app_version_datasource.dart';
import 'package:arena_soccer/features/app_version/domain/app_update.dart';
import 'package:arena_soccer/features/app_version/domain/repositories/app_version_repository_interface.dart';

class AppVersionRepositoryImpl implements IAppVersionRepository {
  final AppVersionDataSource _dataSource;

  AppVersionRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, AppVersionConfig>> getConfig() => _dataSource.getConfig();

  @override
  Future<Either<Failure, void>> saveConfig(AppVersionConfig config) => _dataSource.saveConfig(config);

  @override
  Future<int> installedBuild() => _dataSource.installedBuild();

  @override
  Future<String> installedVersionName() => _dataSource.installedVersionName();
}
