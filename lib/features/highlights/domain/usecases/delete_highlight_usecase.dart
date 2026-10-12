import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/repositories/highlights_repository_interface.dart';

/// Exclui o destaque e desmarca as notícias dele.
class DeleteHighlightUseCase {
  final IHighlightsRepository _repository;

  DeleteHighlightUseCase(this._repository);

  Future<Either<Failure, void>> call(HighlightDTO highlight) => _repository.deleteHighlight(highlight);
}
