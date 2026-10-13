import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

abstract class IPlayersRepository {
  Stream<Either<Failure, List<PlayerDTO>>> watchTeamPlayers({String teamId = '', required String teamName, String? season});

  Future<Either<Failure, List<PlayerDTO>>> getPlayers({String? season});

  Stream<Either<Failure, PlayerDTO?>> watchPlayer({required String id, String? season});

  Future<Either<Failure, void>> createPlayer(PlayerDTO player, {String? season});

  Future<Either<Failure, void>> updatePlayer(PlayerDTO player, {String? season});

  Future<Either<Failure, void>> deletePlayer(PlayerDTO player, {String? season});

  Future<Either<Failure, void>> removeFromSquad(PlayerDTO player, {String? season});

  /// Soma gols/assistências ao jogador (atômico).
  Future<Either<Failure, void>> incrementStats({
    required String playerId,
    int goals = 0,
    int assists = 0,
    String? season,
  });
}
