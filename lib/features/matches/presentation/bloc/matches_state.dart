import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';

class MatchesState extends Equatable {
  final List<MatchDTO> matches;

  const MatchesState({this.matches = const []});

  @override
  List<Object?> get props => [matches];
}

class LoadingMatchesState extends MatchesState {
  const LoadingMatchesState({super.matches});
}

class SuccessMatchesState extends MatchesState {
  const SuccessMatchesState({required super.matches});
}

class ErrorMatchesState extends MatchesState {
  final String errorMessage;

  const ErrorMatchesState({required this.errorMessage, super.matches});

  @override
  List<Object?> get props => [matches, errorMessage];
}
