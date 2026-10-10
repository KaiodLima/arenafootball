import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

class GetPlayersUseCase {
  final IPlayersRepository _repository;

  GetPlayersUseCase(this._repository);

  Future<Either<Failure, List<PlayerDTO>>> call({String? season}) => _repository.getPlayers(season: season);
}
