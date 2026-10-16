import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

/// Apaga uma notícia do cache local (editar/apagar já faz isso no repositório).
class DeleteNewsCacheUseCase {
  final INewsRepository _repository;

  DeleteNewsCacheUseCase(this._repository);

  Future<void> call(String id) => _repository.deleteNewsCache(id);
}
