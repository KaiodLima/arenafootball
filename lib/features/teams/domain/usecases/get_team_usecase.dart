import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';

/// Time pelo id na temporada atual (nulo se não existir).
class GetTeamUseCase {
  final ITeamsRepository _repository;

  GetTeamUseCase(this._repository);

  Future<Either<Failure, TeamDTO?>> call(String id) => _repository.getTeam(id: id);
}
