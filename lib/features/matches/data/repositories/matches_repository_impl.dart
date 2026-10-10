import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/datasources/matches_datasource.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';

class MatchesRepositoryImpl implements IMatchesRepository {
  final MatchesDataSource _dataSource;

  MatchesRepositoryImpl(this._dataSource);

  @override
  Stream<Either<Failure, List<MatchDTO>>> watchMatches({String? season}) => _dataSource.watchMatches(season: season);

  @override
  Future<Either<Failure, void>> createMatch(MatchDTO match, {String? season}) =>
      _dataSource.createMatch(match, season: season);

  @override
  Future<Either<Failure, void>> updateScore({
    required String matchId,
    required int homeGoals,
    required int awayGoals,
    String? season,
  }) =>
      _dataSource.updateScore(matchId: matchId, homeGoals: homeGoals, awayGoals: awayGoals, season: season);

  @override
  Future<Either<Failure, void>> setVotingOpen({required String matchId, required bool isOpen, String? season}) =>
      _dataSource.setVotingOpen(matchId: matchId, isOpen: isOpen, season: season);

  @override
  Future<Either<Failure, void>> deleteMatch({required String matchId, String? season}) =>
      _dataSource.deleteMatch(matchId: matchId, season: season);
}
