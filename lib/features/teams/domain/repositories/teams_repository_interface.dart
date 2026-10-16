import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

abstract class ITeamsRepository {
  Future<Either<Failure, List<TeamDTO>>> getTeams({String? region, String? season});

  Future<Either<Failure, TeamDTO?>> getTeamByName(String name);

  Stream<Either<Failure, List<TeamDTO>>> watchTeams({String? region, String? season});

  Future<Either<Failure, int>> countTeams({String? season});

  Future<Either<Failure, void>> createTeam(TeamDTO team, {String? season});

  Future<Either<Failure, TeamDTO?>> getTeam({required String id, String? season});

  Future<Either<Failure, void>> updateTeamDetails({
    required String id,
    required String description,
    required String imageUrl,
    String primaryColor = '',
    String secondaryColor = '',
    String? region,
    String? season,
  });

  Future<Either<Failure, void>> deleteTeam(TeamDTO team, {String? season});

  /// Cache local dos times da [region] (nula = todas) na [season] (nula =
  /// atual). Nunca falha: sem cache = `Right(null)`.
  Future<Either<Failure, CachedValue<List<TeamDTO>>?>> getCachedTeams({String? region, String? season});

  Future<Either<Failure, void>> saveTeamsCache(List<TeamDTO> teams, {String? region, String? season});

  /// Cache local de um time pelo id (ou nome). `data` nulo = não achado.
  Future<Either<Failure, CachedValue<TeamDTO?>?>> getCachedTeam({required String idOrName, String? season});

  Future<Either<Failure, void>> saveTeamCache(TeamDTO? team, {required String idOrName, String? season});

  /// Apaga todo o cache de times (listas e avulsos).
  Future<void> deleteTeamsCache();
}
