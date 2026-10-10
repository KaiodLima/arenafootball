import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

class WatchNewsByTagUseCase {
  final INewsRepository _repository;

  WatchNewsByTagUseCase(this._repository);

  Stream<Either<Failure, List<NewsDTO>>> call(String tag) => _repository.watchNewsByTag(tag);
}
