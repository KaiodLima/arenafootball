import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';
import 'package:arena_soccer/features/voting/domain/repositories/voting_repository_interface.dart';

/// Todos os votos da partida (um por votante).
class GetVotesUseCase {
  final IVotingRepository _repository;

  GetVotesUseCase(this._repository);

  Future<Either<Failure, List<VoteDTO>>> call(MatchVoteRef ref) => _repository.getVotes(ref: ref);
}
