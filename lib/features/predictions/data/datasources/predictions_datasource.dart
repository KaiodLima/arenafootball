import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';

/// Bolão: palpites (`partidas{ano}/{id}/palpites/{uid}`) e o ranking por
/// região (`palpites_ranking{ano}`, gravado pelas Cloud Functions).
class PredictionsDataSource {
  final FirebaseFirestore _firestore;

  PredictionsDataSource(this._firestore);

  static const String _logName = 'PredictionsDataSource';

  CollectionReference<Map<String, dynamic>> _predictions(String matchId, String? season) =>
      _firestore.collection(SeasonCollection.name('partidas', season)).doc(matchId).collection('palpites');

  CollectionReference<Map<String, dynamic>> _ranking(String? season) =>
      _firestore.collection(SeasonCollection.name('palpites_ranking', season));

  /// Palpite da conta na partida, ao vivo (nulo = ainda não palpitou).
  Stream<Either<Failure, PredictionDTO?>> watchMine({required String matchId, required String uid, String? season}) =>
      _predictions(matchId, season).doc(uid).snapshots().toEither(
            (doc) => doc.exists ? PredictionDTO.fromFirestore(doc) : null,
            fallbackMessage: 'Não foi possível carregar o seu palpite.',
            logName: _logName,
          );

  /// Grava (ou troca) o palpite com a hora do servidor (a regra confere).
  Future<Either<Failure, void>> save({
    required String matchId,
    required String uid,
    required String name,
    required int home,
    required int away,
    String? season,
  }) async {
    try {
      await _predictions(matchId, season).doc(uid).set({
        'golsCasa': home,
        'golsFora': away,
        'nome': name.length > 80 ? name.substring(0, 80) : name,
        'atualizadoEm': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return const Right(null);
    } catch (e) {
      AppLogger.e('save matchId=$matchId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível salvar o palpite.'));
    }
  }

  /// Quantas pessoas palpitaram (agregação `count()`: uma leitura a cada mil).
  Future<Either<Failure, int>> count({required String matchId, String? season}) async {
    try {
      final result = await _predictions(matchId, season).count().get();
      return Right(result.count ?? 0);
    } catch (e) {
      AppLogger.e('count matchId=$matchId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível contar os palpites.'));
    }
  }

  /// Top [limit] da região (pelos pontos; o desempate é feito no app).
  Future<Either<Failure, List<PredictionRankingEntry>>> topOfRegion({
    required String regionId,
    String? season,
    int limit = 50,
  }) async {
    try {
      final snapshot = await _ranking(season)
          .where('idRegiao', isEqualTo: regionId)
          .orderBy('pontos', descending: true)
          .limit(limit)
          .get();
      return Right(snapshot.docs.map(PredictionRankingEntry.fromFirestore).toList());
    } catch (e) {
      AppLogger.e('topOfRegion region=$regionId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível carregar o ranking do bolão.'));
    }
  }

  /// Linha da conta no ranking da região (nula = ainda sem pontos).
  Future<Either<Failure, PredictionRankingEntry?>> mine(
      {required String regionId, required String uid, String? season}) async {
    try {
      final doc = await _ranking(season).doc('${regionId}_$uid').get();
      return Right(doc.exists ? PredictionRankingEntry.fromFirestore(doc) : null);
    } catch (e) {
      AppLogger.e('mine region=$regionId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível carregar a sua posição.'));
    }
  }

  /// Quantos estão à frente da conta (posição = isso + 1), por `count()`.
  Future<Either<Failure, int>> aheadOf({required String regionId, required int points, String? season}) async {
    try {
      final result = await _ranking(season)
          .where('idRegiao', isEqualTo: regionId)
          .where('pontos', isGreaterThan: points)
          .count()
          .get();
      return Right(result.count ?? 0);
    } catch (e) {
      AppLogger.e('aheadOf region=$regionId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível calcular a sua posição.'));
    }
  }
}
