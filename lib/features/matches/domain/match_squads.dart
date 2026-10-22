import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

/// Elenco de um lado da partida, por nome: na competição da partida, só quem
/// joga por esse time nela; em amistoso (sem competição), o elenco geral.
List<PlayerDTO> matchSquad(List<PlayerDTO> players, MatchDTO match, MatchSide side) {
  final teamId = side == MatchSide.home ? match.homeTeamId : match.awayTeamId;
  final teamName = side == MatchSide.home ? match.homeTeam : match.awayTeam;
  final filtered = match.championshipId > 0
      ? players.where((p) => p.playsIn(match.championshipId, teamId: teamId, teamName: teamName)).toList()
      : [...players];
  return filtered..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}

/// Atleta do elenco com os números dele nesta partida.
class MatchPlayerLine {
  final PlayerDTO player;
  final int goals;
  final int assists;

  const MatchPlayerLine({required this.player, this.goals = 0, this.assists = 0});

  bool get involved => goals > 0 || assists > 0;

  /// Elenco com gols/assistências da partida: primeiro quem participou de gol
  /// (mais gols, depois mais passes), depois por posição (goleiro → atacante;
  /// sem posição no fim) e por nome.
  static List<MatchPlayerLine> of(List<MatchGoal> goals, List<PlayerDTO> squad) {
    final scored = <String, int>{};
    final assisted = <String, int>{};
    for (final goal in goals) {
      if (goal.hasScorer) scored[goal.scorerId] = (scored[goal.scorerId] ?? 0) + 1;
      if (goal.hasAssistant) assisted[goal.assistantId] = (assisted[goal.assistantId] ?? 0) + 1;
    }
    int positionRank(PlayerDTO p) {
      final position = PlayerPosition.fromKey(p.position);
      return position == null ? PlayerPosition.values.length : position.index;
    }

    final lines = [
      for (final p in squad) MatchPlayerLine(player: p, goals: scored[p.id] ?? 0, assists: assisted[p.id] ?? 0),
    ];
    lines.sort((a, b) {
      if (a.involved != b.involved) return a.involved ? -1 : 1;
      if (a.goals != b.goals) return b.goals - a.goals;
      if (a.assists != b.assists) return b.assists - a.assists;
      final byPosition = positionRank(a.player) - positionRank(b.player);
      if (byPosition != 0) return byPosition;
      return a.player.name.toLowerCase().compareTo(b.player.name.toLowerCase());
    });
    return lines;
  }
}
