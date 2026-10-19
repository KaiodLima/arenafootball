import 'package:either_dart/either.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';

/// Altera o placar de uma partida (admin). Campo vazio (ou inválido) mantém
/// o placar atual daquele time, como no app antigo. Grava só os gols.
class UpdateMatchScoreUseCase {
  final IMatchesRepository _repository;

  UpdateMatchScoreUseCase(this._repository);

  static int resolveGoals(String input, int current) {
    final parsed = int.tryParse(input.trim());
    return parsed == null || parsed < 0 ? current : parsed;
  }

  Future<Either<Failure, MatchDTO>> call({
    required MatchDTO match,
    required String homeGoals,
    required String awayGoals,
    String? season,
    MatchGoal? goal,
  }) async {
    final updated = match.copyWith(
      homeGoals: resolveGoals(homeGoals, match.homeGoals),
      awayGoals: resolveGoals(awayGoals, match.awayGoals),
    );
    // Um gol a mais (card de gol): entra também na lista de gols da partida.
    final oneMore = updated.homeGoals + updated.awayGoals == match.homeGoals + match.awayGoals + 1;
    if (goal != null && oneMore) {
      final appended = await _repository.appendGoal(
        matchId: match.id,
        goal: goal,
        homeGoals: updated.homeGoals,
        awayGoals: updated.awayGoals,
        season: season,
      );
      return appended.map((_) => updated.copyWith(goals: [...match.goals, goal]));
    }
    final response = await _repository.updateScore(
      matchId: match.id,
      homeGoals: updated.homeGoals,
      awayGoals: updated.awayGoals,
      season: season,
    );
    return response.map((_) => updated);
  }
}
