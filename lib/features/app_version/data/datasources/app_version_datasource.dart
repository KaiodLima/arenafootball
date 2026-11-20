import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/app_version/domain/app_update.dart';

/// Versão do app: as exigidas pelo admin (`config/versao`) e o build instalado.
class AppVersionDataSource {
  final FirebaseFirestore _firestore;

  AppVersionDataSource(this._firestore);

  static const String _logName = 'AppVersionDataSource';

  DocumentReference<Map<String, dynamic>> get _doc => _firestore.doc('config/versao');

  /// As versões exigidas (sem o doc = sem exigência). Uma leitura; offline,
  /// o cache do Firestore.
  Future<Either<Failure, AppVersionConfig>> getConfig() async {
    try {
      final snap = await _doc.get();
      return Right(AppVersionConfig.fromMap(snap.data()));
    } catch (e) {
      AppLogger.e('getConfig', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível ler a versão do app.'));
    }
  }

  /// Admin grava as versões (merge; `atualizadoEm` = hora do servidor).
  Future<Either<Failure, void>> saveConfig(AppVersionConfig config) async {
    try {
      await _doc.set({...config.toMap(), 'atualizadoEm': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      return const Right(null);
    } catch (e) {
      AppLogger.e('saveConfig', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível salvar a versão do app.'));
    }
  }

  /// Nome da versão instalada (`2.0.18` no Android, `1.0.18` no iOS); vazio se não der para ler.
  Future<String> installedVersionName() async {
    try {
      return (await PackageInfo.fromPlatform()).version;
    } catch (e) {
      AppLogger.e('installedVersionName', name: _logName, error: e);
      return '';
    }
  }

  /// Número do build instalado (o `+N`); 0 se não der para ler.
  Future<int> installedBuild() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return int.tryParse(info.buildNumber) ?? 0;
    } catch (e) {
      AppLogger.e('installedBuild', name: _logName, error: e);
      return 0;
    }
  }
}
