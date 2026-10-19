import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// "Meu time" (dono aprovado): o time, o elenco e os pedidos "Sou jogador"
/// para ele. O estado base carrega tudo para sobreviver às transições.
class MyTeamState extends Equatable {
  final TeamDTO? team;
  final List<PlayerDTO> players;
  final List<PlayerRequestDTO> requests;

  /// Pedidos com resposta sendo gravada.
  final Set<String> busy;

  /// Gravando a edição do time ou um jogador novo.
  final bool saving;
  final bool loading;

  /// Competições da temporada que o time joga (jogador novo entra numa delas).
  final List<ChampionshipDTO> championships;

  const MyTeamState({
    this.team,
    this.players = const [],
    this.requests = const [],
    this.busy = const {},
    this.saving = false,
    this.loading = true,
    this.championships = const [],
  });

  List<PlayerRequestDTO> get pendingRequests => requests.where((r) => r.isPending).toList();

  MyTeamState copyWith({
    TeamDTO? team,
    List<PlayerDTO>? players,
    List<PlayerRequestDTO>? requests,
    Set<String>? busy,
    bool? saving,
    bool? loading,
    List<ChampionshipDTO>? championships,
  }) {
    return MyTeamState(
      team: team ?? this.team,
      players: players ?? this.players,
      requests: requests ?? this.requests,
      busy: busy ?? this.busy,
      saving: saving ?? this.saving,
      loading: loading ?? this.loading,
      championships: championships ?? this.championships,
    );
  }

  @override
  List<Object?> get props => [team, players, requests, busy, saving, loading, championships];
}

/// Avisos de uma ação (a página mostra o snackbar).
class MyTeamNoticeState extends MyTeamState {
  final MyTeamNotice notice;

  /// Nome (do jogador ou do time) usado na mensagem.
  final String name;

  MyTeamNoticeState(MyTeamState from, {required this.notice, this.name = ''})
      : super(
          team: from.team,
          players: from.players,
          requests: from.requests,
          busy: from.busy,
          saving: from.saving,
          loading: from.loading,
          championships: from.championships,
        );

  @override
  List<Object?> get props => [...super.props, notice, name];
}

enum MyTeamNotice { saved, playerAdded, requestApproved, requestRejected }

class ErrorMyTeamState extends MyTeamState {
  final String errorMessage;

  ErrorMyTeamState(MyTeamState from, {required this.errorMessage})
      : super(
          team: from.team,
          players: from.players,
          requests: from.requests,
          busy: from.busy,
          saving: false,
          loading: false,
          championships: from.championships,
        );

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
