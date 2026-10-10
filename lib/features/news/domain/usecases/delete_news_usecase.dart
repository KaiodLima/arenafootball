import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

class DeleteNewsUseCase {
  final INewsRepository _repository;

  DeleteNewsUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) => _repository.deleteNews(id);
}
