import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_region_matches_cache_first_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/watch_matches_usecase.dart';
import 'package:arena_soccer/features/matches/domain/match_time.dart';

/// Partidas de hoje de uma região na temporada (de todos os campeonatos),
/// ordenadas pelo horário. Leitura única sobre a mesma lista em cache das
/// partidas da região ([GetRegionMatchesCacheFirstUseCase]), filtrada no app.
class GetTodayMatchesUseCase {
  final GetRegionMatchesCacheFirstUseCase _regionMatches;

  GetTodayMatchesUseCase(this._regionMatches);

  Future<Either<Failure, List<MatchDTO>>> call({required String region, String? season, DateTime? now}) async {
    final today = WatchMatchesUseCase.formatMatchDate(MatchTime.today(now ?? DateTime.now()));
    final response = await _regionMatches.latest(region: region, season: season);
    return response.map(
      (matches) => matches.where((m) => m.date == today).toList()..sort((a, b) => a.time.compareTo(b.time)),
    );
  }
}
