import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

class SaveNewsCacheUseCase {
  final INewsRepository _repository;

  SaveNewsCacheUseCase(this._repository);

  Future<Either<Failure, void>> call(String id, NewsDTO? news) => _repository.saveNewsCache(id, news);
}
