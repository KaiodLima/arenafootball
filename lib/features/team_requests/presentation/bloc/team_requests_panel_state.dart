import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Painel do admin com os pedidos de time. Os times da temporada servem para
/// o aviso de nome repetido na região.
class TeamRequestsPanelState extends Equatable {
  final List<TeamRequestDTO> requests;
  final List<TeamDTO> teams;
  final Set<String> busy;
  final bool loading;

  const TeamRequestsPanelState({
    this.requests = const [],
    this.teams = const [],
    this.busy = const {},
    this.loading = true,
  });

  List<TeamRequestDTO> get pending => requests.where((r) => r.isPending).toList();

  List<TeamRequestDTO> get answered => requests.where((r) => !r.isPending).toList();

  /// Time já existente com o mesmo nome (sem acento/caixa) na região do pedido.
  TeamDTO? duplicateOf(TeamRequestDTO request) {
    final key = foldForSearch(request.name.trim());
    if (key.isEmpty) return null;
    for (final team in teams) {
      if (team.region == request.region && foldForSearch(team.name.trim()) == key) return team;
    }
    return null;
  }

  TeamRequestsPanelState copyWith({
    List<TeamRequestDTO>? requests,
    List<TeamDTO>? teams,
    Set<String>? busy,
    bool? loading,
  }) {
    return TeamRequestsPanelState(
      requests: requests ?? this.requests,
      teams: teams ?? this.teams,
      busy: busy ?? this.busy,
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [requests, teams, busy, loading];
}

enum TeamRequestsNotice { approved, rejected, updated }

class NoticeTeamRequestsPanelState extends TeamRequestsPanelState {
  final TeamRequestsNotice notice;
  final String name;

  NoticeTeamRequestsPanelState(TeamRequestsPanelState from, {required this.notice, this.name = ''})
      : super(requests: from.requests, teams: from.teams, busy: from.busy, loading: from.loading);

  @override
  List<Object?> get props => [...super.props, notice, name];
}

class ErrorTeamRequestsPanelState extends TeamRequestsPanelState {
  final String errorMessage;

  ErrorTeamRequestsPanelState(TeamRequestsPanelState from, {required this.errorMessage})
      : super(requests: from.requests, teams: from.teams, busy: from.busy, loading: false);

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
