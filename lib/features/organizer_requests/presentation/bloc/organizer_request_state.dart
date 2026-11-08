import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/organizer_requests/data/dtos/organizer_request_dto.dart';

/// Primeiro campo inválido do formulário (traduzido na página).
enum OrganizerRequestFormError { name, contact }

/// Dados do formulário "Sou organizador de campeonato".
class OrganizerRequestForm extends Equatable {
  final List<String> regions;
  final String? selectedRegion;
  final ChampionshipScope scope;
  final String name;
  final String description;
  final String contact;
  final File? logo;

  /// Logo que já estava no pedido (mantida se não trocar).
  final String imageUrl;

  const OrganizerRequestForm({
    this.regions = const [],
    this.selectedRegion,
    this.scope = ChampionshipScope.municipal,
    this.name = '',
    this.description = '',
    this.contact = '',
    this.logo,
    this.imageUrl = '',
  });

  OrganizerRequestFormError? get error {
    if (name.trim().length < OrganizerRequestDTO.nameMinLength) return OrganizerRequestFormError.name;
    if (contact.replaceAll(RegExp(r'\D'), '').length < 10) return OrganizerRequestFormError.contact;
    return null;
  }

  OrganizerRequestForm copyWith({
    List<String>? regions,
    String? selectedRegion,
    ChampionshipScope? scope,
    String? name,
    String? description,
    String? contact,
    File? Function()? logo,
    String? imageUrl,
  }) {
    return OrganizerRequestForm(
      regions: regions ?? this.regions,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      scope: scope ?? this.scope,
      name: name ?? this.name,
      description: description ?? this.description,
      contact: contact ?? this.contact,
      logo: logo != null ? logo() : this.logo,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [regions, selectedRegion, scope, name, description, contact, logo, imageUrl];
}

/// Tela "Sou organizador de campeonato": o pedido atual (ou nulo), o
/// formulário, se está editando e os campeonatos que a conta já organiza.
class OrganizerRequestState extends Equatable {
  final OrganizerRequestDTO? request;
  final OrganizerRequestForm form;
  final bool editing;
  final List<ChampionshipDTO> championships;

  const OrganizerRequestState({
    this.request,
    this.form = const OrganizerRequestForm(),
    this.editing = false,
    this.championships = const [],
  });

  /// Sem pedido, ou editando (corrigir o pendente, reenviar ou pedir outro).
  bool get showForm => request == null || editing;

  @override
  List<Object?> get props => [request, form, editing, championships];
}

class LoadingOrganizerRequestState extends OrganizerRequestState {
  const LoadingOrganizerRequestState();
}

class ReadyOrganizerRequestState extends OrganizerRequestState {
  const ReadyOrganizerRequestState({super.request, super.form, super.editing, super.championships});
}

class SubmittingOrganizerRequestState extends OrganizerRequestState {
  SubmittingOrganizerRequestState(OrganizerRequestState from)
      : super(request: from.request, form: from.form, editing: from.editing, championships: from.championships);
}

class SubmittedOrganizerRequestState extends OrganizerRequestState {
  SubmittedOrganizerRequestState(OrganizerRequestState from)
      : super(request: from.request, form: from.form, championships: from.championships);
}

class CancelledOrganizerRequestState extends OrganizerRequestState {
  CancelledOrganizerRequestState(OrganizerRequestState from)
      : super(form: from.form, championships: from.championships);
}

class ErrorOrganizerRequestState extends OrganizerRequestState {
  final String errorMessage;

  ErrorOrganizerRequestState(OrganizerRequestState from, {required this.errorMessage})
      : super(request: from.request, form: from.form, editing: from.editing, championships: from.championships);

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

class LoadErrorOrganizerRequestState extends OrganizerRequestState {
  final String errorMessage;

  const LoadErrorOrganizerRequestState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
