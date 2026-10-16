import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// Os [limit] jogadores com mais gols/assistências ([field]) entre os times
/// [teamIds] (base da artilharia/assistências sem baixar todos os jogadores).
class GetTopPlayersUseCase {
  final IPlayersRepository _repository;

  GetTopPlayersUseCase(this._repository);

  Future<Either<Failure, List<PlayerDTO>>> call({
    required List<String> teamIds,
    required String field,
    int limit = 50,
    String? season,
  }) =>
      _repository.getTopPlayers(teamIds: teamIds, field: field, limit: limit, season: season);
}
