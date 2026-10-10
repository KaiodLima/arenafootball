import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';

abstract class IHighlightsRepository {
  Stream<Either<Failure, List<HighlightDTO>>> watchVisibleHighlights();

  Future<Either<Failure, List<HighlightDTO>>> getHighlights();

  Future<Either<Failure, void>> createHighlight(HighlightDTO highlight);
}
