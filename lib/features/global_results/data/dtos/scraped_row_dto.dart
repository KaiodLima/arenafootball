import 'package:equatable/equatable.dart';

/// Linha crua extraída do HTML do soccerstats.com. Na página de ontem cada
/// time vem numa linha separada (casa + gols); o UseCase junta os pares.
class ScrapedRowDTO extends Equatable {
  final String time;
  final String home;
  final String away;
  final String score;
  final String scorers;
  final String league;

  const ScrapedRowDTO({
    this.time = '',
    this.home = '',
    this.away = '',
    this.score = '',
    this.scorers = '',
    this.league = '',
  });

  @override
  List<Object?> get props => [time, home, away, score, scorers, league];
}
