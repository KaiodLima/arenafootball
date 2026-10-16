import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';
import 'package:arena_soccer/features/voting/domain/repositories/voting_repository_interface.dart';

/// Votos da partida no cache local (nunca falha: sem cache = `Right(null)`).
class GetCachedVotesUseCase {
  final IVotingRepository _repository;

  GetCachedVotesUseCase(this._repository);

  Future<Either<Failure, CachedValue<List<VoteDTO>>?>> call(MatchVoteRef ref) => _repository.getCachedVotes(ref: ref);
}
