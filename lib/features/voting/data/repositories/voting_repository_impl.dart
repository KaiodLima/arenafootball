import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/datasources/voting_datasource.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';
import 'package:arena_soccer/features/voting/domain/repositories/voting_repository_interface.dart';

class VotingRepositoryImpl implements IVotingRepository {
  final VotingDataSource _dataSource;
  final CacheStore _cache;

  VotingRepositoryImpl(this._dataSource, this._cache);

  @override
  Future<Either<Failure, void>> castVote({required MatchVoteRef ref, required VoteDTO vote}) async {
    final response = await _dataSource.castVote(ref: ref, vote: vote);
    // Votou: a apuração guardada desta partida fica velha.
    if (response.isRight) await deleteVotesCache(ref: ref);
    return response;
  }

  @override
  Future<Either<Failure, VoteDTO?>> getVote({required MatchVoteRef ref, required String voterId}) =>
      _dataSource.getVote(ref: ref, voterId: voterId);

  @override
  Future<Either<Failure, List<VoteDTO>>> getVotes({required MatchVoteRef ref}) => _dataSource.getVotes(ref: ref);

  @override
  Future<Either<Failure, CachedValue<List<VoteDTO>>?>> getCachedVotes({required MatchVoteRef ref}) => _cache.read(
        _key(ref),
        (json) => [for (final item in json as List) VoteDTO.fromCache(Map<String, dynamic>.from(item as Map))],
      );

  @override
  Future<Either<Failure, void>> saveVotesCache(List<VoteDTO> votes, {required MatchVoteRef ref}) =>
      _cache.save(_key(ref), [for (final vote in votes) vote.toCache()]);

  @override
  Future<void> deleteVotesCache({required MatchVoteRef ref}) async {
    await _cache.delete(_key(ref));
  }

  String _key(MatchVoteRef ref) => CacheKeys.votes(matchId: ref.matchId, season: ref.season);
}
