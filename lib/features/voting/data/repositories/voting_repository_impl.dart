import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/voting/data/datasources/voting_datasource.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/domain/repositories/voting_repository_interface.dart';

class VotingRepositoryImpl implements IVotingRepository {
  final VotingDataSource _dataSource;

  VotingRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, void>> castVote({required String homeTeam, required String awayTeam, required VoteDTO vote}) =>
      _dataSource.castVote(homeTeam: homeTeam, awayTeam: awayTeam, vote: vote);

  @override
  Future<Either<Failure, List<VoteDTO>>> getVotes({required String homeTeam, required String awayTeam}) =>
      _dataSource.getVotes(homeTeam: homeTeam, awayTeam: awayTeam);
}
