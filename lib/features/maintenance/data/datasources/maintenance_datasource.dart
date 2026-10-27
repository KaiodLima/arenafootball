import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/maintenance/data/dtos/recompress_status_dto.dart';

/// Manutenções do admin feitas pelas Cloud Functions (`manutencao/{id}`): o
/// app pede e acompanha o progresso.
class MaintenanceDataSource {
  final FirebaseFirestore _firestore;

  MaintenanceDataSource(this._firestore);

  static const String _logName = 'MaintenanceDataSource';

  DocumentReference<Map<String, dynamic>> get _recompress => _firestore.doc('manutencao/recomprimir');

  Stream<Either<Failure, RecompressStatusDTO>> watchRecompress() {
    return _recompress.snapshots().toEither(
          (doc) => doc.exists ? RecompressStatusDTO.fromMap(doc.data()!) : const RecompressStatusDTO(),
          fallbackMessage: 'Não foi possível carregar a manutenção.',
          logName: _logName,
        );
  }

  /// Pede a recompressão das imagens antigas (a function começa do zero).
  Future<Either<Failure, void>> requestRecompress() async {
    try {
      await _recompress.set({
        'status': RecompressPhase.requested.key,
        'pedidoEm': FieldValue.serverTimestamp(),
        'erro': '',
      }, SetOptions(merge: true));
      return const Right(null);
    } catch (e) {
      AppLogger.e('requestRecompress', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível pedir a recompressão.'));
    }
  }
}
