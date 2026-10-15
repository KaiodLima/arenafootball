import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/regions/domain/region_usage.dart';
import 'package:arena_soccer/features/regions/domain/usecases/create_region_usecase.dart';

/// Painel de regiões: os nomes e quantos times cada uma tem na temporada
/// atual, preservados em todas as transições.
class ManageRegionsState extends Equatable {
  final List<String> regions;
  final Map<String, int> teamCounts;

  /// Gravando o formulário (criar/renomear).
  final bool saving;

  /// Operação longa em andamento (conferir conteúdo, excluir, vincular).
  final bool working;

  const ManageRegionsState({
    this.regions = const [],
    this.teamCounts = const {},
    this.saving = false,
    this.working = false,
  });

  int teamsIn(String region) => teamCounts[region] ?? 0;

  @override
  List<Object?> get props => [regions, teamCounts, saving, working];
}

class LoadingManageRegionsState extends ManageRegionsState {
  const LoadingManageRegionsState({super.regions, super.teamCounts});
}

class SuccessManageRegionsState extends ManageRegionsState {
  const SuccessManageRegionsState({required super.regions, required super.teamCounts, super.saving, super.working});
}

/// Falha de leitura ou de gravação.
class ErrorManageRegionsState extends ManageRegionsState {
  final String errorMessage;

  const ErrorManageRegionsState({required this.errorMessage, super.regions, super.teamCounts});

  @override
  List<Object?> get props => [...super.props, errorMessage];
}

/// Nome recusado (curto ou repetido): a tela mostra no campo.
class InvalidNameManageRegionsState extends ManageRegionsState {
  final RegionNameError error;

  const InvalidNameManageRegionsState({required this.error, super.regions, super.teamCounts});

  @override
  List<Object?> get props => [...super.props, error];
}

/// Região criada.
class CreatedManageRegionsState extends ManageRegionsState {
  final String name;

  const CreatedManageRegionsState({required this.name, super.regions, super.teamCounts});

  @override
  List<Object?> get props => [...super.props, name];
}

/// Região renomeada ([previous] → [name]).
class RenamedManageRegionsState extends ManageRegionsState {
  final String previous;
  final String name;

  const RenamedManageRegionsState({required this.previous, required this.name, super.regions, super.teamCounts});

  @override
  List<Object?> get props => [...super.props, previous, name];
}

/// Conteúdo conferido antes de excluir: vazia ([usage] vazio) pede
/// confirmação; com conteúdo, a tela bloqueia e mostra a contagem.
class DeleteCheckedManageRegionsState extends ManageRegionsState {
  final String name;
  final RegionUsage usage;

  const DeleteCheckedManageRegionsState({required this.name, required this.usage, super.regions, super.teamCounts});

  @override
  List<Object?> get props => [...super.props, name, usage];
}

/// Tentou excluir a única região.
class LastRegionManageRegionsState extends ManageRegionsState {
  const LastRegionManageRegionsState({super.regions, super.teamCounts});
}

class DeletedManageRegionsState extends ManageRegionsState {
  final String name;

  const DeletedManageRegionsState({required this.name, super.regions, super.teamCounts});

  @override
  List<Object?> get props => [...super.props, name];
}

/// Fim da manutenção "Vincular regiões por id".
class LinkedManageRegionsState extends ManageRegionsState {
  final RegionLinkReport report;

  const LinkedManageRegionsState({required this.report, super.regions, super.teamCounts});

  @override
  List<Object?> get props => [...super.props, report];
}
