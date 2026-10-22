import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/voting/domain/voting_outcome.dart';

/// Resultado da votação de melhor jogador de uma partida.
class ElectedPlayer extends Equatable {
  final String playerName;

  /// Time do jogador (vem dos votos) e o id dele ('' em votos antigos).
  final String team;
  final String teamId;
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
    this.teamId = '',
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
      teamId: teamId,
      votes: votes,
      playerImageUrl: playerImageUrl ?? this.playerImageUrl,
      teamImageUrl: teamImageUrl ?? this.teamImageUrl,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
    );
  }

  @override
  List<Object?> get props => [playerName, team, teamId, votes, playerImageUrl, teamImageUrl, goals, assists];
}

/// Votos de um jogador na apuração.
class VoteTally extends Equatable {
  final String playerName;
  final String team;

  /// Id do time ('' em votos antigos).
  final String teamId;
  final int votes;

  const VoteTally({required this.playerName, required this.team, this.teamId = '', required this.votes});

  @override
  List<Object?> get props => [playerName, team, teamId, votes];
}

/// Apuração completa de uma partida, para a tela do eleito: o eleito (null se
/// a votação não valeu: ver [outcome]), o resultado das regras, o ranking de todos os votados e os escudos e cores (hex, vazio =
/// sem cor) dos dois times.
class VotingResult extends Equatable {
  final ElectedPlayer? elected;

  /// Resultado das regras (nulo = sem apuração).
  final VotingOutcome? outcome;
  final List<VoteTally> ranking;
  final String homeCrest;
  final String awayCrest;
  final String homePrimaryColor;
  final String homeSecondaryColor;
  final String awayPrimaryColor;
  final String awaySecondaryColor;

  const VotingResult({
    this.elected,
    this.outcome,
    this.ranking = const [],
    this.homeCrest = '',
    this.awayCrest = '',
    this.homePrimaryColor = '',
    this.homeSecondaryColor = '',
    this.awayPrimaryColor = '',
    this.awaySecondaryColor = '',
  });

  int get totalVotes => ranking.fold(0, (sum, tally) => sum + tally.votes);

  /// Fração dos votos (0–1) de [votes].
  double shareOf(int votes) => totalVotes == 0 ? 0 : votes / totalVotes;

  @override
  List<Object?> get props => [
        elected,
        outcome,
        ranking,
        homeCrest,
        awayCrest,
        homePrimaryColor,
        homeSecondaryColor,
        awayPrimaryColor,
        awaySecondaryColor,
      ];
}
