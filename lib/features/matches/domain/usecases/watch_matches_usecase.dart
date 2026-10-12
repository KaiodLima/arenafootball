import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/matches_filter.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';

/// Partidas de um campeonato na temporada, das mais recentes para as mais
/// antigas. Com ontem/hoje/amanhã ([MatchesFilter.dayOffset]), só as daquele
/// dia: a data da partida é texto "dd/MM" e é comparada com o dia no mesmo formato.
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
    final offset = filter.dayOffset;
    final base = now ?? DateTime.now();
    // Construtor com dia somado (não Duration): atravessa mês/ano e horário de verão.
    final day = offset == null ? null : formatMatchDate(DateTime(base.year, base.month, base.day + offset));
    return _repository.watchMatches(season: season).map(
          (response) => response.map(
            (matches) => matches
                .where((match) => match.championshipId == championshipId)
                .where((match) => day == null || match.date == day)
                .toList(),
          ),
        );
  }
}
