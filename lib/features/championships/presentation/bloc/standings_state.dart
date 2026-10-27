import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';
import 'package:arena_soccer/features/championships/domain/standings_criterion.dart';

class StandingsState extends Equatable {
  final List<StandingDTO> standings;

  /// Tabela calculada pelas functions (`tabelas{ano}`); falso = a manual antiga.
  final bool automatic;

  /// Critérios de desempate usados na tabela calculada.
  final List<StandingsCriterion> criteria;

  const StandingsState({this.standings = const [], this.automatic = false, this.criteria = const []});

  @override
  List<Object?> get props => [standings, automatic, criteria];
}

class LoadingStandingsState extends StandingsState {
  const LoadingStandingsState({super.standings, super.automatic, super.criteria});
}

class SuccessStandingsState extends StandingsState {
  const SuccessStandingsState({required super.standings, super.automatic, super.criteria});
}

class ErrorStandingsState extends StandingsState {
  final String errorMessage;

  const ErrorStandingsState({required this.errorMessage, super.standings, super.automatic, super.criteria});

  @override
  List<Object?> get props => [standings, automatic, criteria, errorMessage];
}
