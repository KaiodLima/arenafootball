import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Dados do formulário de time. Sobrevive às transições
/// Editing → Submitting → Error/Success.
class TeamFormData extends Equatable {
  /// Número sequencial que vai compor o id do time (só exibição).
  final int? nextNumber;
  final String name;
  final String description;
  final List<String> regions;
  final String? selectedRegion;
  final File? crest;

  const TeamFormData({
    this.nextNumber,
    this.name = '',
    this.description = '',
    this.regions = const [],
    this.selectedRegion,
    this.crest,
  });

  /// Nome com no mínimo 3 caracteres (regra do app antigo).
  bool get isNameValid => name.trim().length >= 3;

  bool get canSubmit => isNameValid && selectedRegion != null;

  /// Time pronto para o UseCase (o id é montado lá).
  TeamDTO toTeam() => TeamDTO(id: '', name: name.trim(), description: description, region: selectedRegion ?? '');

  /// Formulário limpo para o próximo cadastro, mantendo a região.
  TeamFormData cleared() => TeamFormData(nextNumber: nextNumber, regions: regions, selectedRegion: selectedRegion);

  TeamFormData copyWith({
    int? nextNumber,
    String? name,
    String? description,
    List<String>? regions,
    String? selectedRegion,
    File? crest,
  }) {
    return TeamFormData(
      nextNumber: nextNumber ?? this.nextNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      regions: regions ?? this.regions,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      crest: crest ?? this.crest,
    );
  }

  @override
  List<Object?> get props => [nextNumber, name, description, regions, selectedRegion, crest?.path];
}

class TeamFormState extends Equatable {
  final TeamFormData form;

  const TeamFormState({this.form = const TeamFormData()});

  @override
  List<Object?> get props => [form];
}

class EditingTeamFormState extends TeamFormState {
  const EditingTeamFormState({super.form});
}

class SubmittingTeamFormState extends TeamFormState {
  const SubmittingTeamFormState({required super.form});
}

/// Time gravado; [form] já vem limpo para o próximo cadastro.
class SuccessTeamFormState extends TeamFormState {
  const SuccessTeamFormState({required super.form});
}

class ErrorTeamFormState extends TeamFormState {
  final String errorMessage;

  const ErrorTeamFormState({required super.form, required this.errorMessage});

  @override
  List<Object?> get props => [form, errorMessage];
}
