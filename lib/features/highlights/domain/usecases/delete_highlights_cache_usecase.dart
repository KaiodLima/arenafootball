import 'package:arena_soccer/features/highlights/domain/repositories/highlights_repository_interface.dart';

/// Apaga o cache dos destaques (as gravações de destaque já fazem isso no
/// repositório).
class DeleteHighlightsCacheUseCase {
  final IHighlightsRepository _repository;

  DeleteHighlightsCacheUseCase(this._repository);

  Future<void> call() => _repository.deleteHighlightsCache();
}
