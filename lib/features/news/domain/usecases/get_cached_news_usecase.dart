import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

/// Notícia do cache local (nunca falha: sem cache = `Right(null)`).
class GetCachedNewsUseCase {
  final INewsRepository _repository;

  GetCachedNewsUseCase(this._repository);

  Future<Either<Failure, CachedValue<NewsDTO?>?>> call(String id) => _repository.getCachedNews(id);
}
