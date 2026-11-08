import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

/// Ordenação do elenco na tela. Posição (padrão) agrupa por setor.
enum PlayersSort { position, goals, assists, name }

/// Bloco da lista do elenco: os atletas de uma posição (ordenação por
/// posição; [position] nula = "Sem posição") ou a lista inteira ([grouped]
/// falso), ranqueada por gols/assistências ([ranked]).
class SquadSection extends Equatable {
  final bool grouped;
  final PlayerPosition? position;
  final bool ranked;
  final List<PlayerDTO> players;

  const SquadSection({required this.players, this.grouped = false, this.position, this.ranked = false});

  @override
  List<Object?> get props => [grouped, position, ranked, players];
}

/// Ordem do setor na lista (sem posição no fim).
int positionOrder(PlayerDTO player) {
  final position = PlayerPosition.fromKey(player.position);
  return position == null ? PlayerPosition.values.length : position.index;
}

/// Seções da lista já filtrada e ordenada ([visible]): por posição, um bloco
/// por setor na ordem do campo (goleiros → atacantes, sem posição no fim);
/// nas outras ordenações, um bloco só (ranqueado em gols/assistências).
List<SquadSection> squadSections(List<PlayerDTO> visible, PlayersSort sort) {
  if (visible.isEmpty) return const [];
  if (sort != PlayersSort.position) {
    return [SquadSection(players: visible, ranked: sort == PlayersSort.goals || sort == PlayersSort.assists)];
  }
  final byPosition = <int, List<PlayerDTO>>{};
  for (final player in visible) {
    byPosition.putIfAbsent(positionOrder(player), () => []).add(player);
  }
  final orders = byPosition.keys.toList()..sort();
  return [
    for (final order in orders)
      SquadSection(
        grouped: true,
        position: order < PlayerPosition.values.length ? PlayerPosition.values[order] : null,
        players: byPosition[order]!,
      ),
  ];
}

/// Como o elenco está sendo visto: time, competição escolhida ("Elenco geral"
/// = nula), as competições do time na temporada, ordenação e busca.
class TeamPlayersView extends Equatable {
  final String teamId;
  final String teamName;
  final List<ChampionshipDTO> championships;

  /// `id_campeonato` da sublista; nula = elenco geral.
  final int? championshipId;
  final PlayersSort sort;
  final String query;

  const TeamPlayersView({
    this.teamId = '',
    this.teamName = '',
    this.championships = const [],
    this.championshipId,
    this.sort = PlayersSort.position,
    this.query = '',
  });

  TeamPlayersView copyWith({
    String? teamId,
    String? teamName,
    List<ChampionshipDTO>? championships,
    int? Function()? championshipId,
    PlayersSort? sort,
    String? query,
  }) {
    return TeamPlayersView(
      teamId: teamId ?? this.teamId,
      teamName: teamName ?? this.teamName,
      championships: championships ?? this.championships,
      championshipId: championshipId != null ? championshipId() : this.championshipId,
      sort: sort ?? this.sort,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [teamId, teamName, championships, championshipId, sort, query];
}

/// O estado base carrega o elenco geral e a visão escolhida, preservados em
/// todas as transições.
class TeamPlayersState extends Equatable {
  /// Elenco geral: todos que jogam pelo time em alguma competição da temporada.
  final List<PlayerDTO> players;
  final TeamPlayersView view;

  const TeamPlayersState({this.players = const [], this.view = const TeamPlayersView()});

  PlayersSort get sort => view.sort;
  String get query => view.query;
  int? get championshipId => view.championshipId;

  /// Algum atleta do elenco tem gol ou assistência em amistoso (chip "Amistosos").
  bool get hasFriendlies => players.any((p) => p.friendlyGoals > 0 || p.friendlyAssists > 0);

  /// Quem está na lista escolhida: o elenco geral, o da competição ou, nos
  /// amistosos ([PlayerDTO.friendlyId]), quem tem números neles.
  List<PlayerDTO> get squad {
    final id = championshipId;
    if (id == null) return players;
    if (id == PlayerDTO.friendlyId) {
      return players.where((p) => p.friendlyGoals > 0 || p.friendlyAssists > 0).toList();
    }
    return players.where((p) => p.playsIn(id, teamId: view.teamId, teamName: view.teamName)).toList();
  }

  /// Números de cada atleta na lista escolhida (total ou da competição).
  int goalsOf(PlayerDTO player) => player.statIn(PlayerDTO.goalsField, championshipId);

  int assistsOf(PlayerDTO player) => player.statIn(PlayerDTO.assistsField, championshipId);

  /// Lista filtrada pela busca e ordenada (empate pelo nome).
  List<PlayerDTO> get visiblePlayers {
    final term = foldForSearch(query.trim());
    final base = squad;
    final filtered = term.isEmpty ? [...base] : base.where((p) => foldForSearch(p.name).contains(term)).toList();
    int byName(PlayerDTO a, PlayerDTO b) => foldForSearch(a.name).compareTo(foldForSearch(b.name));
    filtered.sort((a, b) {
      switch (sort) {
        case PlayersSort.position:
          final diff = positionOrder(a).compareTo(positionOrder(b));
          return diff != 0 ? diff : byName(a, b);
        case PlayersSort.goals:
          final diff = goalsOf(b).compareTo(goalsOf(a));
          return diff != 0 ? diff : byName(a, b);
        case PlayersSort.assists:
          final diff = assistsOf(b).compareTo(assistsOf(a));
          return diff != 0 ? diff : byName(a, b);
        case PlayersSort.name:
          return byName(a, b);
      }
    });
    return filtered;
  }

  /// Blocos da lista na tela (ver [squadSections]).
  List<SquadSection> get sections => squadSections(visiblePlayers, sort);

  int get totalGoals => squad.fold(0, (sum, p) => sum + goalsOf(p));

  int get totalAssists => squad.fold(0, (sum, p) => sum + assistsOf(p));

  /// Artilheiro da lista (maior número de gols, se alguém marcou).
  String? get topScorerId {
    PlayerDTO? top;
    for (final player in squad) {
      if (goalsOf(player) > 0 && (top == null || goalsOf(player) > goalsOf(top))) top = player;
    }
    return top?.id;
  }

  /// Artilheiro e garçom da lista escolhida (nulos sem gol/assistência).
  PlayerDTO? get topScorer => _top(goalsOf);

  PlayerDTO? get topAssister => _top(assistsOf);

  PlayerDTO? _top(int Function(PlayerDTO) of) {
    PlayerDTO? top;
    for (final player in squad) {
      if (of(player) > 0 && (top == null || of(player) > of(top))) top = player;
    }
    return top;
  }

  @override
  List<Object?> get props => [players, view];
}

class LoadingTeamPlayersState extends TeamPlayersState {
  const LoadingTeamPlayersState({super.players, super.view});
}

class SuccessTeamPlayersState extends TeamPlayersState {
  const SuccessTeamPlayersState({required super.players, super.view});
}

class ErrorTeamPlayersState extends TeamPlayersState {
  final String errorMessage;

  const ErrorTeamPlayersState({required this.errorMessage, super.players, super.view});

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

/// Excluindo o time (admin): a página bloqueia as ações.
class DeletingTeamPlayersState extends TeamPlayersState {
  const DeletingTeamPlayersState({super.players, super.view});
}

/// Time excluído: a página avisa e fecha.
class DeletedTeamPlayersState extends TeamPlayersState {
  final String teamName;

  const DeletedTeamPlayersState({required this.teamName});

  @override
  List<Object?> get props => [...super.props, teamName];
}
