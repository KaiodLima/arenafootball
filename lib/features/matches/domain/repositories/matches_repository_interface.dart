import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';

abstract class IMatchesRepository {
  /// Com [region], só as partidas daquela região (filtradas no servidor).
  Stream<Either<Failure, List<MatchDTO>>> watchMatches({String? season, String? region});

  Future<Either<Failure, void>> createMatch(MatchDTO match, {String? season});

  Future<Either<Failure, void>> updateScore({
    required String matchId,
    required int homeGoals,
    required int awayGoals,
    String? season,
  });

  /// Grava a lista de gols e o placar contado dela.
  Future<Either<Failure, void>> updateGoals({required String matchId, required List<MatchGoal> goals, String? season});

  /// Acrescenta um gol (card de gol) com o placar dado.
  Future<Either<Failure, void>> appendGoal({
    required String matchId,
    required MatchGoal goal,
    required int homeGoals,
    required int awayGoals,
    String? season,
  });

  Future<Either<Failure, void>> setVotingOpen({required String matchId, required bool isOpen, String? season});

  Future<Either<Failure, void>> deleteMatch({required String matchId, String? season});
}
