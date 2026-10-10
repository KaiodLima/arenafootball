import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

class TeamPlayersState extends Equatable {
  final List<PlayerDTO> players;

  const TeamPlayersState({this.players = const []});

  /// Versão mais recente do jogador na lista (o diálogo de detalhes lê daqui
  /// para refletir as edições). [fallback] se ele não estiver mais na lista.
  PlayerDTO playerById(String id, PlayerDTO fallback) {
    for (final player in players) {
      if (player.id == id) return player;
    }
    return fallback;
  }

  @override
  List<Object?> get props => [players];
}

class LoadingTeamPlayersState extends TeamPlayersState {
  const LoadingTeamPlayersState({super.players});
}

class SuccessTeamPlayersState extends TeamPlayersState {
  const SuccessTeamPlayersState({required super.players});
}

/// Enviando a foto de um jogador.
class SavingTeamPlayersState extends TeamPlayersState {
  final String playerId;

  const SavingTeamPlayersState({required this.playerId, required super.players});

  @override
  List<Object?> get props => [players, playerId];
}

class ErrorTeamPlayersState extends TeamPlayersState {
  final String errorMessage;

  const ErrorTeamPlayersState({required this.errorMessage, super.players});

  @override
  List<Object?> get props => [players, errorMessage];
}
