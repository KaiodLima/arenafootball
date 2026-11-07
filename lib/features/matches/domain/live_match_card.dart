import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_report_dtos.dart';
import 'package:arena_soccer/features/matches/domain/match_report.dart';
import 'package:arena_soccer/features/news/data/dtos/live_event.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Card "ao vivo" da partida no feed (um por partida): montado da partida
/// inteira (gols, cartões, substituições), então nunca diverge da súmula.
class LiveMatchCard {
  const LiveMatchCard._();

  /// O lance da súmula no formato do card.
  static LiveEvent eventOf(ReportEvent event) {
    final home = event.side == MatchSide.home;
    final goal = event.goal;
    if (goal != null) {
      return LiveEvent(
        id: goal.id,
        type: LiveEventType.goal,
        home: home,
        minute: goal.minute,
        player: goal.hasScorer ? goal.scorerName : '',
        playerId: goal.hasScorer ? goal.scorerId : '',
        assistant: goal.hasAssistant ? goal.assistantName : '',
      );
    }
    final sub = event.substitution;
    if (sub != null) {
      return LiveEvent(
        id: sub.id,
        type: LiveEventType.substitution,
        home: home,
        minute: sub.minute,
        playerIn: sub.inName,
        playerInId: sub.inId,
        playerOut: sub.outName,
      );
    }
    final booking = event.booking!;
    return LiveEvent(
      id: booking.id,
      type: booking.type == BookingType.red ? LiveEventType.red : LiveEventType.yellow,
      home: home,
      minute: booking.minute,
      player: booking.playerName,
      playerId: booking.playerId,
      secondYellow: booking.secondYellow,
    );
  }

  /// Todos os lances da partida, na ordem da linha do tempo.
  static List<LiveEvent> eventsOf(MatchDTO match) => [
        for (final event in MatchReport.timeline(match.goals, match.bookings, match.substitutions)) eventOf(event),
      ];

  /// Ids dos lances de [after] que não estavam em [before].
  static Set<String> _newIds(MatchDTO? before, MatchDTO after) {
    final old = before == null
        ? <String>{}
        : {
            for (final g in before.goals) g.id,
            for (final b in before.bookings) b.id,
            for (final s in before.substitutions) s.id,
          };
    return {
      for (final g in after.goals) g.id,
      for (final b in after.bookings) b.id,
      for (final s in after.substitutions) s.id,
    }.difference(old);
  }

  /// O lance novo mais recente (na ordem da linha do tempo) entre [before] e
  /// [after]; nulo = nenhum lance novo (só apagou/editou: o card não sobe).
  static LiveEvent? newestEvent(MatchDTO? before, MatchDTO after) {
    final added = _newIds(before, after);
    if (added.isEmpty) return null;
    return eventsOf(after).lastWhere((e) => added.contains(e.id), orElse: () => eventsOf(after).last);
  }

  /// Vermelhos novos (o card oculto deles dispara o push "Expulso!").
  static List<MatchBooking> newReds(MatchDTO? before, MatchDTO after) {
    final added = _newIds(before, after);
    return [
      for (final b in after.bookings)
        if (b.type == BookingType.red && added.contains(b.id)) b,
    ];
  }

  /// Placar pela lista de gols (com lista) ou o gravado.
  static (int, int) scoreOf(MatchDTO match) => match.goals.isEmpty
      ? (match.homeGoals, match.awayGoals)
      : (
          match.goals.where((g) => g.side == MatchSide.home).length,
          match.goals.where((g) => g.side == MatchSide.away).length,
        );

  /// Texto do lance (título/descrição para o app antigo e o card oculto).
  static String eventText(LiveEvent event) {
    final minute = event.minute == null ? '' : "${event.minute}' ";
    return switch (event.type) {
      LiveEventType.goal => '⚽ $minute${event.player.isEmpty ? 'Gol' : event.player}',
      LiveEventType.yellow => '🟨 $minute${event.player}',
      LiveEventType.red => '🟥 $minute${event.player}',
      LiveEventType.substitution => '🔁 $minute${event.playerIn} ↔ ${event.playerOut}',
    };
  }

  /// O card ao vivo da partida. [last] = o lance em destaque (o novo; sem
  /// lance novo, o último da linha do tempo).
  static NewsDTO build(
    MatchDTO match,
    Map<String, TeamDTO> teams, {
    String season = '',
    LiveEvent? last,
  }) {
    final events = eventsOf(match);
    final highlight = last ?? (events.isEmpty ? null : events.last);
    final (home, away) = scoreOf(match);
    final homeTeam = teams[match.homeTeamId];
    final awayTeam = teams[match.awayTeamId];
    return NewsDTO(
      id: NewsDTO.liveIdOf(match.id),
      tag: NewsDTO.liveTag,
      isVisible: true,
      // Lido pelo app antigo (que não conhece a tag) como notícia comum.
      title: '${match.homeTeam} $home × $away ${match.awayTeam} · ao vivo',
      description: highlight == null ? '' : eventText(highlight),
      region: match.region,
      homeTeam: match.homeTeam,
      awayTeam: match.awayTeam,
      homeGoals: '$home',
      awayGoals: '$away',
      homeTeamId: match.homeTeamId,
      awayTeamId: match.awayTeamId,
      homeCrest: homeTeam?.imageUrl ?? '',
      awayCrest: awayTeam?.imageUrl ?? '',
      homeColor: homeTeam?.primaryColor ?? '',
      awayColor: awayTeam?.primaryColor ?? '',
      season: season,
      matchId: match.id,
      championshipId: match.championshipId > 0 ? match.championshipId : null,
      regionIds: match.regionIds,
      lastEvent: highlight,
      liveEvents: events,
    );
  }

  /// Card oculto do vermelho [booking] (só dispara o push "Expulso!").
  static NewsDTO redCard(MatchDTO match, MatchBooking booking, Map<String, TeamDTO> teams, {String season = ''}) {
    final home = booking.side == MatchSide.home;
    final (homeGoals, awayGoals) = scoreOf(match);
    final teamName = home ? match.homeTeam : match.awayTeam;
    final teamId = home ? match.homeTeamId : match.awayTeamId;
    final minute = booking.minute == null ? '' : " · ${booking.minute}'";
    return NewsDTO(
      tag: NewsDTO.bookingTag,
      isVisible: false,
      title: '🟥 Expulso: ${booking.playerName}',
      description: '${booking.playerName} ($teamName)$minute',
      region: match.region,
      homeTeam: match.homeTeam,
      awayTeam: match.awayTeam,
      homeGoals: '$homeGoals',
      awayGoals: '$awayGoals',
      homeTeamId: match.homeTeamId,
      awayTeamId: match.awayTeamId,
      scoringTeam: teamName,
      scoringTeamId: teamId,
      scoringTeamCrest: teams[teamId]?.imageUrl ?? '',
      season: season,
      matchId: match.id,
      championshipId: match.championshipId > 0 ? match.championshipId : null,
      regionIds: match.regionIds,
    );
  }
}
