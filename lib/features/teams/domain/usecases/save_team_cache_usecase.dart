import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';

class SaveTeamCacheUseCase {
  final ITeamsRepository _repository;

  SaveTeamCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(TeamDTO? team, {required String idOrName, String? season}) =>
      _repository.saveTeamCache(team, idOrName: idOrName, season: season);
}
