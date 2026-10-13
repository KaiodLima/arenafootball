import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';

class VotingDataSource {
  final FirebaseFirestore _firestore;

  VotingDataSource(this._firestore);

  static const String _logName = 'VotingDataSource';

  /// Votos da partida: subcoleção `votos` do doc em `partidas{ano}`.
  CollectionReference<Map<String, dynamic>> _votes(MatchVoteRef ref) => _firestore
      .collection(SeasonCollection.name('partidas', ref.season))
      .doc(ref.matchId)
      .collection('votos');

  /// Coleção antiga, nomeada pelos dois times (sem temporada). Só leitura:
  /// votos de antes da mudança e de versões antigas do app.
  CollectionReference<Map<String, dynamic>> _legacyVotes(MatchVoteRef ref) =>
      _firestore.collection('melhorjogador${ref.homeTeam}${ref.awayTeam}');

  /// Grava (ou substitui) o voto de quem votou: `set` no documento do votante.
  /// Partida sem id (não deveria acontecer) cai na coleção antiga.
  Future<Either<Failure, void>> castVote({required MatchVoteRef ref, required VoteDTO vote}) async {
    try {
      final votes = ref.matchId.isEmpty ? _legacyVotes(ref) : _votes(ref);
      await votes.doc(vote.voterId).set(vote.toMap());
      return const Right(null);
    } catch (e) {
      AppLogger.e('castVote ${ref.homeTeam} x ${ref.awayTeam}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível registrar o voto.'));
    }
  }

  /// Voto atual de [voterId] na partida (o novo vale sobre o antigo); `null`
  /// se ainda não votou.
  Future<Either<Failure, VoteDTO?>> getVote({required MatchVoteRef ref, required String voterId}) async {
    try {
      if (ref.matchId.isNotEmpty) {
        final doc = await _votes(ref).doc(voterId).get();
        if (doc.exists) return Right(VoteDTO.fromFirestore(doc));
      }
      final legacy = await _legacyVotes(ref).doc(voterId).get();
      return Right(legacy.exists ? VoteDTO.fromFirestore(legacy) : null);
    } catch (e) {
      AppLogger.e('getVote ${ref.homeTeam} x ${ref.awayTeam}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível carregar o seu voto.'));
    }
  }

  /// Todos os votos: os da partida mais os da coleção antiga de quem não
  /// votou de novo (um voto por votante; o novo vale). Ordem: antigos
  /// primeiro (desempate pelo primeiro voto, como no app antigo).
  Future<Either<Failure, List<VoteDTO>>> getVotes({required MatchVoteRef ref}) async {
    try {
      final current = ref.matchId.isEmpty
          ? const <VoteDTO>[]
          : (await _votes(ref).get()).docs.map(VoteDTO.fromFirestore).toList();
      final voters = {for (final vote in current) vote.voterId};
      final legacy = (await _legacyVotes(ref).get())
          .docs
          .map(VoteDTO.fromFirestore)
          .where((vote) => !voters.contains(vote.voterId))
          .toList();
      return Right([...legacy, ...current]);
    } catch (e) {
      AppLogger.e('getVotes ${ref.homeTeam} x ${ref.awayTeam}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível carregar os votos.'));
    }
  }
}
