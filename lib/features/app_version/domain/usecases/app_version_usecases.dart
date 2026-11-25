import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/app_version/domain/app_update.dart';
import 'package:arena_soccer/features/app_version/domain/repositories/app_version_repository_interface.dart';

/// As versões exigidas pelo admin (`config/versao`).
class GetAppVersionConfigUseCase {
  final IAppVersionRepository _repository;

  GetAppVersionConfigUseCase(this._repository);

  Future<Either<Failure, AppVersionConfig>> call() => _repository.getConfig();
}

/// Config das versões do cache local (nunca falha: sem cache = `Right(null)`).
class GetCachedAppVersionConfigUseCase {
  final IAppVersionRepository _repository;

  GetCachedAppVersionConfigUseCase(this._repository);

  Future<Either<Failure, CachedValue<AppVersionConfig>?>> call() => _repository.getCachedConfig();
}

class SaveAppVersionConfigCacheUseCase {
  final IAppVersionRepository _repository;

  SaveAppVersionConfigCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(AppVersionConfig config) => _repository.saveConfigCache(config);
}

/// Config das versões pelo fluxo [cacheFirst] (validade [CacheTtl.appVersion]),
/// para o aviso de atualização: uma leitura de `config/versao` a cada 6 h, não
/// a cada abertura. O painel do admin lê sempre o Firestore
/// ([GetAppVersionConfigUseCase]) e gravar apaga o cache.
class AppVersionCacheFirstUseCase {
  final GetAppVersionConfigUseCase _getConfig;
  final GetCachedAppVersionConfigUseCase _getCached;
  final SaveAppVersionConfigCacheUseCase _saveCache;

  AppVersionCacheFirstUseCase(this._getConfig, this._getCached, this._saveCache);

  Stream<Either<Failure, AppVersionConfig>> call({bool force = false}) => cacheFirst<AppVersionConfig>(
        readCache: _getCached.call,
        fetchRemote: _getConfig.call,
        saveCache: _saveCache.call,
        ttl: CacheTtl.appVersion,
        force: force,
        logName: 'AppVersionCacheFirstUseCase',
      );
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
