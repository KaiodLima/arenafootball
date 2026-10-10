import 'package:either_dart/either.dart';
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
  }) async {
    final updated = match.copyWith(
      homeGoals: resolveGoals(homeGoals, match.homeGoals),
      awayGoals: resolveGoals(awayGoals, match.awayGoals),
    );
    final response = await _repository.updateScore(
      matchId: match.id,
      homeGoals: updated.homeGoals,
      awayGoals: updated.awayGoals,
      season: season,
    );
    return response.map((_) => updated);
  }
}
