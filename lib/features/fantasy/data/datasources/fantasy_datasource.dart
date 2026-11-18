import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_config_dto.dart';

/// Arena Fantasy: a configuração por campeonato (`fantasy/{idDocCampeonato}`).
class FantasyDataSource {
  final FirebaseFirestore _firestore;

  FantasyDataSource(this._firestore);

  static const String _logName = 'FantasyDataSource';

  DocumentReference<Map<String, dynamic>> _doc(String championshipDocId) =>
      _firestore.collection(FantasyConfigDTO.collection).doc(championshipDocId);

  /// Configuração do [championship] (sem o doc = desligado com os padrões).
  Stream<Either<Failure, FantasyConfigDTO>> watchConfig(ChampionshipDTO championship) {
    return _doc(championship.id).snapshots().toEither(
          (doc) => FantasyConfigDTO.fromMap(doc.id, doc.data(), championship: championship),
          fallbackMessage: 'Não foi possível carregar o Arena Fantasy.',
          logName: _logName,
        );
  }

  /// Admin grava a chave, os parâmetros e as cópias do campeonato.
  Future<Either<Failure, void>> saveConfig(FantasyConfigDTO config) async {
    try {
      await _doc(config.championshipDocId).set(
        {...config.toAdminMap(), 'atualizadoEm': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
      return const Right(null);
    } catch (e) {
      AppLogger.e('saveConfig ${config.championshipDocId}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível salvar o Arena Fantasy.'));
    }
  }
}
