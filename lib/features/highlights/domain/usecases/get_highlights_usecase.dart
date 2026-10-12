import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/repositories/highlights_repository_interface.dart';

/// Todos os destaques cadastrados (visíveis ou não), na ordem do carrossel.
class GetHighlightsUseCase {
  final IHighlightsRepository _repository;

  GetHighlightsUseCase(this._repository);

  Future<Either<Failure, List<HighlightDTO>>> call() => _repository.getHighlights();
}
