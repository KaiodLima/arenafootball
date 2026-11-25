import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/repositories/teams_repository_interface.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_cached_team_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/save_team_cache_usecase.dart';

/// Time pelo id na temporada atual (nulo se não existir).
class GetTeamUseCase {
  final ITeamsRepository _repository;

  GetTeamUseCase(this._repository);

  Future<Either<Failure, TeamDTO?>> call(String id) => _repository.getTeam(id: id);
}

/// Time da temporada atual pelo id pelo fluxo [cacheFirst] (validade
/// [CacheTtl.teams]), na mesma chave do [GetTeamByNameCacheFirstUseCase]
/// (`CacheKeys.team`). Gravar um time apaga (no repositório).
class GetTeamCacheFirstUseCase {
  final GetTeamUseCase _getTeam;
  final GetCachedTeamUseCase _getCached;
  final SaveTeamCacheUseCase _saveCache;

  GetTeamCacheFirstUseCase(this._getTeam, this._getCached, this._saveCache);

  Stream<Either<Failure, TeamDTO?>> call(String id, {bool force = false}) => cacheFirst<TeamDTO?>(
        readCache: () => _getCached(idOrName: id),
        fetchRemote: () => _getTeam(id),
        saveCache: (team) => _saveCache(team, idOrName: id),
        ttl: CacheTtl.teams,
        force: force,
        logName: 'GetTeamCacheFirstUseCase',
      );

  /// O valor mais novo numa leitura só.
  Future<Either<Failure, TeamDTO?>> latest(String id, {bool force = false}) => call(id, force: force).last;
}
