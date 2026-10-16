import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_cached_teams_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/save_teams_cache_usecase.dart';

/// Times pelo fluxo [cacheFirst] (validade [CacheTtl.teams]): mesma entrada
/// do [GetTeamsUseCase], mas emite o cache na hora e só lê o Firestore com o
/// cache vencido/ausente ou [force] (puxar para atualizar, depois de gravar).
class GetTeamsCacheFirstUseCase {
  final GetTeamsUseCase _getTeams;
  final GetCachedTeamsUseCase _getCached;
  final SaveTeamsCacheUseCase _saveCache;

  GetTeamsCacheFirstUseCase(this._getTeams, this._getCached, this._saveCache);

  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) =>
      cacheFirst<List<TeamDTO>>(
        readCache: () => _getCached(region: region, season: season),
        fetchRemote: () => _getTeams(region: region, season: season),
        saveCache: (teams) => _saveCache(teams, region: region, season: season),
        ttl: CacheTtl.teams,
        force: force,
        logName: 'GetTeamsCacheFirstUseCase',
      );
}
