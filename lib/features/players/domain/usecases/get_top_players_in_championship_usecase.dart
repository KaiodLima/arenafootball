import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';

/// Os [limit] atletas com mais [field] (`PlayerDTO.goalsField`/`assistsField`)
/// na competição [championshipId], pelos números da inscrição.
class GetTopPlayersInChampionshipUseCase {
  final IPlayersRepository _repository;

  GetTopPlayersInChampionshipUseCase(this._repository);

  Future<Either<Failure, List<PlayerDTO>>> call({
    required int championshipId,
    required String field,
    int limit = 50,
    String? season,
  }) =>
      _repository.getTopPlayersInChampionship(
          championshipId: championshipId, field: field, limit: limit, season: season);
}
