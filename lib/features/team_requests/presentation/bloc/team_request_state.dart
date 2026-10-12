import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';

/// Primeiro campo inválido do formulário (traduzido na página).
enum TeamRequestFormError { name, nameTaken, contact }

/// Dados do formulário "Sou dono de time".
class TeamRequestForm extends Equatable {
  static const int nameMinLength = 3;
  static const int nameMaxLength = 40;
  static const int messageMaxLength = 200;
  static const int descriptionMaxLength = 300;

  final List<String> regions;
  final String? selectedRegion;

  /// Nomes dos times que já existem na região (aviso de nome repetido).
  final List<String> existingTeams;
  final String name;
  final String description;
  final String contact;
  final String message;
  final File? crest;

  /// Cores do time (hex; vazio = sem cor).
  final String primaryColor;
  final String secondaryColor;

  /// Escudo que já estava no pedido (mantido se não trocar).
  final String imageUrl;

  const TeamRequestForm({
    this.regions = const [],
    this.selectedRegion,
    this.existingTeams = const [],
    this.name = '',
    this.description = '',
    this.contact = '',
    this.message = '',
    this.crest,
    this.primaryColor = '',
    this.secondaryColor = '',
    this.imageUrl = '',
  });

  /// Nome igual (sem acento/caixa) a um time da região.
  String? get takenName {
    final key = foldForSearch(name.trim());
    if (key.isEmpty) return null;
    for (final team in existingTeams) {
      if (foldForSearch(team.trim()) == key) return team;
    }
    return null;
  }

  TeamRequestFormError? get error {
    if (name.trim().length < nameMinLength) return TeamRequestFormError.name;
    if (takenName != null) return TeamRequestFormError.nameTaken;
    if (contact.replaceAll(RegExp(r'\D'), '').length < 10) return TeamRequestFormError.contact;
    return null;
  }

  TeamRequestForm copyWith({
    List<String>? regions,
    String? selectedRegion,
    List<String>? existingTeams,
    String? name,
    String? description,
    String? contact,
    String? message,
    File? Function()? crest,
    String? primaryColor,
    String? secondaryColor,
    String? imageUrl,
  }) {
    return TeamRequestForm(
      regions: regions ?? this.regions,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      existingTeams: existingTeams ?? this.existingTeams,
      name: name ?? this.name,
      description: description ?? this.description,
      contact: contact ?? this.contact,
      message: message ?? this.message,
      crest: crest != null ? crest() : this.crest,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props =>
      [regions, selectedRegion, existingTeams, name, description, contact, message, crest, primaryColor, secondaryColor,
        imageUrl];
}

/// Tela "Sou dono de time". O estado base carrega o pedido atual (ou nulo),
/// o formulário e se o usuário está editando.
class TeamRequestState extends Equatable {
  final TeamRequestDTO? request;
  final TeamRequestForm form;
  final bool editing;

  const TeamRequestState({this.request, this.form = const TeamRequestForm(), this.editing = false});

  bool get showForm => request == null || editing;

  @override
  List<Object?> get props => [request, form, editing];
}

class LoadingTeamRequestState extends TeamRequestState {
  const LoadingTeamRequestState();
}

class ReadyTeamRequestState extends TeamRequestState {
  const ReadyTeamRequestState({super.request, super.form, super.editing});
}

class SubmittingTeamRequestState extends TeamRequestState {
  SubmittingTeamRequestState(TeamRequestState from)
      : super(request: from.request, form: from.form, editing: from.editing);
}

class SubmittedTeamRequestState extends TeamRequestState {
  SubmittedTeamRequestState(TeamRequestState from) : super(request: from.request, form: from.form);
}

class CancelledTeamRequestState extends TeamRequestState {
  CancelledTeamRequestState(TeamRequestState from) : super(form: from.form);
}

class ErrorTeamRequestState extends TeamRequestState {
  final String errorMessage;

  ErrorTeamRequestState(TeamRequestState from, {required this.errorMessage})
      : super(request: from.request, form: from.form, editing: from.editing);

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

class LoadErrorTeamRequestState extends TeamRequestState {
  final String errorMessage;

  const LoadErrorTeamRequestState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
