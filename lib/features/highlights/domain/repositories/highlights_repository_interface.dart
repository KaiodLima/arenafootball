import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';

abstract class IHighlightsRepository {
  Stream<Either<Failure, List<HighlightDTO>>> watchVisibleHighlights();

  Future<Either<Failure, List<HighlightDTO>>> getHighlights();

  Future<Either<Failure, void>> createHighlight(HighlightDTO highlight);

  Stream<Either<Failure, List<HighlightDTO>>> watchAllHighlights();

  Future<Either<Failure, void>> updateHighlight(HighlightDTO highlight, {String? oldTitle, String? newsAuthorId});

  Future<Either<Failure, void>> deleteHighlight(HighlightDTO highlight, {String? newsAuthorId});

  Future<Either<Failure, void>> reorderHighlights(List<String> ids);

  Future<Either<Failure, void>> setHighlightVisible({required String id, required bool visible});

  /// Cache local de todos os destaques. Nunca falha: sem cache = `Right(null)`.
  Future<Either<Failure, CachedValue<List<HighlightDTO>>?>> getCachedHighlights();

  Future<Either<Failure, void>> saveHighlightsCache(List<HighlightDTO> highlights);

  Future<void> deleteHighlightsCache();
}
