import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/get_cached_highlights_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/get_highlights_usecase.dart';
import 'package:arena_soccer/features/highlights/domain/usecases/save_highlights_cache_usecase.dart';

/// Todos os destaques pelo fluxo [cacheFirst] (validade [CacheTtl.highlights]).
/// O carrossel continua no stream do Firestore; isto é para as leituras únicas.
class GetHighlightsCacheFirstUseCase {
  final GetHighlightsUseCase _getHighlights;
  final GetCachedHighlightsUseCase _getCached;
  final SaveHighlightsCacheUseCase _saveCache;

  GetHighlightsCacheFirstUseCase(this._getHighlights, this._getCached, this._saveCache);

  Stream<Either<Failure, List<HighlightDTO>>> call({bool force = false}) => cacheFirst<List<HighlightDTO>>(
        readCache: _getCached.call,
        fetchRemote: _getHighlights.call,
        saveCache: _saveCache.call,
        ttl: CacheTtl.highlights,
        force: force,
        logName: 'GetHighlightsCacheFirstUseCase',
      );
}
