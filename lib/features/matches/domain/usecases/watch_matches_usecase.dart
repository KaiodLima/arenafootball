import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/matches_filter.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';

/// Partidas de um campeonato na temporada, das mais recentes para as mais
/// antigas. Com [MatchesFilter.today], só as do dia: a data da partida é texto
/// "dd/MM" e é comparada com a data de hoje no mesmo formato.
class WatchMatchesUseCase {
  final IMatchesRepository _repository;

  WatchMatchesUseCase(this._repository);

  /// Data no formato gravado nas partidas ("dd/MM", com zero à esquerda).
  static String formatMatchDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';

  Stream<Either<Failure, List<MatchDTO>>> call({
    required int championshipId,
    required MatchesFilter filter,
    String? season,
    DateTime? now,
  }) {
    final today = formatMatchDate(now ?? DateTime.now());
    return _repository.watchMatches(season: season).map(
          (response) => response.map(
            (matches) => matches
                .where((match) => match.championshipId == championshipId)
                .where((match) => filter == MatchesFilter.all || match.date == today)
                .toList(),
          ),
        );
  }
}
