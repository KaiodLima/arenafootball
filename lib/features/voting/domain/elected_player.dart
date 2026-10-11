import 'package:equatable/equatable.dart';

/// Resultado da votação de melhor jogador de uma partida.
class ElectedPlayer extends Equatable {
  final String playerName;

  /// Time do jogador (vem dos votos).
  final String team;
  final int votes;

  /// Foto do jogador e escudo do time; vazios quando não encontrados.
  final String playerImageUrl;
  final String teamImageUrl;

  /// Gols e assistências na temporada; 0 quando o jogador não foi achado no
  /// elenco.
  final int goals;
  final int assists;

  const ElectedPlayer({
    required this.playerName,
    required this.team,
    required this.votes,
    this.playerImageUrl = '',
    this.teamImageUrl = '',
    this.goals = 0,
    this.assists = 0,
  });

  ElectedPlayer copyWith({String? playerImageUrl, String? teamImageUrl, int? goals, int? assists}) {
    return ElectedPlayer(
      playerName: playerName,
      team: team,
      votes: votes,
      playerImageUrl: playerImageUrl ?? this.playerImageUrl,
      teamImageUrl: teamImageUrl ?? this.teamImageUrl,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
    );
  }

  @override
  List<Object?> get props => [playerName, team, votes, playerImageUrl, teamImageUrl, goals, assists];
}

/// Votos de um jogador na apuração.
class VoteTally extends Equatable {
  final String playerName;
  final String team;
  final int votes;

  const VoteTally({required this.playerName, required this.team, required this.votes});

  @override
  List<Object?> get props => [playerName, team, votes];
}

/// Apuração completa de uma partida, para a tela do eleito: o eleito (null sem
/// votos), o ranking de todos os votados e os escudos dos dois times.
class VotingResult extends Equatable {
  final ElectedPlayer? elected;
  final List<VoteTally> ranking;
  final String homeCrest;
  final String awayCrest;

  const VotingResult({this.elected, this.ranking = const [], this.homeCrest = '', this.awayCrest = ''});

  int get totalVotes => ranking.fold(0, (sum, tally) => sum + tally.votes);

  /// Fração dos votos (0–1) de [votes].
  double shareOf(int votes) => totalVotes == 0 ? 0 : votes / totalVotes;

  @override
  List<Object?> get props => [elected, ranking, homeCrest, awayCrest];
}
