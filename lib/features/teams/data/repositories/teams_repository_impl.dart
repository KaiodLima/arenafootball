import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/data/datasources/teams_datasource.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';

class TeamsRepositoryImpl implements ITeamsRepository {
  final TeamsDataSource _dataSource;
  final CacheStore _cache;

  TeamsRepositoryImpl(this._dataSource, this._cache);

  @override
  Future<Either<Failure, List<TeamDTO>>> getTeams({String? region, String? season}) =>
      _dataSource.getTeams(region: region, season: season);

  @override
  Future<Either<Failure, TeamDTO?>> getTeamByName(String name) => _dataSource.getTeamByName(name);

  @override
  Stream<Either<Failure, List<TeamDTO>>> watchTeams({String? region, String? season}) =>
      _dataSource.watchTeams(region: region, season: season);

  @override
  Future<Either<Failure, int>> countTeams({String? season}) => _dataSource.countTeams(season: season);

  @override
  Future<Either<Failure, void>> createTeam(TeamDTO team, {String? season}) async =>
      _invalidate(await _dataSource.createTeam(team, season: season));

  @override
  Future<Either<Failure, TeamDTO?>> getTeam({required String id, String? season}) =>
      _dataSource.getTeam(id: id, season: season);

  @override
  Future<Either<Failure, void>> updateTeamDetails({
    required String id,
    required String description,
    required String imageUrl,
    String primaryColor = '',
    String secondaryColor = '',
    String? region,
    String? season,
  }) async =>
      _invalidate(await _dataSource.updateTeamDetails(
        id: id,
        description: description,
        imageUrl: imageUrl,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        region: region,
        season: season,
      ));

  @override
  Future<Either<Failure, void>> deleteTeam(TeamDTO team, {String? season}) async =>
      _invalidate(await _dataSource.deleteTeam(team, season: season));

  @override
  Future<Either<Failure, CachedValue<List<TeamDTO>>?>> getCachedTeams({String? region, String? season}) => _cache.read(
        CacheKeys.teams(region: region, season: season),
        (json) => [for (final item in json as List) TeamDTO.fromCache(Map<String, dynamic>.from(item as Map))],
      );

  @override
  Future<Either<Failure, void>> saveTeamsCache(List<TeamDTO> teams, {String? region, String? season}) =>
      _cache.save(CacheKeys.teams(region: region, season: season), [for (final team in teams) team.toCache()]);

  @override
  Future<Either<Failure, CachedValue<TeamDTO?>?>> getCachedTeam({required String idOrName, String? season}) =>
      _cache.read(
        CacheKeys.team(idOrName: idOrName, season: season),
        (json) => json == null ? null : TeamDTO.fromCache(Map<String, dynamic>.from(json as Map)),
      );

  @override
  Future<Either<Failure, void>> saveTeamCache(TeamDTO? team, {required String idOrName, String? season}) =>
      _cache.save(CacheKeys.team(idOrName: idOrName, season: season), team?.toCache());

  @override
  Future<void> deleteTeamsCache() => _cache.deleteWhere(CacheKeys.isTeamKey);

  /// Depois de gravar um time: o cache de times fica velho.
  Future<Either<Failure, void>> _invalidate(Either<Failure, void> response) async {
    if (response.isRight) await deleteTeamsCache();
    return response;
  }
}
