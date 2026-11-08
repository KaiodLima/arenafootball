import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/match_clock.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Time na arte: nome, escudo e cores (cópias dos dados oficiais).
class ArtTeam extends Equatable {
  final String name;
  final String crestUrl;
  final String primaryColor;
  final String secondaryColor;

  const ArtTeam({required this.name, this.crestUrl = '', this.primaryColor = '', this.secondaryColor = ''});

  /// Iniciais para o escudo substituto ("LJ" de "Lava Jato").
  String get initials {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    // Ignora "de", "da", "FC"... quando há palavras maiores.
    final main = words.where((w) => w.length > 2).toList();
    return (main.isNotEmpty ? main : words).take(2).map((w) => w[0].toUpperCase()).join();
  }

  @override
  List<Object?> get props => [name, crestUrl, primaryColor, secondaryColor];
}

/// Situação da partida na arte.
enum ArtMatchStatus { finished, live, halfTime, notStarted }

/// Vencedor (nulo = empate ou partida não iniciada).
enum ArtSide { home, away }

/// Gol na arte: lado, autor (vazio = sem autor) e minuto.
class ArtGoal extends Equatable {
  final ArtSide side;
  final String scorer;
  final int? minute;

  const ArtGoal({required this.side, required this.scorer, this.minute});

  @override
  List<Object?> get props => [side, scorer, minute];
}

/// O que falta cadastrar e a arte mostra sem (aviso da prévia).
enum ArtMissing { homeCrest, awayCrest, venue, date }

/// Dados do card de resultado, só com informação oficial da partida: times
/// (pelo `idTime`), placar pela lista de gols, vencedor, competição, data,
/// horário, local, situação e gols em ordem de minuto. O placar do 1º tempo
/// só existe quando todos os gols têm minuto.
class ResultArtData extends Equatable {
  final ArtTeam home;
  final ArtTeam away;
  final int homeGoals;
  final int awayGoals;

  /// Nome da competição; vazio = amistoso.
  final String championship;

  /// Logo do campeonato (`campeonatos.urlImagem`); vazio = sem logo/amistoso.
  final String championshipLogoUrl;
  final String date;
  final String time;
  final String venue;
  final ArtMatchStatus status;
  final List<ArtGoal> goals;

  /// Placar no intervalo (nulo sem os minutos de todos os gols).
  final (int, int)? halfTimeScore;

  /// Link do QR (página pública do resultado ou do app).
  final String link;
  final List<ArtMissing> missing;

  const ResultArtData({
    required this.home,
    required this.away,
    required this.homeGoals,
    required this.awayGoals,
    this.championship = '',
    this.championshipLogoUrl = '',
    this.date = '',
    this.time = '',
    this.venue = '',
    this.status = ArtMatchStatus.finished,
    this.goals = const [],
    this.halfTimeScore,
    this.link = '',
    this.missing = const [],
  });

  ArtSide? get winner {
    if (status == ArtMatchStatus.notStarted || homeGoals == awayGoals) return null;
    return homeGoals > awayGoals ? ArtSide.home : ArtSide.away;
  }

  List<ArtGoal> goalsOf(ArtSide side) => goals.where((g) => g.side == side).toList();

  static ArtMatchStatus statusOf(MatchDTO match, DateTime now) {
    if (match.manualStatus == MatchManualStatus.finished) return ArtMatchStatus.finished;
    if (match.manualStatus == MatchManualStatus.halfTime) return ArtMatchStatus.halfTime;
    if (match.manualStatus == MatchManualStatus.live) return ArtMatchStatus.live;
    final end = MatchClock.expectedEnd(match, now);
    if (end != null && now.isAfter(end)) return ArtMatchStatus.finished;
    final kickoff = MatchClock.kickoffOf(match, now);
    if (kickoff == null || now.isBefore(kickoff) || match.manualStatus == MatchManualStatus.waiting) {
      return kickoff == null && match.goals.isNotEmpty ? ArtMatchStatus.finished : ArtMatchStatus.notStarted;
    }
    return ArtMatchStatus.live;
  }

  factory ResultArtData.of(
    MatchDTO match, {
    TeamDTO? homeTeam,
    TeamDTO? awayTeam,
    String championship = '',
    String championshipLogoUrl = '',
    String link = '',
    DateTime? now,
  }) {
    ArtTeam team(String name, TeamDTO? dto) => ArtTeam(
          name: name,
          crestUrl: dto?.imageUrl ?? '',
          primaryColor: dto?.primaryColor ?? '',
          secondaryColor: dto?.secondaryColor ?? '',
        );
    final hasList = match.goals.isNotEmpty;
    final goals = [
      for (final g in [...match.goals]..sort((a, b) => (a.minute ?? 999).compareTo(b.minute ?? 999)))
        ArtGoal(
          side: g.side == MatchSide.home ? ArtSide.home : ArtSide.away,
          scorer: g.hasScorer ? g.scorerName : '',
          minute: g.minute,
        ),
    ];
    final half = (match.durationMinutes / 2).round();
    final allMinutes = goals.isNotEmpty && goals.every((g) => g.minute != null);
    final home = team(match.homeTeam, homeTeam);
    final away = team(match.awayTeam, awayTeam);
    return ResultArtData(
      home: home,
      away: away,
      homeGoals: hasList ? goals.where((g) => g.side == ArtSide.home).length : match.homeGoals,
      awayGoals: hasList ? goals.where((g) => g.side == ArtSide.away).length : match.awayGoals,
      championship: match.championshipId > 0 ? championship : '',
      championshipLogoUrl: match.championshipId > 0 ? championshipLogoUrl.trim() : '',
      date: match.date.trim(),
      time: match.time.trim(),
      venue: match.venue.trim(),
      status: statusOf(match, now ?? DateTime.now()),
      goals: goals,
      halfTimeScore: allMinutes
          ? (
              goals.where((g) => g.side == ArtSide.home && g.minute! <= half).length,
              goals.where((g) => g.side == ArtSide.away && g.minute! <= half).length,
            )
          : null,
      link: link,
      missing: [
        if (home.crestUrl.isEmpty) ArtMissing.homeCrest,
        if (away.crestUrl.isEmpty) ArtMissing.awayCrest,
        if (match.venue.trim().isEmpty) ArtMissing.venue,
        if (match.date.trim().isEmpty) ArtMissing.date,
      ],
    );
  }

  @override
  List<Object?> get props => [
        home,
        away,
        homeGoals,
        awayGoals,
        championship,
        championshipLogoUrl,
        date,
        time,
        venue,
        status,
        goals,
        halfTimeScore,
        link,
        missing
      ];
}
