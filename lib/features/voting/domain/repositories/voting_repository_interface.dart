import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';

abstract class IVotingRepository {
  Future<Either<Failure, void>> castVote({required MatchVoteRef ref, required VoteDTO vote});

  Future<Either<Failure, VoteDTO?>> getVote({required MatchVoteRef ref, required String voterId});

  Future<Either<Failure, List<VoteDTO>>> getVotes({required MatchVoteRef ref});
}
