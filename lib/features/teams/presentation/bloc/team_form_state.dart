import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Dados do formulário de time. Sobrevive às transições
/// Editing → Submitting → Error/Success.
class TeamFormData extends Equatable {
  /// Número sequencial que vai compor o id do time (o UseCase recalcula).
  final int? nextNumber;
  final String name;
  final String description;
  final List<String> regions;
  final String? selectedRegion;
  final File? crest;

  /// Times já cadastrados na região (lista e aviso de duplicado).
  final List<TeamDTO> existing;

  const TeamFormData({
    this.nextNumber,
    this.name = '',
    this.description = '',
    this.regions = const [],
    this.selectedRegion,
    this.crest,
    this.existing = const [],
  });

  /// Nome com no mínimo 3 caracteres (regra do app antigo).
  bool get isNameValid => name.trim().length >= 3;

  bool get canSubmit => isNameValid && selectedRegion != null;

  /// Time da região com o mesmo nome (sem diferenciar acento, caixa e
  /// espaços extras); nulo se não há.
  TeamDTO? get duplicate {
    final key = _key(name);
    if (key.isEmpty) return null;
    for (final team in existing) {
      if (_key(team.name) == key) return team;
    }
    return null;
  }

  static String _key(String text) => foldForSearch(text.trim().replaceAll(RegExp(r'\s+'), ' '));

  /// Há algo que se perderia ao sair.
  bool get isDirty => name.trim().isNotEmpty || description.trim().isNotEmpty || crest != null;

  /// Time pronto para o UseCase (o id é montado lá).
  TeamDTO toTeam() => TeamDTO(id: '', name: name.trim(), description: description, region: selectedRegion ?? '');

  /// Formulário limpo para o próximo cadastro, mantendo região e times.
  TeamFormData cleared() =>
      TeamFormData(nextNumber: nextNumber, regions: regions, selectedRegion: selectedRegion, existing: existing);

  TeamFormData copyWith({
    int? nextNumber,
    String? name,
    String? description,
    List<String>? regions,
    String? selectedRegion,
    File? crest,
    bool clearCrest = false,
    List<TeamDTO>? existing,
  }) {
    return TeamFormData(
      nextNumber: nextNumber ?? this.nextNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      regions: regions ?? this.regions,
      selectedRegion: selectedRegion ?? this.selectedRegion,
      crest: clearCrest ? null : (crest ?? this.crest),
      existing: existing ?? this.existing,
    );
  }

  @override
  List<Object?> get props => [nextNumber, name, description, regions, selectedRegion, crest?.path, existing];
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
