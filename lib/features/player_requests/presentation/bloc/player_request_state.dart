import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Primeiro campo inválido do formulário (traduzido na página).
enum PlayerRequestFormError { championship, alreadyInChampionship, team, name, position }

/// Dados do formulário "Sou jogador".
class PlayerRequestForm extends Equatable {
  static const int nameMinLength = 3;
  static const int nameMaxLength = 40;
  static const int messageMaxLength = 200;

  final List<String> regions;
  final String? selectedRegion;
  final List<TeamDTO> teams;

  /// Id do time escolhido ('' se não achar na lista).
  String get selectedTeamId => TeamDirectory(teams).idOf(name: selectedTeam ?? '');
  final bool loadingTeams;
  final String? selectedTeam;
  final String name;
  final PlayerPosition? position;
  final String message;

  /// Foto nova escolhida agora.
  final File? photo;

  /// Foto que já estava no pedido (mantida se não trocar).
  final String imageUrl;

  /// Atletas do time escolhido ainda sem conta (para o "sou eu").
  final List<PlayerDTO> unlinkedPlayers;
  final bool loadingPlayers;

  /// Atleta que o usuário diz ser (pedido de vínculo); nulo = jogador novo.
  final PlayerDTO? claimedPlayer;

  /// Competições da região (temporada atual) e a escolhida. Sem competições
  /// na região, o pedido vai só com o time, como antes.
  final List<ChampionshipDTO> championships;
  final int? championshipId;

  /// Atleta da conta na temporada (nulo = ainda não é atleta): já inscrito
  /// na competição escolhida = não pede outro time nela.
  final PlayerDTO? accountPlayer;

  const PlayerRequestForm({
    this.regions = const [],
    this.selectedRegion,
    this.teams = const [],
    this.loadingTeams = false,
    this.selectedTeam,
    this.name = '',
    this.position,
    this.message = '',
    this.photo,
    this.imageUrl = '',
    this.unlinkedPlayers = const [],
    this.loadingPlayers = false,
    this.claimedPlayer,
    this.championships = const [],
    this.championshipId,
    this.accountPlayer,
  });

  bool get isClaim => claimedPlayer != null;

  ChampionshipDTO? get selectedChampionship {
    for (final c in championships) {
      if (c.championshipId == championshipId) return c;
    }
    return null;
  }

  /// Times que dá para escolher: os da competição escolhida (sem
  /// competições na região, todos).
  List<TeamDTO> get selectableTeams {
    final championship = selectedChampionship;
    if (championship == null) return championships.isEmpty ? teams : const [];
    return teams.where((t) => championship.hasTeam(id: t.id, name: t.name)).toList();
  }

  /// Inscrição do atleta da conta na competição escolhida: na mesma
  /// temporada, um time só por competição (atleta antigo, sem inscrições, não
  /// bloqueia).
  PlayerEnrollment? get enrollmentInSelected {
    final id = championshipId;
    if (id == null) return null;
    return accountPlayer?.enrollments.where((e) => e.championshipId == id).firstOrNull;
  }

  PlayerRequestFormError? get error {
    if (championships.isNotEmpty && selectedChampionship == null) return PlayerRequestFormError.championship;
    if (enrollmentInSelected != null) return PlayerRequestFormError.alreadyInChampionship;
    if (selectedTeam == null) return PlayerRequestFormError.team;
    // Vínculo: o nome é o do atleta.
    if (!isClaim && name.trim().length < nameMinLength) return PlayerRequestFormError.name;
    if (position == null) return PlayerRequestFormError.position;
    return null;
  }

  String? crestOf(String? team) {
    for (final t in teams) {
      if (t.name == team) return t.imageUrl;
    }
    return null;
  }

  PlayerRequestForm copyWith({
    List<String>? regions,
    String? selectedRegion,
    List<TeamDTO>? teams,
    bool? loadingTeams,
    String? Function()? selectedTeam,
    String? name,
    PlayerPosition? position,
    String? message,
    File? Function()? photo,
    String? imageUrl,
    List<PlayerDTO>? unlinkedPlayers,
    bool? loadingPlayers,
    PlayerDTO? Function()? claimedPlayer,
    List<ChampionshipDTO>? championships,
    int? Function()? championshipId,
    PlayerDTO? Function()? accountPlayer,
  }) {
    return PlayerRequestForm(
      regions: regions ?? this.regions,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      teams: teams ?? this.teams,
      loadingTeams: loadingTeams ?? this.loadingTeams,
      selectedTeam: selectedTeam != null ? selectedTeam() : this.selectedTeam,
      name: name ?? this.name,
      position: position ?? this.position,
      message: message ?? this.message,
      photo: photo != null ? photo() : this.photo,
      imageUrl: imageUrl ?? this.imageUrl,
      unlinkedPlayers: unlinkedPlayers ?? this.unlinkedPlayers,
      loadingPlayers: loadingPlayers ?? this.loadingPlayers,
      claimedPlayer: claimedPlayer != null ? claimedPlayer() : this.claimedPlayer,
      championships: championships ?? this.championships,
      championshipId: championshipId != null ? championshipId() : this.championshipId,
      accountPlayer: accountPlayer != null ? accountPlayer() : this.accountPlayer,
    );
  }

  @override
  List<Object?> get props => [
        regions,
        selectedRegion,
        teams,
        loadingTeams,
        selectedTeam,
        name,
        position,
        message,
        photo,
        imageUrl,
        unlinkedPlayers,
        loadingPlayers,
        claimedPlayer,
        championships,
        championshipId,
        accountPlayer,
      ];
}

/// Tela "Sou jogador". O estado base carrega o pedido atual (ou nulo), o
/// formulário e se o usuário está editando, para sobreviverem às transições.
class PlayerRequestState extends Equatable {
  final PlayerRequestDTO? request;
  final PlayerRequestForm form;

  /// Formulário aberto sobre um pedido existente (editar/reenviar).
  final bool editing;

  const PlayerRequestState({this.request, this.form = const PlayerRequestForm(), this.editing = false});

  /// Sem pedido, ou editando: mostra o formulário; senão, o status.
  bool get showForm => request == null || editing;

  @override
  List<Object?> get props => [request, form, editing];
}

class LoadingPlayerRequestState extends PlayerRequestState {
  const LoadingPlayerRequestState();
}

class ReadyPlayerRequestState extends PlayerRequestState {
  const ReadyPlayerRequestState({super.request, super.form, super.editing});
}

class SubmittingPlayerRequestState extends PlayerRequestState {
  SubmittingPlayerRequestState(PlayerRequestState from)
      : super(request: from.request, form: from.form, editing: from.editing);
}

/// Enviado: a página mostra o aviso; o status chega pelo stream.
class SubmittedPlayerRequestState extends PlayerRequestState {
  SubmittedPlayerRequestState(PlayerRequestState from) : super(request: from.request, form: from.form);
}

class CancelledPlayerRequestState extends PlayerRequestState {
  CancelledPlayerRequestState(PlayerRequestState from) : super(form: from.form);
}

class ErrorPlayerRequestState extends PlayerRequestState {
  final String errorMessage;

  ErrorPlayerRequestState(PlayerRequestState from, {required this.errorMessage})
      : super(request: from.request, form: from.form, editing: from.editing);

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

/// Falha ao carregar o pedido ou as regiões (tela inteira com "tentar de novo").
class LoadErrorPlayerRequestState extends PlayerRequestState {
  final String errorMessage;

  const LoadErrorPlayerRequestState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
