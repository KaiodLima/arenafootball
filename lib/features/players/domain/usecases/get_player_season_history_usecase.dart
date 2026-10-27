import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/players/domain/player_season_summary.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// Histórico do atleta com conta vinculada: em cada temporada de [seasons], o
/// cadastro dele (pela conta) e quantas vezes foi o craque. Temporada sem
/// cadastro fica de fora; falha numa temporada só a tira da lista.
class GetPlayerSeasonHistoryUseCase {
  final IPlayersRepository _players;
  final IMatchesRepository _matches;

  GetPlayerSeasonHistoryUseCase(this._players, this._matches);

  Future<Either<Failure, List<PlayerSeasonSummary>>> call({
    required String userId,
    required List<String> seasons,
  }) async {
    if (userId.isEmpty) return const Right([]);
    final rows = await Future.wait(seasons.map((season) async {
      final player = await _players.getPlayerByUser(userId: userId, season: season);
      final found = player.fold((_) => null, (p) => p);
      if (found == null) return null;
      final awards = await _matches.countElectedMatches(playerId: found.id, season: season);
      return PlayerSeasonSummary(season: season, player: found, awards: awards.fold((_) => 0, (n) => n));
    }));
    final list = rows.whereType<PlayerSeasonSummary>().toList()..sort((a, b) => b.season.compareTo(a.season));
    return Right(list);
  }
}
