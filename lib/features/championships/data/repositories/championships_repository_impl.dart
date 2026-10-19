import 'package:either_dart/either.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/datasources/championships_datasource.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/group_dto.dart';
import 'package:arena_soccer/features/championships/data/dtos/standing_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';

class ChampionshipsRepositoryImpl implements IChampionshipsRepository {
  final ChampionshipsDataSource _dataSource;
  final CacheStore _cache;

  ChampionshipsRepositoryImpl(this._dataSource, this._cache);

  @override
  Stream<Either<Failure, List<ChampionshipDTO>>> watchChampionships({String? region}) =>
      _dataSource.watchChampionships(region: region);

  @override
  Stream<Either<Failure, List<GroupDTO>>> watchGroups({required String region, String? season}) =>
      _dataSource.watchGroups(region: region, season: season);

  @override
  Stream<Either<Failure, List<StandingDTO>>> watchStandings({
    required String region,
    required String group,
    String? season,
  }) =>
      _dataSource.watchStandings(region: region, group: group, season: season);

  @override
  Future<Either<Failure, ChampionshipDTO>> createChampionship(ChampionshipDTO championship) async =>
      _invalidate(await _dataSource.createChampionship(championship));

  @override
  Future<Either<Failure, ChampionshipDTO>> updateChampionship(ChampionshipDTO championship) async =>
      _invalidate(await _dataSource.updateChampionship(championship));

  @override
  Future<Either<Failure, void>> deleteChampionship(String id) async =>
      _invalidate(await _dataSource.deleteChampionship(id));

  @override
  Future<Either<Failure, List<ChampionshipDTO>>> getSeasonChampionships(String season) =>
      _dataSource.getSeasonChampionships(season);

  @override
  Future<Either<Failure, ChampionshipDTO>> setTeamEnrollment({
    required String championshipDocId,
    required TeamDTO team,
    required bool enrolled,
  }) async =>
      _invalidate(
          await _dataSource.setTeamEnrollment(championshipDocId: championshipDocId, team: team, enrolled: enrolled));

  @override
  Future<Either<Failure, ChampionshipDTO?>> getChampionshipForRegion({
    required String region,
    required String season,
  }) =>
      _dataSource.getChampionshipForRegion(region: region, season: season);

  @override
  Future<Either<Failure, List<ChampionshipDTO>>> getRegionChampionships({
    required String region,
    required String season,
  }) =>
      _dataSource.getRegionChampionships(region: region, season: season);

  @override
  Future<Either<Failure, CachedValue<List<ChampionshipDTO>>?>> getCachedRegionChampionships({
    required String region,
    required String season,
  }) =>
      _cache.read(
        CacheKeys.championships(region: region, season: season),
        (json) => [for (final item in json as List) ChampionshipDTO.fromCache(Map<String, dynamic>.from(item as Map))],
      );

  @override
  Future<Either<Failure, void>> saveRegionChampionshipsCache(
    List<ChampionshipDTO> championships, {
    required String region,
    required String season,
  }) =>
      _cache.save(
        CacheKeys.championships(region: region, season: season),
        [for (final championship in championships) championship.toCache()],
      );

  @override
  Future<Either<Failure, CachedValue<ChampionshipDTO?>?>> getCachedRegionChampionship({
    required String region,
    required String season,
  }) =>
      _cache.read(
        CacheKeys.championship(region: region, season: season),
        (json) => json == null ? null : ChampionshipDTO.fromCache(Map<String, dynamic>.from(json as Map)),
      );

  @override
  Future<Either<Failure, void>> saveRegionChampionshipCache(
    ChampionshipDTO? championship, {
    required String region,
    required String season,
  }) =>
      _cache.save(CacheKeys.championship(region: region, season: season), championship?.toCache());

  @override
  Future<void> deleteChampionshipsCache() => _cache.deleteWhere(CacheKeys.isChampionshipKey);

  /// Depois de gravar um campeonato: o cache de campeonatos fica velho.
  Future<Either<Failure, T>> _invalidate<T>(Either<Failure, T> response) async {
    if (response.isRight) await deleteChampionshipsCache();
    return response;
  }
}
