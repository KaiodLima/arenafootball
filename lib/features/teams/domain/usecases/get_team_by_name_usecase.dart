import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';

class GetTeamByNameUseCase {
  final ITeamsRepository _repository;

  GetTeamByNameUseCase(this._repository);

  Future<Either<Failure, TeamDTO?>> call(String name) => _repository.getTeamByName(name);
}
