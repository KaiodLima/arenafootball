import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';

class GetTeamsUseCase {
  final ITeamsRepository _repository;

  GetTeamsUseCase(this._repository);

  Future<Either<Failure, List<TeamDTO>>> call({String? region, String? season}) =>
      _repository.getTeams(region: region, season: season);
}
