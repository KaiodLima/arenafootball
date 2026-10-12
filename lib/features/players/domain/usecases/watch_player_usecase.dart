import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// Um jogador em tempo real (`null` se foi excluído).
class WatchPlayerUseCase {
  final IPlayersRepository _repository;

  WatchPlayerUseCase(this._repository);

  Stream<Either<Failure, PlayerDTO?>> call({required String id, String? season}) =>
      _repository.watchPlayer(id: id, season: season);
}
