import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/players/domain/player_season_summary.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Dados da tela do atleta. Sobrevive às transições (o stream do jogador
/// atualiza [player]; o resto chega aos poucos).
class PlayerProfileState extends Equatable {
  final PlayerDTO? player;

  /// Time do jogador (escudo, região e o link para o elenco).
  final TeamDTO? team;

  /// Posição na artilharia e nas assistências da região (nulo = fora do
  /// ranking, ex.: sem gols).
  final int? goalsRank;
  final int? assistsRank;

  /// Cards de gol em que ele marcou ou deu o passe.
  final List<NewsDTO> participations;

  /// O jogador não existe (excluído ou id inválido).
  final bool notFound;

  /// Gravando uma edição do admin.
  final bool saving;

  /// Times da temporada (escudo de cada inscrição) e competições da região
  /// (nome de cada inscrição).
  final List<TeamDTO> teams;
  final List<ChampionshipDTO> championships;

  /// Partidas da região do time na temporada (gráfico "Últimas partidas").
  final List<MatchDTO> regionMatches;

  /// Partidas em que foi eleito o craque (troféus).
  final List<MatchDTO> awards;

  /// Temporadas do atleta com conta vinculada (vazio sem conta).
  final List<PlayerSeasonSummary> history;

  const PlayerProfileState({
    this.player,
    this.team,
    this.goalsRank,
    this.assistsRank,
    this.participations = const [],
    this.notFound = false,
    this.saving = false,
    this.teams = const [],
    this.championships = const [],
    this.regionMatches = const [],
    this.awards = const [],
    this.history = const [],
  });

  /// Nome da competição pelo `id_campeonato` (vazio se não carregou).
  String championshipTitle(int championshipId) {
    for (final c in championships) {
      if (c.championshipId == championshipId) return c.title;
    }
    return '';
  }

  /// Time da inscrição (escudo, link para o elenco).
  TeamDTO? teamOf({required String teamId, required String name}) {
    for (final t in teams) {
      if (teamId.isNotEmpty ? t.id == teamId : t.name.trim().toLowerCase() == name.trim().toLowerCase()) return t;
    }
    return null;
  }

  PlayerProfileState copyWith({
    PlayerDTO? player,
    TeamDTO? team,
    bool clearTeam = false,
    int? goalsRank,
    int? assistsRank,
    bool clearRanks = false,
    List<NewsDTO>? participations,
    bool? notFound,
    bool? saving,
    List<TeamDTO>? teams,
    List<ChampionshipDTO>? championships,
    List<MatchDTO>? regionMatches,
    List<MatchDTO>? awards,
    List<PlayerSeasonSummary>? history,
  }) {
    return PlayerProfileState(
      player: player ?? this.player,
      team: clearTeam ? null : (team ?? this.team),
      goalsRank: clearRanks ? null : (goalsRank ?? this.goalsRank),
      assistsRank: clearRanks ? null : (assistsRank ?? this.assistsRank),
      participations: participations ?? this.participations,
      notFound: notFound ?? this.notFound,
      saving: saving ?? this.saving,
      teams: teams ?? this.teams,
      championships: championships ?? this.championships,
      regionMatches: regionMatches ?? this.regionMatches,
      awards: awards ?? this.awards,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props =>
      [
        player,
        team,
        goalsRank,
        assistsRank,
        participations,
        notFound,
        saving,
        teams,
        championships,
        regionMatches,
        awards,
        history,
      ];
}

/// Uma falha de leitura ou de gravação (a tela mostra no snackbar, ou o
/// estado de erro se ainda não há jogador).
class ErrorPlayerProfileState extends PlayerProfileState {
  final String errorMessage;

  ErrorPlayerProfileState(PlayerProfileState base, this.errorMessage)
      : super(
          player: base.player,
          team: base.team,
          goalsRank: base.goalsRank,
          assistsRank: base.assistsRank,
          participations: base.participations,
          notFound: base.notFound,
          teams: base.teams,
          championships: base.championships,
          regionMatches: base.regionMatches,
          awards: base.awards,
          history: base.history,
        );

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

/// Jogador excluído pelo admin: a tela avisa e fecha.
class DeletedPlayerProfileState extends PlayerProfileState {
  final String name;
  final String teamName;

  const DeletedPlayerProfileState({required this.name, required this.teamName});

  @override
  List<Object?> get props => [...super.props, name, teamName];
}

/// Jogador vinculado tirado do elenco pelo admin: a tela avisa e continua
/// mostrando o atleta (agora sem time).
class RemovedFromSquadPlayerProfileState extends PlayerProfileState {
  final String name;
  final String teamName;

  RemovedFromSquadPlayerProfileState(PlayerProfileState base, {required this.name, required this.teamName})
      : super(
          player: base.player,
          team: base.team,
          goalsRank: base.goalsRank,
          assistsRank: base.assistsRank,
          participations: base.participations,
          notFound: base.notFound,
          teams: base.teams,
          championships: base.championships,
          regionMatches: base.regionMatches,
          awards: base.awards,
          history: base.history,
        );

  @override
  List<Object?> get props => [...super.props, name, teamName];
}
