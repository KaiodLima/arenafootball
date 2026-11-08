import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';

/// Times pelos ids (e pelos nomes, para os sem id), de qualquer região.
class GetTeamsByIdsUseCase {
  final ITeamsRepository _repository;

  GetTeamsByIdsUseCase(this._repository);

  Future<Either<Failure, List<TeamDTO>>> call({required List<String> ids, List<String> names = const [], String? season}) =>
      _repository.getTeamsByIds(ids: ids, names: names, season: season);
}
