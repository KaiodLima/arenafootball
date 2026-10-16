import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/seasons/data/datasources/seasons_datasource.dart';
import 'package:arena_soccer/features/seasons/data/dtos/seasons_config_dto.dart';
import 'package:arena_soccer/features/seasons/domain/repositories/seasons_repository_interface.dart';
import 'package:arena_soccer/features/seasons/domain/team_links.dart';

class SeasonsRepositoryImpl implements ISeasonsRepository {
  final SeasonsDataSource _dataSource;
  final CacheStore _cache;

  SeasonsRepositoryImpl(this._dataSource, this._cache);

  @override
  Future<Either<Failure, SeasonsConfigDTO?>> getConfig() => _dataSource.getConfig();

  @override
  Future<Either<Failure, CachedValue<SeasonsConfigDTO>?>> getCachedConfig() => _cache.read(
        CacheKeys.seasonsConfig,
        (json) => SeasonsConfigDTO.fromCache(Map<String, dynamic>.from(json as Map)),
      );

  @override
  Future<Either<Failure, void>> saveConfigCache(SeasonsConfigDTO config) =>
      _cache.save(CacheKeys.seasonsConfig, config.toCache());

  @override
  Future<Either<Failure, void>> deleteConfigCache() => _cache.delete(CacheKeys.seasonsConfig);

  /// Temporada nova: a config e os times em cache ficam velhos.
  @override
  Future<Either<Failure, SeasonsConfigDTO>> startSeason({
    required String season,
    required List<String> seasons,
    String? copyTeamsFrom,
  }) async {
    final response = await _dataSource.startSeason(season: season, seasons: seasons, copyTeamsFrom: copyTeamsFrom);
    if (response.isRight) {
      await deleteConfigCache();
      await _cache.deleteWhere(CacheKeys.isTeamKey);
    }
    return response;
  }

  /// Completa os ids dos times: o cache de times fica velho.
  @override
  Future<Either<Failure, TeamLinkReport>> linkTeams(String season) async {
    final response = await _dataSource.linkTeams(season);
    if (response.isRight) await _cache.deleteWhere(CacheKeys.isTeamKey);
    return response;
  }
}
