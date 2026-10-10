import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';

class StandingsState extends Equatable {
  final List<StandingDTO> standings;

  const StandingsState({this.standings = const []});

  @override
  List<Object?> get props => [standings];
}

class LoadingStandingsState extends StandingsState {
  const LoadingStandingsState({super.standings});
}

class SuccessStandingsState extends StandingsState {
  const SuccessStandingsState({required super.standings});
}

class ErrorStandingsState extends StandingsState {
  final String errorMessage;

  const ErrorStandingsState({required this.errorMessage, super.standings});

  @override
  List<Object?> get props => [standings, errorMessage];
}
