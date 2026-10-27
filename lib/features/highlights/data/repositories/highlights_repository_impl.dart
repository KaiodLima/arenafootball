import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/highlights/data/datasources/highlights_datasource.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/repositories/highlights_repository_interface.dart';

class HighlightsRepositoryImpl implements IHighlightsRepository {
  final HighlightsDataSource _dataSource;
  final CacheStore _cache;

  HighlightsRepositoryImpl(this._dataSource, this._cache);

  @override
  Stream<Either<Failure, List<HighlightDTO>>> watchVisibleHighlights() => _dataSource.watchVisibleHighlights();

  @override
  Future<Either<Failure, List<HighlightDTO>>> getHighlights() => _dataSource.getHighlights();

  @override
  Future<Either<Failure, void>> createHighlight(HighlightDTO highlight) async =>
      _invalidate(await _dataSource.createHighlight(highlight));

  @override
  Stream<Either<Failure, List<HighlightDTO>>> watchAllHighlights() => _dataSource.watchAllHighlights();

  @override
  Future<Either<Failure, void>> updateHighlight(HighlightDTO highlight, {String? oldTitle, String? newsAuthorId}) async =>
      _invalidate(await _dataSource.updateHighlight(highlight, oldTitle: oldTitle, newsAuthorId: newsAuthorId));

  @override
  Future<Either<Failure, void>> deleteHighlight(HighlightDTO highlight, {String? newsAuthorId}) async =>
      _invalidate(await _dataSource.deleteHighlight(highlight, newsAuthorId: newsAuthorId));

  @override
  Future<Either<Failure, void>> reorderHighlights(List<String> ids) async =>
      _invalidate(await _dataSource.reorderHighlights(ids));

  @override
  Future<Either<Failure, void>> setHighlightVisible({required String id, required bool visible}) async =>
      _invalidate(await _dataSource.setHighlightVisible(id: id, visible: visible));

  @override
  Future<Either<Failure, CachedValue<List<HighlightDTO>>?>> getCachedHighlights() => _cache.read(
        CacheKeys.highlights,
        (json) => [for (final item in json as List) HighlightDTO.fromCache(Map<String, dynamic>.from(item as Map))],
      );

  @override
  Future<Either<Failure, void>> saveHighlightsCache(List<HighlightDTO> highlights) =>
      _cache.save(CacheKeys.highlights, [for (final highlight in highlights) highlight.toCache()]);

  @override
  Future<void> deleteHighlightsCache() async {
    await _cache.delete(CacheKeys.highlights);
  }

  /// Depois de gravar um destaque: o cache dos destaques fica velho.
  Future<Either<Failure, void>> _invalidate(Either<Failure, void> response) async {
    if (response.isRight) await deleteHighlightsCache();
    return response;
  }
}
