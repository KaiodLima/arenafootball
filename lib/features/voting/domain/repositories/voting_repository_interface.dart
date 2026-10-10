import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';

abstract class IVotingRepository {
  Future<Either<Failure, void>> castVote({required String homeTeam, required String awayTeam, required VoteDTO vote});

  Future<Either<Failure, List<VoteDTO>>> getVotes({required String homeTeam, required String awayTeam});
}
