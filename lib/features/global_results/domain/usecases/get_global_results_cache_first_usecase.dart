import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_match_dto.dart';
import 'package:arena_soccer/features/global_results/domain/entities/global_match.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_cached_global_results_usecase.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_global_results_usecase.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/save_global_results_cache_usecase.dart';

/// Resultados pelo mundo pelo fluxo [cacheFirst] (validade
/// [CacheTtl.globalResults]): o scraping é pesado, então o dia reaberto em
/// poucos minutos vem do aparelho. O cache guarda o HTML já extraído (cru) e
/// a interpretação ([GetGlobalResultsUseCase.toMatches]) roda na leitura.
class GetGlobalResultsCacheFirstUseCase {
  final GetGlobalResultsUseCase _getResults;
  final GetCachedGlobalResultsUseCase _getCached;
  final SaveGlobalResultsCacheUseCase _saveCache;

  GetGlobalResultsCacheFirstUseCase(this._getResults, this._getCached, this._saveCache);

  Stream<Either<Failure, List<GlobalMatch>>> call(ResultsDay day, {bool force = false}) =>
      cacheFirst<List<ScrapedMatchDTO>>(
        readCache: () => _getCached(day),
        fetchRemote: () => _getResults.scrape(day),
        saveCache: (matches) => _saveCache(day, matches),
        ttl: CacheTtl.globalResults,
        force: force,
        logName: 'GetGlobalResultsCacheFirstUseCase',
      ).map((response) => response.map((matches) => GetGlobalResultsUseCase.toMatches(matches, day)));
}
