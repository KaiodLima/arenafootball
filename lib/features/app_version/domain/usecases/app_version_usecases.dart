import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/app_version/domain/app_update.dart';
import 'package:arena_soccer/features/app_version/domain/repositories/app_version_repository_interface.dart';

/// As versões exigidas pelo admin (`config/versao`).
class GetAppVersionConfigUseCase {
  final IAppVersionRepository _repository;

  GetAppVersionConfigUseCase(this._repository);

  Future<Either<Failure, AppVersionConfig>> call() => _repository.getConfig();
}

/// Admin grava as versões exigidas.
class SaveAppVersionConfigUseCase {
  final IAppVersionRepository _repository;

  SaveAppVersionConfigUseCase(this._repository);

  Future<Either<Failure, void>> call(AppVersionConfig config) => _repository.saveConfig(config);
}

/// Número do build instalado no aparelho (0 = desconhecido).
class GetInstalledBuildUseCase {
  final IAppVersionRepository _repository;

  GetInstalledBuildUseCase(this._repository);

  Future<int> call() => _repository.installedBuild();

  /// Nome da versão instalada (o que aparece na loja: 2.0.18 / 1.0.18).
  Future<String> name() => _repository.installedVersionName();
}
