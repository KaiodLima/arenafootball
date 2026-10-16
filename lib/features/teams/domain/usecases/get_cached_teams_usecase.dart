import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';

/// Times do cache local (nunca falha: sem cache = `Right(null)`).
class GetCachedTeamsUseCase {
  final ITeamsRepository _repository;

  GetCachedTeamsUseCase(this._repository);

  Future<Either<Failure, CachedValue<List<TeamDTO>>?>> call({String? region, String? season}) =>
      _repository.getCachedTeams(region: region, season: season);
}
