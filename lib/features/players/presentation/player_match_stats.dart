import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

/// Gols e assistências do atleta numa partida (gráfico "Últimas partidas").
class PlayerMatchStat extends Equatable {
  final MatchDTO match;
  final int goals;
  final int assists;

  /// Adversário (o outro time da partida).
  final String opponent;

  const PlayerMatchStat({required this.match, required this.goals, required this.assists, required this.opponent});

  @override
  List<Object?> get props => [match, goals, assists, opponent];
}

class PlayerMatchStats {
  const PlayerMatchStats._();

  /// As últimas [limit] partidas já jogadas dos times do atleta (o principal e
  /// os das inscrições), da mais antiga para a mais nova, com os gols e as
  /// assistências dele nas listas de gols (zero quando não marcou). Partida
  /// antiga, sem lista de gols, só entra se o placar for 0 × 0.
  static List<PlayerMatchStat> lastMatches(
    List<MatchDTO> matches,
    PlayerDTO player, {
    required DateTime now,
    int limit = 10,
  }) {
    final teams = <({String id, String name})>[
      (id: player.teamId, name: player.team),
      for (final e in player.enrollments) (id: e.teamId, name: e.team),
    ].where((t) => t.id.isNotEmpty || t.name.trim().isNotEmpty).toList();

    MatchSide? sideOf(MatchDTO match) {
      for (final goal in match.goals) {
        if (goal.scorerId == player.id || goal.assistantId == player.id) return goal.side;
      }
      for (final t in teams) {
        if (sameTeam(idA: match.homeTeamId, nameA: match.homeTeam, idB: t.id, nameB: t.name)) return MatchSide.home;
        if (sameTeam(idA: match.awayTeamId, nameA: match.awayTeam, idB: t.id, nameB: t.name)) return MatchSide.away;
      }
      return null;
    }

    final stats = <({PlayerMatchStat stat, DateTime? date})>[];
    for (final match in matches) {
      final side = sideOf(match);
      if (side == null || !MatchCardStatus.of(match, now).finished) continue;
      // Sem a lista de gols não dá para saber quem marcou (só o 0 × 0 é certo).
      if (match.goals.isEmpty && (match.homeGoals > 0 || match.awayGoals > 0)) continue;
      stats.add((
        stat: PlayerMatchStat(
          match: match,
          goals: match.goals.where((g) => g.scorerId == player.id).length,
          assists: match.goals.where((g) => g.hasAssistant && g.assistantId == player.id).length,
          opponent: side == MatchSide.home ? match.awayTeam : match.homeTeam,
        ),
        date: dateOf(match, now),
      ));
    }
    stats.sort((a, b) {
      final byDate = (a.date ?? DateTime(0)).compareTo(b.date ?? DateTime(0));
      if (byDate != 0) return byDate;
      return (a.stat.match.registeredAt ?? DateTime(0)).compareTo(b.stat.match.registeredAt ?? DateTime(0));
    });
    final list = stats.map((s) => s.stat).toList();
    return list.length <= limit ? list : list.sublist(list.length - limit);
  }

  /// Data "dd/MM" ou "dd/MM/aaaa" da partida; sem ano, a do ano de [now] (ou o
  /// anterior, se cairia no futuro).
  static DateTime? dateOf(MatchDTO match, DateTime now) {
    final parts = match.date.split('/');
    final day = int.tryParse(parts.first.trim());
    final month = parts.length > 1 ? int.tryParse(parts[1].trim()) : null;
    if (day == null || month == null) return null;
    final year = parts.length > 2 ? int.tryParse(parts[2].trim()) : null;
    var date = DateTime(year ?? now.year, month, day);
    if (year == null && date.isAfter(now)) date = DateTime(now.year - 1, month, day);
    return date;
  }
}
