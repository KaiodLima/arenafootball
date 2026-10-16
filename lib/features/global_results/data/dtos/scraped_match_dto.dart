import 'package:equatable/equatable.dart';

/// Gol extraído do site: da lista de autores do destaque ("0-1 Erling
/// Haaland (65')") ou da cronologia da página de análise do jogo.
class ScrapedGoalDTO extends Equatable {
  final int homeScore;
  final int awayScore;
  final String scorer;
  final String minute;

  /// Lado do gol quando o site informa (página de análise); nulo no destaque,
  /// onde sai da mudança do placar.
  final bool? isHome;
  final bool isOwnGoal;
  final bool isPenalty;

  const ScrapedGoalDTO({
    required this.homeScore,
    required this.awayScore,
    required this.scorer,
    required this.minute,
    this.isHome,
    this.isOwnGoal = false,
    this.isPenalty = false,
  });

  /// Cache local (ver `CacheStore`).
  factory ScrapedGoalDTO.fromCache(Map<String, dynamic> json) => ScrapedGoalDTO(
        homeScore: (json['homeScore'] as num?)?.toInt() ?? 0,
        awayScore: (json['awayScore'] as num?)?.toInt() ?? 0,
        scorer: json['scorer']?.toString() ?? '',
        minute: json['minute']?.toString() ?? '',
        isHome: json['isHome'] as bool?,
        isOwnGoal: json['isOwnGoal'] == true,
        isPenalty: json['isPenalty'] == true,
      );

  Map<String, dynamic> toCache() => {
        'homeScore': homeScore,
        'awayScore': awayScore,
        'scorer': scorer,
        'minute': minute,
        'isHome': isHome,
        'isOwnGoal': isOwnGoal,
        'isPenalty': isPenalty,
      };

  @override
  List<Object?> get props => [homeScore, awayScore, scorer, minute, isHome, isOwnGoal, isPenalty];
}

/// Partida extraída do HTML do soccerstats.com, ainda com o status em texto
/// (o UseCase interpreta). Campos vazios/nulos = o site não informou.
class ScrapedMatchDTO extends Equatable {
  final String league;

  /// Bandeira da liga em base64 (PNG), sem o prefixo `data:`.
  final String flagBase64;

  /// Horário de início "HH:mm" (no fuso enviado no cookie `tz`).
  final String kickoff;

  /// Texto do status na seção de destaque: "87'", "HT", "FT", "'"...
  final String statusText;

  /// Status em vermelho no site (jogo em andamento).
  final bool isLive;

  /// Veio da seção de destaque da página de hoje (tem status e gols).
  final bool featured;
  final String homeTeam;
  final String awayTeam;
  final int? homeGoals;
  final int? awayGoals;
  final bool postponed;
  final List<ScrapedGoalDTO> goals;

  /// Página de análise do jogo encerrado (tem a cronologia dos gols).
  final String detailsUrl;

  const ScrapedMatchDTO({
    required this.homeTeam,
    required this.awayTeam,
    this.league = '',
    this.flagBase64 = '',
    this.kickoff = '',
    this.statusText = '',
    this.isLive = false,
    this.featured = false,
    this.homeGoals,
    this.awayGoals,
    this.postponed = false,
    this.goals = const [],
    this.detailsUrl = '',
  });

  /// Cache local (ver `CacheStore`).
  factory ScrapedMatchDTO.fromCache(Map<String, dynamic> json) => ScrapedMatchDTO(
        league: json['league']?.toString() ?? '',
        flagBase64: json['flagBase64']?.toString() ?? '',
        kickoff: json['kickoff']?.toString() ?? '',
        statusText: json['statusText']?.toString() ?? '',
        isLive: json['isLive'] == true,
        featured: json['featured'] == true,
        homeTeam: json['homeTeam']?.toString() ?? '',
        awayTeam: json['awayTeam']?.toString() ?? '',
        homeGoals: (json['homeGoals'] as num?)?.toInt(),
        awayGoals: (json['awayGoals'] as num?)?.toInt(),
        postponed: json['postponed'] == true,
        goals: [
          for (final item in (json['goals'] as List?) ?? const [])
            ScrapedGoalDTO.fromCache(Map<String, dynamic>.from(item as Map)),
        ],
        detailsUrl: json['detailsUrl']?.toString() ?? '',
      );

  Map<String, dynamic> toCache() => {
        'league': league,
        'flagBase64': flagBase64,
        'kickoff': kickoff,
        'statusText': statusText,
        'isLive': isLive,
        'featured': featured,
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'homeGoals': homeGoals,
        'awayGoals': awayGoals,
        'postponed': postponed,
        'goals': [for (final goal in goals) goal.toCache()],
        'detailsUrl': detailsUrl,
      };

  @override
  List<Object?> get props => [
        league,
        flagBase64,
        kickoff,
        statusText,
        isLive,
        featured,
        homeTeam,
        awayTeam,
        homeGoals,
        awayGoals,
        postponed,
        goals,
        detailsUrl,
      ];
}
