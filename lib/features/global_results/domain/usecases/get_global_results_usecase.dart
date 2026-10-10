import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_row_dto.dart';
import 'package:arena_soccer/features/global_results/domain/entities/global_match.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';
import 'package:arena_soccer/features/global_results/domain/repositories/global_results_repository_interface.dart';

class GetGlobalResultsUseCase {
  final IGlobalResultsRepository _repository;

  GetGlobalResultsUseCase(this._repository);

  Future<Either<Failure, List<GlobalMatch>>> call(ResultsDay day) async {
    final response = await _repository.getRows(day);
    return response.map((rows) => _toMatches(rows, day));
  }

  List<GlobalMatch> _toMatches(List<ScrapedRowDTO> rows, ResultsDay day) {
    switch (day) {
      case ResultsDay.today:
        // A página inicial do site lista cada jogo duas vezes: só a primeira metade vale.
        return rows
            .take((rows.length / 2).ceil())
            .map(
              (row) => GlobalMatch(
                league: row.league,
                time: row.time,
                homeTeam: row.home,
                awayTeam: row.away,
                score: row.score,
                scorers: row.scorers,
              ),
            )
            .toList();
      case ResultsDay.yesterday:
        // Cada time vem numa linha própria: junta os pares (casa, fora).
        final matches = <GlobalMatch>[];
        for (var i = 0; i + 1 < rows.length; i += 2) {
          final home = rows[i];
          final away = rows[i + 1];
          matches.add(
            GlobalMatch(
              league: home.league,
              time: '',
              homeTeam: home.home,
              awayTeam: away.home,
              score: '${home.score} x ${away.score}',
            ),
          );
        }
        return matches;
      case ResultsDay.tomorrow:
        // A página de amanhã ainda não é interpretada (o app antigo também não exibia nada).
        return const [];
    }
  }
}
