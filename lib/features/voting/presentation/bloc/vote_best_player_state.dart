import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

/// Elencos dos dois times e o jogador escolhido. Sobrevive a todas as
/// transições.
class VoteBestPlayerState extends Equatable {
  final List<PlayerDTO> homePlayers;
  final List<PlayerDTO> awayPlayers;

  /// Jogador escolhido (nome + time); nulo enquanto ninguém foi tocado.
  final PlayerDTO? selected;

  const VoteBestPlayerState({this.homePlayers = const [], this.awayPlayers = const [], this.selected});

  bool isSelected(PlayerDTO player) => selected?.id == player.id && selected?.team == player.team;

  @override
  List<Object?> get props => [homePlayers, awayPlayers, selected];
}

class LoadingVoteBestPlayerState extends VoteBestPlayerState {
  const LoadingVoteBestPlayerState({super.homePlayers, super.awayPlayers, super.selected});
}

class ReadyVoteBestPlayerState extends VoteBestPlayerState {
  const ReadyVoteBestPlayerState({super.homePlayers, super.awayPlayers, super.selected});
}

class SubmittingVoteBestPlayerState extends VoteBestPlayerState {
  const SubmittingVoteBestPlayerState({super.homePlayers, super.awayPlayers, super.selected});
}

/// Voto gravado (em [selected]).
class SuccessVoteBestPlayerState extends VoteBestPlayerState {
  const SuccessVoteBestPlayerState({super.homePlayers, super.awayPlayers, required super.selected});
}

class ErrorVoteBestPlayerState extends VoteBestPlayerState {
  final String errorMessage;

  /// `code` da falha (ex.: [CastVoteUseCase.loginRequiredCode]) para a tela
  /// escolher o texto traduzido.
  final String? errorCode;

  const ErrorVoteBestPlayerState({
    required this.errorMessage,
    this.errorCode,
    super.homePlayers,
    super.awayPlayers,
    super.selected,
  });

  @override
  List<Object?> get props => [homePlayers, awayPlayers, selected, errorMessage, errorCode];
}
