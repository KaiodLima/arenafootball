import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// Admin exclui um jogador sem conta vinculada ([season] nulo = temporada corrente).
class DeletePlayerUseCase {
  final IPlayersRepository _repository;

  DeletePlayerUseCase(this._repository);

  Future<Either<Failure, void>> call(PlayerDTO player, {String? season}) =>
      _repository.deletePlayer(player, season: season);
}
