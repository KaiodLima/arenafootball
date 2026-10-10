import 'package:equatable/equatable.dart';

/// Uma partida já montada para exibição.
class GlobalMatch extends Equatable {
  final String league;
  final String time;
  final String homeTeam;
  final String awayTeam;
  final String score;

  /// Autores dos gols (só vem na página de hoje).
  final String scorers;

  const GlobalMatch({
    required this.league,
    required this.time,
    required this.homeTeam,
    required this.awayTeam,
    required this.score,
    this.scorers = '',
  });

  @override
  List<Object?> get props => [league, time, homeTeam, awayTeam, score, scorers];
}
