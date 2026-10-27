import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// Manutenção do admin ("Corrigir números dos atletas"): conta os gols e
/// assistências de cada atleta nas partidas sem competição da temporada
/// (amistosos, pela lista `gols`) e acerta os jogadores: o Geral volta a ser a
/// soma das competições e os amistosos ficam à parte. Pode rodar de novo.
/// Devolve quantos atletas mudaram.
class RepairPlayerTotalsUseCase {
  final IPlayersRepository _players;
  final IMatchesRepository _matches;

  RepairPlayerTotalsUseCase(this._players, this._matches);

  /// Gols/assistências por atleta nas partidas amistosas.
  static Map<String, ({int goals, int assists})> friendlyCounts(List<MatchDTO> matches) {
    final counts = <String, ({int goals, int assists})>{};
    void bump(String id, {int goals = 0, int assists = 0}) {
      if (id.isEmpty) return;
      final current = counts[id];
      counts[id] = (goals: (current?.goals ?? 0) + goals, assists: (current?.assists ?? 0) + assists);
    }

    for (final match in matches) {
      if (match.championshipId > 0) continue;
      for (final goal in match.goals) {
        bump(goal.scorerId, goals: 1);
        if (goal.hasAssistant) bump(goal.assistantId, assists: 1);
      }
    }
    return counts;
  }

  /// Gols/assistências por atleta e por competição nas listas de gols das
  /// partidas com competição, com o time do lado do gol (cria a inscrição que
  /// falta).
  static Map<String, Map<int, ChampionshipStatCount>> championshipCounts(List<MatchDTO> matches) {
    final counts = <String, Map<int, ChampionshipStatCount>>{};
    void bump(String id, MatchDTO match, MatchSide side, {int goals = 0, int assists = 0}) {
      if (id.isEmpty) return;
      final byChampionship = counts.putIfAbsent(id, () => {});
      final current = byChampionship[match.championshipId];
      final home = side == MatchSide.home;
      byChampionship[match.championshipId] = (
        goals: (current?.goals ?? 0) + goals,
        assists: (current?.assists ?? 0) + assists,
        teamId: current?.teamId ?? (home ? match.homeTeamId : match.awayTeamId),
        team: current?.team ?? (home ? match.homeTeam : match.awayTeam),
      );
    }

    for (final match in matches) {
      if (match.championshipId <= 0) continue;
      for (final goal in match.goals) {
        bump(goal.scorerId, match, goal.side, goals: 1);
        if (goal.hasAssistant) bump(goal.assistantId, match, goal.side, assists: 1);
      }
    }
    return counts;
  }

  Future<Either<Failure, int>> call({String? season}) async {
    final matches = await _matches.watchMatches(season: season).first;
    if (matches.isLeft) return Left(matches.left);
    return _players.repairTotals(
      friendlyCounts(matches.right),
      season: season,
      championshipCounts: championshipCounts(matches.right),
    );
  }
}
