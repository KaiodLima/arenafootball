import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/global_results/domain/entities/global_match.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';

class GlobalResultsState extends Equatable {
  final ResultsDay day;
  final List<GlobalMatch> matches;

  const GlobalResultsState({this.day = ResultsDay.today, this.matches = const []});

  @override
  List<Object?> get props => [day, matches];
}

class LoadingGlobalResultsState extends GlobalResultsState {
  const LoadingGlobalResultsState({super.day});
}

class SuccessGlobalResultsState extends GlobalResultsState {
  const SuccessGlobalResultsState({required super.day, required super.matches});
}

class ErrorGlobalResultsState extends GlobalResultsState {
  final String errorMessage;

  const ErrorGlobalResultsState({required super.day, required this.errorMessage});

  @override
  List<Object?> get props => [day, matches, errorMessage];
}
