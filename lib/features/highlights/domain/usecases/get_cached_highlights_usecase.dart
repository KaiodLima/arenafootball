import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/highlights/domain/repositories/highlights_repository_interface.dart';

/// Destaques do cache local (nunca falha: sem cache = `Right(null)`).
class GetCachedHighlightsUseCase {
  final IHighlightsRepository _repository;

  GetCachedHighlightsUseCase(this._repository);

  Future<Either<Failure, CachedValue<List<HighlightDTO>>?>> call() => _repository.getCachedHighlights();
}
