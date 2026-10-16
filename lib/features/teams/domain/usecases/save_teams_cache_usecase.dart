import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';

class SaveTeamsCacheUseCase {
  final ITeamsRepository _repository;

  SaveTeamsCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(List<TeamDTO> teams, {String? region, String? season}) =>
      _repository.saveTeamsCache(teams, region: region, season: season);
}
