import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

/// Ordenação do elenco na tela.
enum PlayersSort { goals, assists, name }

/// O estado base carrega o elenco e a visão escolhida (ordenação e busca),
/// preservados em todas as transições.
class TeamPlayersState extends Equatable {
  final List<PlayerDTO> players;
  final PlayersSort sort;
  final String query;

  const TeamPlayersState({this.players = const [], this.sort = PlayersSort.goals, this.query = ''});

  /// Versão mais recente do jogador na lista (o painel de detalhes lê daqui
  /// para refletir as edições). [fallback] se ele não estiver mais na lista.
  PlayerDTO playerById(String id, PlayerDTO fallback) {
    for (final player in players) {
      if (player.id == id) return player;
    }
    return fallback;
  }

  /// Elenco filtrado pela busca e ordenado (empate pelo nome).
  List<PlayerDTO> get visiblePlayers {
    final term = foldForSearch(query.trim());
    final filtered = term.isEmpty ? [...players] : players.where((p) => foldForSearch(p.name).contains(term)).toList();
    int byName(PlayerDTO a, PlayerDTO b) => foldForSearch(a.name).compareTo(foldForSearch(b.name));
    filtered.sort((a, b) {
      switch (sort) {
        case PlayersSort.goals:
          final diff = b.goals.compareTo(a.goals);
          return diff != 0 ? diff : byName(a, b);
        case PlayersSort.assists:
          final diff = b.assists.compareTo(a.assists);
          return diff != 0 ? diff : byName(a, b);
        case PlayersSort.name:
          return byName(a, b);
      }
    });
    return filtered;
  }

  int get totalGoals => players.fold(0, (sum, p) => sum + p.goals);

  int get totalAssists => players.fold(0, (sum, p) => sum + p.assists);

  /// Artilheiro do time (maior número de gols, se alguém marcou).
  String? get topScorerId {
    PlayerDTO? top;
    for (final player in players) {
      if (player.goals > 0 && (top == null || player.goals > top.goals)) top = player;
    }
    return top?.id;
  }

  @override
  List<Object?> get props => [players, sort, query];
}

class LoadingTeamPlayersState extends TeamPlayersState {
  const LoadingTeamPlayersState({super.players, super.sort, super.query});
}

class SuccessTeamPlayersState extends TeamPlayersState {
  const SuccessTeamPlayersState({required super.players, super.sort, super.query});
}

/// Enviando a foto de um jogador.
class SavingTeamPlayersState extends TeamPlayersState {
  final String playerId;

  const SavingTeamPlayersState({required this.playerId, required super.players, super.sort, super.query});

  @override
  List<Object?> get props => [...super.props, playerId];
}

class ErrorTeamPlayersState extends TeamPlayersState {
  final String errorMessage;

  const ErrorTeamPlayersState({required this.errorMessage, super.players, super.sort, super.query});

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
