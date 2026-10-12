import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/highlights/domain/repositories/highlights_repository_interface.dart';

/// Mostra/oculta o destaque no carrossel.
class SetHighlightVisibleUseCase {
  final IHighlightsRepository _repository;

  SetHighlightVisibleUseCase(this._repository);

  Future<Either<Failure, void>> call({required String id, required bool visible}) =>
      _repository.setHighlightVisible(id: id, visible: visible);
}
