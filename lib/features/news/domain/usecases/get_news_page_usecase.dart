import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/domain/news_feed_page.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

/// Página mais antiga do feed (leitura única), depois da notícia
/// [afterNewsId], já filtrada para exibição.
class GetNewsPageUseCase {
  final INewsRepository _repository;

  GetNewsPageUseCase(this._repository);

  Future<Either<Failure, NewsFeedPage>> call({
    String? region,
    required String afterNewsId,
    int limit = newsFeedPageSize,
  }) async {
    final response = await _repository.getNewsPage(region: region, afterNewsId: afterNewsId, limit: limit);
    return response.map((raw) => NewsFeedPage.fromRaw(raw, limit: limit));
  }
}
