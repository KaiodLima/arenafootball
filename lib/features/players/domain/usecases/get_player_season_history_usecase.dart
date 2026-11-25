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
    final rows = await Future.wait(
      seasons.map((season) async => (await this.season(userId: userId, season: season)).fold((_) => null, (s) => s)),
    );
    return Right(sortHistory(rows));
  }

  /// Uma temporada: o cadastro da conta nela e os troféus (nulo = sem
  /// cadastro). Falha ao ler o cadastro ou os troféus = `Left` (não vai para
  /// o cache).
  Future<Either<Failure, PlayerSeasonSummary?>> season({required String userId, required String season}) async {
    final player = await _players.getPlayerByUser(userId: userId, season: season);
    if (player.isLeft) return Left(player.left);
    final found = player.right;
    if (found == null) return const Right(null);
    final awards = await _matches.countElectedMatches(playerId: found.id, season: season);
    if (awards.isLeft) return Left(awards.left);
    return Right(PlayerSeasonSummary(season: season, player: found, awards: awards.right));
  }

  /// As temporadas com cadastro, a mais nova primeiro.
  static List<PlayerSeasonSummary> sortHistory(Iterable<PlayerSeasonSummary?> rows) =>
      rows.whereType<PlayerSeasonSummary>().toList()..sort((a, b) => b.season.compareTo(a.season));
}
