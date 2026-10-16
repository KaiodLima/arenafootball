import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

/// Apaga o cache de cards de gol de todos os jogadores (gravar notícia já faz
/// isso no repositório).
class DeleteGoalCardsCacheUseCase {
  final INewsRepository _repository;

  DeleteGoalCardsCacheUseCase(this._repository);

  Future<void> call() => _repository.deleteGoalCardsCache();
}
