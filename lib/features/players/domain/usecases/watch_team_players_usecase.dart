import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

class WatchTeamPlayersUseCase {
  final IPlayersRepository _repository;

  WatchTeamPlayersUseCase(this._repository);

  Stream<Either<Failure, List<PlayerDTO>>> call({required String teamName, String? season}) =>
      _repository.watchTeamPlayers(teamName: teamName, season: season);
}
