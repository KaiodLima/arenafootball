import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_cached_region_matches_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_region_matches_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/save_region_matches_cache_usecase.dart';

/// Partidas da região na temporada pelo fluxo [cacheFirst] (validade
/// [CacheTtl.regionMatches]): mesma entrada do [GetRegionMatchesUseCase], mas
/// emite o cache na hora e só lê o Firestore com o cache vencido/ausente ou
/// [force]. Gravar uma partida apaga o cache (no repositório).
class GetRegionMatchesCacheFirstUseCase {
  final GetRegionMatchesUseCase _getMatches;
  final GetCachedRegionMatchesUseCase _getCached;
  final SaveRegionMatchesCacheUseCase _saveCache;

  GetRegionMatchesCacheFirstUseCase(this._getMatches, this._getCached, this._saveCache);

  Stream<Either<Failure, List<MatchDTO>>> call({required String region, String? season, bool force = false}) =>
      cacheFirst<List<MatchDTO>>(
        readCache: () => _getCached(region: region, season: season),
        fetchRemote: () => _getMatches(region: region, season: season),
        saveCache: (matches) => _saveCache(matches, region: region, season: season),
        ttl: CacheTtl.regionMatches,
        force: force,
        logName: 'GetRegionMatchesCacheFirstUseCase',
      );

  /// O valor mais novo numa leitura só (para quem junta com outras leituras):
  /// cache válido = na hora, sem ler; vencido = o do Firestore (ou o cache,
  /// se o remoto falhar).
  Future<Either<Failure, List<MatchDTO>>> latest({required String region, String? season, bool force = false}) =>
      call(region: region, season: season, force: force).last;
}
