import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/team_key.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/match_day.dart';

class MatchesState extends Equatable {
  final List<MatchDTO> matches;

  /// Time escolhido no filtro (nome como gravado na partida); null = todos.
  final String? teamFilter;

  /// Escudos por nome normalizado do time ([normalizeTeamName]).
  final Map<String, String> crests;

  const MatchesState({this.matches = const [], this.teamFilter, this.crests = const {}});

  /// Partidas do recorte do filtro.
  List<MatchDTO> get visibleMatches => teamFilter == null
      ? matches
      : matches.where((m) => m.homeTeam.trim() == teamFilter || m.awayTeam.trim() == teamFilter).toList();

  List<MatchDay> get days => groupMatchesByDate(visibleMatches);

  MatchesSummary get summary => MatchesSummary.of(visibleMatches);

  /// Times que aparecem nas partidas, em ordem alfabética.
  List<String> get teams {
    final names = {
      for (final match in matches) ...[match.homeTeam.trim(), match.awayTeam.trim()],
    }..remove('');
    return names.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  String? crestOf(String teamName) => crests[normalizeTeamName(teamName)];

  @override
  List<Object?> get props => [matches, teamFilter, crests];
}

class LoadingMatchesState extends MatchesState {
  const LoadingMatchesState({super.matches, super.teamFilter, super.crests});
}

class SuccessMatchesState extends MatchesState {
  const SuccessMatchesState({required super.matches, super.teamFilter, super.crests});
}

class ErrorMatchesState extends MatchesState {
  final String errorMessage;

  const ErrorMatchesState({required this.errorMessage, super.matches, super.teamFilter, super.crests});

  @override
  List<Object?> get props => [matches, teamFilter, crests, errorMessage];
}
