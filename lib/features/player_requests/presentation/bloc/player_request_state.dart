import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Primeiro campo inválido do formulário (traduzido na página).
enum PlayerRequestFormError { team, name, position }

/// Dados do formulário "Sou jogador".
class PlayerRequestForm extends Equatable {
  static const int nameMinLength = 3;
  static const int nameMaxLength = 40;
  static const int messageMaxLength = 200;

  final List<String> regions;
  final String? selectedRegion;
  final List<TeamDTO> teams;
  final bool loadingTeams;
  final String? selectedTeam;
  final String name;
  final PlayerPosition? position;
  final String message;

  /// Foto nova escolhida agora.
  final File? photo;

  /// Foto que já estava no pedido (mantida se não trocar).
  final String imageUrl;

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
  });

  PlayerRequestFormError? get error {
    if (selectedTeam == null) return PlayerRequestFormError.team;
    if (name.trim().length < nameMinLength) return PlayerRequestFormError.name;
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
    );
  }

  @override
  List<Object?> get props =>
      [regions, selectedRegion, teams, loadingTeams, selectedTeam, name, position, message, photo, imageUrl];
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
