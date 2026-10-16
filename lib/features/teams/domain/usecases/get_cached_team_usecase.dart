import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';

/// Um time do cache local, pelo id (ou nome). Nunca falha.
class GetCachedTeamUseCase {
  final ITeamsRepository _repository;

  GetCachedTeamUseCase(this._repository);

  Future<Either<Failure, CachedValue<TeamDTO?>?>> call({required String idOrName, String? season}) =>
      _repository.getCachedTeam(idOrName: idOrName, season: season);
}
