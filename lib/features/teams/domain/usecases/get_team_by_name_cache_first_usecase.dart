import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_cached_team_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_team_by_name_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/save_team_cache_usecase.dart';

/// Time da temporada atual pelo id (ou nome), pelo fluxo [cacheFirst]
/// (validade [CacheTtl.teams]). Ex.: time do coração no drawer e na
/// carteirinha, que aparecem na hora com o cache.
class GetTeamByNameCacheFirstUseCase {
  final GetTeamByNameUseCase _getTeamByName;
  final GetCachedTeamUseCase _getCached;
  final SaveTeamCacheUseCase _saveCache;

  GetTeamByNameCacheFirstUseCase(this._getTeamByName, this._getCached, this._saveCache);

  Stream<Either<Failure, TeamDTO?>> call(String name, {String id = '', bool force = false}) {
    final key = id.isNotEmpty ? id : name;
    return cacheFirst<TeamDTO?>(
      readCache: () => _getCached(idOrName: key),
      fetchRemote: () => _getTeamByName(name, id: id),
      saveCache: (team) => _saveCache(team, idOrName: key),
      ttl: CacheTtl.teams,
      force: force,
      logName: 'GetTeamByNameCacheFirstUseCase',
    );
  }
}
