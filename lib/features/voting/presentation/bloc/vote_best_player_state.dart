import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';

/// Elencos dos dois times, o jogador escolhido, o voto atual do usuário e o
/// recorte da tela (time exibido e busca). Sobrevive a todas as transições.
class VoteBestPlayerState extends Equatable {
  final List<PlayerDTO> homePlayers;
  final List<PlayerDTO> awayPlayers;

  /// Jogador escolhido (nome + time); nulo enquanto ninguém foi tocado.
  final PlayerDTO? selected;

  /// Voto já gravado do usuário nesta partida; nulo se não votou (ou convidado).
  final VoteDTO? myVote;

  /// Elenco exibido: visitante (true) ou mandante (false).
  final bool showAway;
  final String query;
  final String homeCrest;
  final String awayCrest;

  const VoteBestPlayerState({
    this.homePlayers = const [],
    this.awayPlayers = const [],
    this.selected,
    this.myVote,
    this.showAway = false,
    this.query = '',
    this.homeCrest = '',
    this.awayCrest = '',
  });

  bool isSelected(PlayerDTO player) => selected?.id == player.id && selected?.team == player.team;

  /// O voto é gravado por nome + time (não há id do jogador no voto).
  bool isMyVote(PlayerDTO player) => myVote != null && myVote!.playerName == player.name && myVote!.team == player.team;

  /// O jogador escolhido já é o voto gravado (votar de novo não muda nada).
  bool get selectedIsMyVote => selected != null && isMyVote(selected!);

  /// Elenco do time exibido, filtrado pela busca (sem diferenciar acento/caixa).
  List<PlayerDTO> get visiblePlayers {
    final players = showAway ? awayPlayers : homePlayers;
    final term = foldForSearch(query.trim());
    if (term.isEmpty) return players;
    return players.where((p) => foldForSearch(p.name).contains(term)).toList();
  }

  /// Elenco do time exibido sem a busca (vazio = elenco não cadastrado).
  List<PlayerDTO> get currentSquad => showAway ? awayPlayers : homePlayers;

  @override
  List<Object?> get props => [homePlayers, awayPlayers, selected, myVote, showAway, query, homeCrest, awayCrest];
}

class LoadingVoteBestPlayerState extends VoteBestPlayerState {
  const LoadingVoteBestPlayerState({
    super.homePlayers,
    super.awayPlayers,
    super.selected,
    super.myVote,
    super.showAway,
    super.query,
    super.homeCrest,
    super.awayCrest,
  });
}

class ReadyVoteBestPlayerState extends VoteBestPlayerState {
  const ReadyVoteBestPlayerState({
    super.homePlayers,
    super.awayPlayers,
    super.selected,
    super.myVote,
    super.showAway,
    super.query,
    super.homeCrest,
    super.awayCrest,
  });
}

class SubmittingVoteBestPlayerState extends VoteBestPlayerState {
  const SubmittingVoteBestPlayerState({
    super.homePlayers,
    super.awayPlayers,
    super.selected,
    super.myVote,
    super.showAway,
    super.query,
    super.homeCrest,
    super.awayCrest,
  });
}

/// Voto gravado (em [selected], que agora também é o [myVote]).
class SuccessVoteBestPlayerState extends VoteBestPlayerState {
  const SuccessVoteBestPlayerState({
    super.homePlayers,
    super.awayPlayers,
    required super.selected,
    super.myVote,
    super.showAway,
    super.query,
    super.homeCrest,
    super.awayCrest,
  });
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
    super.myVote,
    super.showAway,
    super.query,
    super.homeCrest,
    super.awayCrest,
  });

  @override
  List<Object?> get props => [...super.props, errorMessage, errorCode];
}
