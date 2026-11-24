import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_scoring_table.dart';
import 'package:arena_soccer/features/predictions/domain/prediction_rules.dart';

/// Pontuações editáveis pelo admin: a tabela padrão do Arena Fantasy
/// (`config/pontuacao_fantasy`, campo `tabela`) e os pontos do bolão
/// (`config/bolao`). Leitura pública (dois docs pequenos, em stream: o cache
/// do Firestore serve as telas); escrita do admin.
class ScoringDataSource {
  final FirebaseFirestore _firestore;

  ScoringDataSource(this._firestore);

  static const String _logName = 'ScoringDataSource';

  DocumentReference<Map<String, dynamic>> get _fantasy => _firestore.doc('config/pontuacao_fantasy');
  DocumentReference<Map<String, dynamic>> get _bolao => _firestore.doc('config/bolao');

  /// Tabela padrão do Fantasy (sem o doc = os padrões do código).
  Stream<Either<Failure, FantasyScoringTable>> watchFantasyTable() => _fantasy.snapshots().toEither(
        (doc) {
          final table = doc.data()?['tabela'];
          return FantasyScoringTable.fromMap(table is Map ? Map<String, dynamic>.from(table) : null);
        },
        fallbackMessage: 'Não foi possível carregar a pontuação do Fantasy.',
        logName: _logName,
      );

  /// Pontos do bolão (sem o doc = 10/7/5).
  Stream<Either<Failure, PredictionRules>> watchPredictionRules() => _bolao.snapshots().toEither(
        (doc) => PredictionRules.fromMap(doc.data()),
        fallbackMessage: 'Não foi possível carregar a pontuação do bolão.',
        logName: _logName,
      );

  Future<Either<Failure, void>> saveFantasyTable(FantasyScoringTable table) async {
    try {
      await _fantasy.set({'tabela': table.toMap(), 'atualizadoEm': FieldValue.serverTimestamp()});
      return const Right(null);
    } catch (e) {
      AppLogger.e('saveFantasyTable', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível salvar a pontuação do Fantasy.'));
    }
  }

  Future<Either<Failure, void>> savePredictionRules(PredictionRules rules) async {
    try {
      await _bolao.set({...rules.toMap(), 'atualizadoEm': FieldValue.serverTimestamp()});
      return const Right(null);
    } catch (e) {
      AppLogger.e('savePredictionRules', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível salvar a pontuação do bolão.'));
    }
  }
}
