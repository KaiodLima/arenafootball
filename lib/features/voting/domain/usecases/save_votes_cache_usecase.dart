import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';
import 'package:arena_soccer/features/voting/domain/repositories/voting_repository_interface.dart';

class SaveVotesCacheUseCase {
  final IVotingRepository _repository;

  SaveVotesCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(MatchVoteRef ref, List<VoteDTO> votes) =>
      _repository.saveVotesCache(votes, ref: ref);
}
