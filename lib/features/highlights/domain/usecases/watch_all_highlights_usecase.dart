import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/repositories/highlights_repository_interface.dart';

/// Todos os destaques (painel do admin), na ordem do carrossel.
class WatchAllHighlightsUseCase {
  final IHighlightsRepository _repository;

  WatchAllHighlightsUseCase(this._repository);

  Stream<Either<Failure, List<HighlightDTO>>> call() => _repository.watchAllHighlights();
}
