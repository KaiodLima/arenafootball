import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

/// Ordenação do elenco na tela.
enum PlayersSort { goals, assists, name }

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
    this.sort = PlayersSort.goals,
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

  /// Quem está na lista escolhida: o elenco geral ou o da competição.
  List<PlayerDTO> get squad {
    final id = championshipId;
    if (id == null) return players;
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
