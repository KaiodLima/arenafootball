import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

abstract class INewsRepository {
  Stream<Either<Failure, List<NewsDTO>>> watchNews({String? region});

  Stream<Either<Failure, List<NewsDTO>>> watchNewsByTag(String tag);

  Future<Either<Failure, void>> createNews(NewsDTO news);

  Future<Either<Failure, void>> updateNews(NewsDTO news);

  Future<Either<Failure, void>> deleteNews(String id);

  Future<Either<Failure, List<NewsDTO>>> getGoalCardsByPlayer(String playerId);
}
