import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/datasources/players_datasource.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

class PlayersRepositoryImpl implements IPlayersRepository {
  final PlayersDataSource _dataSource;

  PlayersRepositoryImpl(this._dataSource);

  @override
  Stream<Either<Failure, List<PlayerDTO>>> watchTeamPlayers({required String teamName, String? season}) =>
      _dataSource.watchTeamPlayers(teamName: teamName, season: season);

  @override
  Future<Either<Failure, List<PlayerDTO>>> getPlayers({String? season}) => _dataSource.getPlayers(season: season);

  @override
  Future<Either<Failure, void>> createPlayer(PlayerDTO player, {String? season}) =>
      _dataSource.createPlayer(player, season: season);

  @override
  Future<Either<Failure, void>> updatePlayer(PlayerDTO player, {String? season}) =>
      _dataSource.updatePlayer(player, season: season);
}
