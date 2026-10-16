import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';

abstract class IVotingRepository {
  Future<Either<Failure, void>> castVote({required MatchVoteRef ref, required VoteDTO vote});

  Future<Either<Failure, VoteDTO?>> getVote({required MatchVoteRef ref, required String voterId});

  Future<Either<Failure, List<VoteDTO>>> getVotes({required MatchVoteRef ref});

  /// Cache local dos votos da partida (só para o resultado de votação
  /// encerrada). Nunca falha: sem cache = `Right(null)`.
  Future<Either<Failure, CachedValue<List<VoteDTO>>?>> getCachedVotes({required MatchVoteRef ref});

  Future<Either<Failure, void>> saveVotesCache(List<VoteDTO> votes, {required MatchVoteRef ref});

  Future<void> deleteVotesCache({required MatchVoteRef ref});
}
