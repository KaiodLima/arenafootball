import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/players/domain/usecases/get_player_awards_usecase.dart';

/// Troféus de craque do atleta na temporada, do cache local.
class GetCachedPlayerAwardsUseCase {
  final IMatchesRepository _matches;

  GetCachedPlayerAwardsUseCase(this._matches);

  Future<Either<Failure, CachedValue<List<MatchDTO>>?>> call({required String playerId, String? season}) =>
      _matches.getCachedElectedMatches(playerId: playerId, season: season);
}

class SavePlayerAwardsCacheUseCase {
  final IMatchesRepository _matches;

  SavePlayerAwardsCacheUseCase(this._matches);

  Future<Either<Failure, void>> call(List<MatchDTO> matches, {required String playerId, String? season}) =>
      _matches.saveElectedMatchesCache(matches, playerId: playerId, season: season);
}

/// Troféus de craque pelo fluxo [cacheFirst] (validade [CacheTtl.profileFor]:
/// a temporada atual 10 min, as passadas 24 h). O craque é gravado só pelas
/// functions (o app não grava), então vale só a validade.
class GetPlayerAwardsCacheFirstUseCase {
  final GetPlayerAwardsUseCase _getAwards;
  final GetCachedPlayerAwardsUseCase _getCached;
  final SavePlayerAwardsCacheUseCase _saveCache;

  GetPlayerAwardsCacheFirstUseCase(this._getAwards, this._getCached, this._saveCache);

  Stream<Either<Failure, List<MatchDTO>>> call({required String playerId, String? season, bool force = false}) =>
      cacheFirst<List<MatchDTO>>(
        readCache: () => _getCached(playerId: playerId, season: season),
        fetchRemote: () => _getAwards(playerId: playerId, season: season),
        saveCache: (matches) => _saveCache(matches, playerId: playerId, season: season),
        ttl: CacheTtl.profileFor(season),
        force: force,
        logName: 'GetPlayerAwardsCacheFirstUseCase',
      );
}
