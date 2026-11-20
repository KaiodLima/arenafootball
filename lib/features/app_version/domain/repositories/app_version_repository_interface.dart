import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/app_version/domain/app_update.dart';

abstract class IAppVersionRepository {
  Future<Either<Failure, AppVersionConfig>> getConfig();

  Future<Either<Failure, void>> saveConfig(AppVersionConfig config);

  Future<int> installedBuild();

  Future<String> installedVersionName();
}
