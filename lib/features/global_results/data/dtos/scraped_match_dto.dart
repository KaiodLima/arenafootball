import 'package:equatable/equatable.dart';

/// Gol extraído da lista de autores ("0-1 Erling Haaland (65')").
class ScrapedGoalDTO extends Equatable {
  final int homeScore;
  final int awayScore;
  final String scorer;
  final String minute;

  const ScrapedGoalDTO({required this.homeScore, required this.awayScore, required this.scorer, required this.minute});

  @override
  List<Object?> get props => [homeScore, awayScore, scorer, minute];
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
  });

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
      ];
}
