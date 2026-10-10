import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';

class VotingDataSource {
  final FirebaseFirestore _firestore;

  VotingDataSource(this._firestore);

  static const String _logName = 'VotingDataSource';

  /// Uma coleção por partida, nomeada pelos dois times (sem temporada), como
  /// no app antigo.
  CollectionReference<Map<String, dynamic>> _votes(String homeTeam, String awayTeam) =>
      _firestore.collection('melhorjogador$homeTeam$awayTeam');

  /// Grava (ou substitui) o voto de quem votou: `set` no documento do votante.
  Future<Either<Failure, void>> castVote({
    required String homeTeam,
    required String awayTeam,
    required VoteDTO vote,
  }) async {
    try {
      await _votes(homeTeam, awayTeam).doc(vote.voterId).set(vote.toMap());
      return const Right(null);
    } catch (e) {
      AppLogger.e('castVote $homeTeam x $awayTeam', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível registrar o voto.'));
    }
  }

  Future<Either<Failure, List<VoteDTO>>> getVotes({required String homeTeam, required String awayTeam}) async {
    try {
      final result = await _votes(homeTeam, awayTeam).get();
      return Right(result.docs.map(VoteDTO.fromFirestore).toList());
    } catch (e) {
      AppLogger.e('getVotes $homeTeam x $awayTeam', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível carregar os votos.'));
    }
  }
}
