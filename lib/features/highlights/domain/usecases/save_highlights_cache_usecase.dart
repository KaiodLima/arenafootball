import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/repositories/highlights_repository_interface.dart';

class SaveHighlightsCacheUseCase {
  final IHighlightsRepository _repository;

  SaveHighlightsCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(List<HighlightDTO> highlights) => _repository.saveHighlightsCache(highlights);
}
