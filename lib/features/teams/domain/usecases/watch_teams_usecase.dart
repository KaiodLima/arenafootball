import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';

class WatchTeamsUseCase {
  final ITeamsRepository _repository;

  WatchTeamsUseCase(this._repository);

  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season}) =>
      _repository.watchTeams(region: region, season: season);
}
