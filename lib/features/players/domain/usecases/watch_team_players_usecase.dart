import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

class WatchTeamPlayersUseCase {
  final IPlayersRepository _repository;

  WatchTeamPlayersUseCase(this._repository);

  /// Pelo id do time (com fallback no nome para jogadores antigos).
  Stream<Either<Failure, List<PlayerDTO>>> call({String teamId = '', required String teamName, String? season}) =>
      _repository.watchTeamPlayers(teamId: teamId, teamName: teamName, season: season);
}
