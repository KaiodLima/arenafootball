import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Situação da partida.
enum MatchStatus { scheduled, live, halfTime, finished, postponed }

/// Gol de uma partida (só a página de hoje traz os autores).
class GoalEvent extends Equatable {
  /// Minuto como no site ("65", "90+2").
  final String minute;
  final String scorer;

  /// Gol a favor do mandante.
  final bool isHome;
  final bool isPenalty;

  /// Gol contra (conta para o lado em [isHome]).
  final bool isOwnGoal;

  const GoalEvent({
    required this.minute,
    required this.scorer,
    required this.isHome,
    this.isPenalty = false,
    this.isOwnGoal = false,
  });

  @override
  List<Object?> get props => [minute, scorer, isHome, isPenalty, isOwnGoal];
}

/// Uma partida já interpretada para exibição.
class GlobalMatch extends Equatable {
  final String league;

  /// Bandeira da liga (PNG); nula quando o site não trouxe.
  final Uint8List? flag;

  /// Horário de início "HH:mm" (vazio quando o site não informou).
  final String kickoff;
  final MatchStatus status;

  /// Minuto do jogo em andamento ("87"); vazio quando desconhecido.
  final String minute;
  final String homeTeam;
  final String awayTeam;
  final int? homeGoals;
  final int? awayGoals;
  final List<GoalEvent> goals;

  /// Página de análise (jogos encerrados): de lá saem os gols sob demanda.
  final String detailsUrl;

  const GlobalMatch({
    required this.league,
    required this.homeTeam,
    required this.awayTeam,
    required this.status,
    this.flag,
    this.kickoff = '',
    this.minute = '',
    this.homeGoals,
    this.awayGoals,
    this.goals = const [],
    this.detailsUrl = '',
  });

  bool get hasScore => homeGoals != null && awayGoals != null;
  bool get isLive => status == MatchStatus.live || status == MatchStatus.halfTime;
  bool get homeWon => hasScore && homeGoals! > awayGoals!;
  bool get awayWon => hasScore && awayGoals! > homeGoals!;

  /// Encerrado com gols, mas sem a lista de autores: dá para buscar na
  /// página de análise.
  bool get canLoadGoals =>
      goals.isEmpty && detailsUrl.isNotEmpty && status == MatchStatus.finished && (homeGoals ?? 0) + (awayGoals ?? 0) > 0;

  @override
  List<Object?> get props => [league, kickoff, status, minute, homeTeam, awayTeam, homeGoals, awayGoals, goals, detailsUrl];
}
