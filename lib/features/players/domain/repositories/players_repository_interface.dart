import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

abstract class IPlayersRepository {
  Stream<Either<Failure, List<PlayerDTO>>> watchTeamPlayers({required String teamName, String? season});

  Future<Either<Failure, List<PlayerDTO>>> getPlayers({String? season});

  Future<Either<Failure, void>> createPlayer(PlayerDTO player, {String? season});

  Future<Either<Failure, void>> updatePlayer(PlayerDTO player, {String? season});
}
