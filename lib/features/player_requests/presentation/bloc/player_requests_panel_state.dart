import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Painel do admin. O estado base carrega os pedidos, os times (escudos e
/// edição) e os jogadores da temporada (aviso de nome repetido), para
/// sobreviverem às transições.
class PlayerRequestsPanelState extends Equatable {
  final List<PlayerRequestDTO> requests;
  final List<TeamDTO> teams;
  final List<PlayerDTO> players;

  /// Pedidos com resposta sendo gravada (botões desabilitados).
  final Set<String> busy;

  const PlayerRequestsPanelState({
    this.requests = const [],
    this.teams = const [],
    this.players = const [],
    this.busy = const {},
  });

  List<PlayerRequestDTO> get pending => requests.where((r) => r.isPending).toList();

  List<PlayerRequestDTO> get answered => requests.where((r) => !r.isPending).toList();

  String? crestOf(String team) {
    for (final t in teams) {
      if (t.name == team) return t.imageUrl;
    }
    return null;
  }

  List<TeamDTO> teamsOf(String region) => teams.where((t) => t.region == region).toList();

  /// Jogador do mesmo time com o mesmo nome (sem acento/caixa), que não seja
  /// o próprio usuário do pedido.
  PlayerDTO? duplicateOf(PlayerRequestDTO request) {
    // Pedido de vínculo: o "duplicado" é o próprio atleta reivindicado.
    if (request.isClaim) return null;
    final key = foldForSearch(request.name.trim());
    if (key.isEmpty) return null;
    for (final player in players) {
      if (sameTeam(idA: player.teamId, nameA: player.team, idB: request.teamId, nameB: request.team) &&
          player.userId != request.userId &&
          foldForSearch(player.name.trim()) == key) {
        return player;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [requests, teams, players, busy];
}

class LoadingPlayerRequestsPanelState extends PlayerRequestsPanelState {
  const LoadingPlayerRequestsPanelState();
}

class ReadyPlayerRequestsPanelState extends PlayerRequestsPanelState {
  const ReadyPlayerRequestsPanelState({super.requests, super.teams, super.players, super.busy});
}

class ErrorPlayerRequestsPanelState extends PlayerRequestsPanelState {
  final String errorMessage;

  ErrorPlayerRequestsPanelState(PlayerRequestsPanelState from, {required this.errorMessage})
      : super(requests: from.requests, teams: from.teams, players: from.players, busy: from.busy);

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

class ApprovedPlayerRequestsPanelState extends PlayerRequestsPanelState {
  final String name;
  final String team;

  ApprovedPlayerRequestsPanelState(PlayerRequestsPanelState from, {required this.name, required this.team})
      : super(requests: from.requests, teams: from.teams, players: from.players, busy: from.busy);

  @override
  List<Object?> get props => [...super.props, name, team];
}

class RejectedPlayerRequestsPanelState extends PlayerRequestsPanelState {
  RejectedPlayerRequestsPanelState(PlayerRequestsPanelState from)
      : super(requests: from.requests, teams: from.teams, players: from.players, busy: from.busy);
}

class UpdatedPlayerRequestsPanelState extends PlayerRequestsPanelState {
  UpdatedPlayerRequestsPanelState(PlayerRequestsPanelState from)
      : super(requests: from.requests, teams: from.teams, players: from.players, busy: from.busy);
}
