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

  const ElectedPlayer({
    required this.playerName,
    required this.team,
    required this.votes,
    this.playerImageUrl = '',
    this.teamImageUrl = '',
  });

  ElectedPlayer copyWith({String? playerImageUrl, String? teamImageUrl}) {
    return ElectedPlayer(
      playerName: playerName,
      team: team,
      votes: votes,
      playerImageUrl: playerImageUrl ?? this.playerImageUrl,
      teamImageUrl: teamImageUrl ?? this.teamImageUrl,
    );
  }

  @override
  List<Object?> get props => [playerName, team, votes, playerImageUrl, teamImageUrl];
}
