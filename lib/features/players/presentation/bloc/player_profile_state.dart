import 'package:equatable/equatable.dart';
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

  const PlayerProfileState({
    this.player,
    this.team,
    this.goalsRank,
    this.assistsRank,
    this.participations = const [],
    this.notFound = false,
    this.saving = false,
  });

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
  }) {
    return PlayerProfileState(
      player: player ?? this.player,
      team: clearTeam ? null : (team ?? this.team),
      goalsRank: clearRanks ? null : (goalsRank ?? this.goalsRank),
      assistsRank: clearRanks ? null : (assistsRank ?? this.assistsRank),
      participations: participations ?? this.participations,
      notFound: notFound ?? this.notFound,
      saving: saving ?? this.saving,
    );
  }

  @override
  List<Object?> get props => [player, team, goalsRank, assistsRank, participations, notFound, saving];
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
        );

  @override
  List<Object?> get props => [...super.props, name, teamName];
}
