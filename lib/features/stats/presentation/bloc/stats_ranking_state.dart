import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

class StatsRankingState extends Equatable {
  /// Jogadores já filtrados e ordenados pelo UseCase.
  final List<PlayerDTO> players;

  const StatsRankingState({this.players = const []});

  @override
  List<Object?> get props => [players];
}

class LoadingStatsRankingState extends StatsRankingState {
  const LoadingStatsRankingState({super.players});
}

class SuccessStatsRankingState extends StatsRankingState {
  const SuccessStatsRankingState({required super.players});
}

class ErrorStatsRankingState extends StatsRankingState {
  final String errorMessage;

  const ErrorStatsRankingState({required this.errorMessage, super.players});

  @override
  List<Object?> get props => [players, errorMessage];
}
