import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// "Editar placar": grava a lista de gols da partida (o placar sai dela) e
/// acerta os números dos atletas pela diferença com a lista anterior — +1/−1
/// gol no autor e assistência no garçom, no Geral e na competição da partida
/// (amistoso: só na contagem de amistosos).
class UpdateMatchGoalsUseCase {
  final IMatchesRepository _matches;
  final IPlayersRepository _players;

  UpdateMatchGoalsUseCase(this._matches, this._players);

  Future<Either<Failure, MatchDTO>> call({
    required MatchDTO match,
    required List<MatchGoal> before,
    required List<MatchGoal> after,
    String? season,
  }) async {
    final saved = await _matches.updateGoals(matchId: match.id, goals: after, season: season);
    if (saved.isLeft) return Left(saved.left);

    final delta = MatchGoal.statsDelta(before, after);
    for (final entry in delta.entries) {
      final home = entry.value.side == MatchSide.home;
      final enrollment = match.championshipId > 0
          ? PlayerEnrollment(
              championshipId: match.championshipId,
              teamId: home ? match.homeTeamId : match.awayTeamId,
              team: home ? match.homeTeam : match.awayTeam,
            )
          : null;
      final response = await _players.incrementStats(
        playerId: entry.key,
        goals: entry.value.goals,
        assists: entry.value.assists,
        enrollment: enrollment,
        // Amistoso (sem competição): contagem à parte, fora do Geral.
        friendly: match.championshipId <= 0,
        season: season,
      );
      if (response.isLeft) return Left(response.left);
    }
    return Right(match.copyWith(
      goals: after,
      homeGoals: after.where((g) => g.side == MatchSide.home).length,
      awayGoals: after.where((g) => g.side == MatchSide.away).length,
    ));
  }
}
