import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/fan_ranking/data/dtos/fan_ranking_dto.dart';

/// `ranking_torcidas/{temporada}`: um doc por temporada, gravado pela function.
class FanRankingDataSource {
  final FirebaseFirestore _firestore;

  FanRankingDataSource(this._firestore);

  static const String _logName = 'FanRankingDataSource';

  /// Ranking da [season]; sem o doc ainda, um ranking vazio.
  Future<Either<Failure, FanRankingDTO>> getRanking(String season) async {
    try {
      final doc = await _firestore.collection('ranking_torcidas').doc(season).get();
      return Right(doc.exists ? FanRankingDTO.fromFirestore(doc) : FanRankingDTO(season: season));
    } catch (e) {
      AppLogger.e('getRanking season=$season', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível carregar o ranking de torcidas.'));
    }
  }
}
