import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/championship_rules_file.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Primeiro campo inválido (traduzido na página).
enum ChampionshipFormError { title, teams }

/// Dados do formulário de campeonato. [base] é o campeonato em edição (ou um
/// novo, sem id); os campos editáveis ficam soltos para o formulário.
class ChampionshipFormData extends Equatable {
  final ChampionshipDTO base;
  final List<String> regions;
  final List<String> seasons;

  /// Times da região/temporada escolhidas (para a grade).
  final List<TeamDTO> teams;
  final bool loadingTeams;

  /// Nomes marcados, na ordem em que foram marcados.
  final List<String> selectedTeams;

  final File? banner;
  final ChampionshipRulesFile? rulesFile;

  /// Algo mudou desde que abriu (sair pede confirmação).
  final bool dirty;

  const ChampionshipFormData({
    required this.base,
    this.regions = const [],
    this.seasons = const [],
    this.teams = const [],
    this.loadingTeams = false,
    this.selectedTeams = const [],
    this.banner,
    this.rulesFile,
    this.dirty = false,
  });

  bool get isEditing => base.id.isNotEmpty;

  /// Tem regulamento: o novo escolhido agora ou o que já estava gravado.
  bool get hasRules => rulesFile != null || base.rulesUrl.isNotEmpty;

  String get rulesName => rulesFile?.name ?? base.rulesFileName;

  ChampionshipFormError? get error {
    if (base.title.trim().length < 3) return ChampionshipFormError.title;
    if (selectedTeams.isEmpty) return ChampionshipFormError.teams;
    return null;
  }

  ChampionshipFormData copyWith({
    ChampionshipDTO? base,
    List<String>? regions,
    List<String>? seasons,
    List<TeamDTO>? teams,
    bool? loadingTeams,
    List<String>? selectedTeams,
    File? Function()? banner,
    ChampionshipRulesFile? Function()? rulesFile,
    bool? dirty,
  }) {
    return ChampionshipFormData(
      base: base ?? this.base,
      regions: regions ?? this.regions,
      seasons: seasons ?? this.seasons,
      teams: teams ?? this.teams,
      loadingTeams: loadingTeams ?? this.loadingTeams,
      selectedTeams: selectedTeams ?? this.selectedTeams,
      banner: banner != null ? banner() : this.banner,
      rulesFile: rulesFile != null ? rulesFile() : this.rulesFile,
      dirty: dirty ?? this.dirty,
    );
  }

  @override
  List<Object?> get props => [base, regions, seasons, teams, loadingTeams, selectedTeams, banner, rulesFile, dirty];
}

class ChampionshipFormState extends Equatable {
  final ChampionshipFormData form;

  const ChampionshipFormState(this.form);

  @override
  List<Object?> get props => [form];
}

class LoadingChampionshipFormState extends ChampionshipFormState {
  const LoadingChampionshipFormState(super.form);
}

class EditingChampionshipFormState extends ChampionshipFormState {
  const EditingChampionshipFormState(super.form);
}

class SubmittingChampionshipFormState extends ChampionshipFormState {
  const SubmittingChampionshipFormState(super.form);
}

/// Salvo: a página avisa e fecha.
class SavedChampionshipFormState extends ChampionshipFormState {
  final bool created;

  const SavedChampionshipFormState(super.form, {required this.created});

  @override
  List<Object?> get props => [...super.props, created];
}

class ErrorChampionshipFormState extends ChampionshipFormState {
  final String errorMessage;

  const ErrorChampionshipFormState(super.form, {required this.errorMessage});

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

/// Falha ao carregar as regiões (tela com "tentar de novo").
class LoadErrorChampionshipFormState extends ChampionshipFormState {
  const LoadErrorChampionshipFormState(super.form);
}
