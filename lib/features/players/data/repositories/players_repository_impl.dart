import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/datasources/players_datasource.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

class PlayersRepositoryImpl implements IPlayersRepository {
  final PlayersDataSource _dataSource;
  final CacheStore _cache;

  PlayersRepositoryImpl(this._dataSource, this._cache);

  @override
  Stream<Either<Failure, List<PlayerDTO>>> watchTeamPlayers(
          {String teamId = '', required String teamName, String? season}) =>
      _dataSource.watchTeamPlayers(teamId: teamId, teamName: teamName, season: season);

  @override
  Stream<Either<Failure, PlayerDTO?>> watchPlayer({required String id, String? season}) =>
      _dataSource.watchPlayer(id: id, season: season);

  @override
  Future<Either<Failure, List<PlayerDTO>>> getPlayers({String? season}) => _dataSource.getPlayers(season: season);

  @override
  Future<Either<Failure, List<PlayerDTO>>> getTopPlayers({
    required List<String> teamIds,
    required String field,
    int limit = 50,
    String? season,
  }) =>
      _dataSource.getTopPlayers(teamIds: teamIds, field: field, limit: limit, season: season);

  @override
  Future<Either<Failure, void>> createPlayer(PlayerDTO player, {String? season}) async =>
      _invalidate(await _dataSource.createPlayer(player, season: season));

  @override
  Future<Either<Failure, void>> updatePlayer(PlayerDTO player, {String? season}) async =>
      _invalidate(await _dataSource.updatePlayer(player, season: season));

  @override
  Future<Either<Failure, void>> deletePlayer(PlayerDTO player, {String? season}) async =>
      _invalidate(await _dataSource.deletePlayer(player, season: season));

  @override
  Future<Either<Failure, void>> removeFromSquad(PlayerDTO player, {String? season}) async =>
      _invalidate(await _dataSource.removeFromSquad(player, season: season));

  @override
  Future<Either<Failure, void>> incrementStats({
    required String playerId,
    int goals = 0,
    int assists = 0,
    String? season,
  }) async =>
      _invalidate(await _dataSource.incrementStats(playerId: playerId, goals: goals, assists: assists, season: season));

  /// Depois de mexer num jogador (números, time, elenco): os rankings do
  /// cache local ficam velhos.
  Future<Either<Failure, void>> _invalidate(Either<Failure, void> response) async {
    if (response.isRight) await _cache.deleteWhere(CacheKeys.isRankingKey);
    return response;
  }
}
