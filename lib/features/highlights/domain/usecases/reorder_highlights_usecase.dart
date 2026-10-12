import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/highlights/domain/repositories/highlights_repository_interface.dart';

/// Grava a ordem do carrossel (ids na ordem desejada).
class ReorderHighlightsUseCase {
  final IHighlightsRepository _repository;

  ReorderHighlightsUseCase(this._repository);

  Future<Either<Failure, void>> call(List<String> ids) => _repository.reorderHighlights(ids);
}
