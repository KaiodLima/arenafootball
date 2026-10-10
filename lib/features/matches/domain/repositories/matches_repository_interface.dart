import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';

abstract class IMatchesRepository {
  Stream<Either<Failure, List<MatchDTO>>> watchMatches({String? season});

  Future<Either<Failure, void>> createMatch(MatchDTO match, {String? season});

  Future<Either<Failure, void>> updateScore({
    required String matchId,
    required int homeGoals,
    required int awayGoals,
    String? season,
  });

  Future<Either<Failure, void>> setVotingOpen({required String matchId, required bool isOpen, String? season});

  Future<Either<Failure, void>> deleteMatch({required String matchId, String? season});
}
