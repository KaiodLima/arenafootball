import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/datasources/voting_datasource.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';
import 'package:arena_soccer/features/voting/domain/repositories/voting_repository_interface.dart';

class VotingRepositoryImpl implements IVotingRepository {
  final VotingDataSource _dataSource;

  VotingRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, void>> castVote({required MatchVoteRef ref, required VoteDTO vote}) =>
      _dataSource.castVote(ref: ref, vote: vote);

  @override
  Future<Either<Failure, VoteDTO?>> getVote({required MatchVoteRef ref, required String voterId}) =>
      _dataSource.getVote(ref: ref, voterId: voterId);

  @override
  Future<Either<Failure, List<VoteDTO>>> getVotes({required MatchVoteRef ref}) => _dataSource.getVotes(ref: ref);
}
