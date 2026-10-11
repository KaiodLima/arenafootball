import 'package:equatable/equatable.dart';
import 'package:arena_soccer/core/utils/search_text.dart';
import 'package:arena_soccer/features/global_results/domain/entities/global_match.dart';
import 'package:arena_soccer/features/global_results/domain/entities/league_group.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';

class GlobalResultsState extends Equatable {
  final ResultsDay day;
  final List<GlobalMatch> matches;

  /// Busca por time ou liga.
  final String query;

  /// Mostra só os jogos em andamento (inclui intervalo).
  final bool liveOnly;

  const GlobalResultsState({
    this.day = ResultsDay.today,
    this.matches = const [],
    this.query = '',
    this.liveOnly = false,
  });

  int get liveCount => matches.where((m) => m.isLive).length;

  /// Partidas do recorte (busca sem diferenciar acento/caixa + ao vivo),
  /// agrupadas por liga na ordem do site.
  List<LeagueGroup> get groups {
    final term = foldForSearch(query.trim());
    bool matchesQuery(GlobalMatch m) =>
        term.isEmpty ||
        foldForSearch(m.homeTeam).contains(term) ||
        foldForSearch(m.awayTeam).contains(term) ||
        foldForSearch(m.league).contains(term);
    return LeagueGroup.of(matches.where((m) => (!liveOnly || m.isLive) && matchesQuery(m)).toList());
  }

  @override
  List<Object?> get props => [day, matches, query, liveOnly];
}

class LoadingGlobalResultsState extends GlobalResultsState {
  const LoadingGlobalResultsState({super.day, super.query});
}

class SuccessGlobalResultsState extends GlobalResultsState {
  const SuccessGlobalResultsState({required super.day, required super.matches, super.query, super.liveOnly});
}

class ErrorGlobalResultsState extends GlobalResultsState {
  final String errorMessage;

  const ErrorGlobalResultsState({required super.day, required this.errorMessage, super.matches, super.query, super.liveOnly});

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
