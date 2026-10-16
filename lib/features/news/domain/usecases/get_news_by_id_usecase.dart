import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

/// Uma notícia pelo id (deep link). Nulo quando ela não existe mais.
class GetNewsByIdUseCase {
  final INewsRepository _repository;

  GetNewsByIdUseCase(this._repository);

  Future<Either<Failure, NewsDTO?>> call(String id) => _repository.getNewsById(id);
}
