import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';

class StatsRankingState extends Equatable {
  /// Quesito exibido (o seletor da tela troca na hora; os dados chegam depois).
  final StatsRankingType type;

  /// Entradas já ordenadas e com posição, vindas do UseCase.
  final List<RankingEntry> entries;

  /// Escudos por nome do time.
  final Map<String, String> crests;

  const StatsRankingState({this.type = StatsRankingType.goals, this.entries = const [], this.crests = const {}});

  /// Até 3 primeiros com posição de pódio (com 4 empatados em 1º, o 4º vai
  /// para a lista, ainda como 1º).
  List<RankingEntry> get podium => entries.take(3).where((e) => e.position <= 3).toList();

  List<RankingEntry> get rest => entries.skip(podium.length).toList();

  String? crestOf(String teamName) => crests[teamName];

  @override
  List<Object?> get props => [type, entries, crests];
}

class LoadingStatsRankingState extends StatsRankingState {
  const LoadingStatsRankingState({super.type, super.entries, super.crests});
}

class SuccessStatsRankingState extends StatsRankingState {
  const SuccessStatsRankingState({required super.type, required super.entries, required super.crests});
}

class ErrorStatsRankingState extends StatsRankingState {
  final String errorMessage;

  const ErrorStatsRankingState({required this.errorMessage, super.type, super.entries, super.crests});

  @override
  List<Object?> get props => [type, entries, crests, errorMessage];
}
