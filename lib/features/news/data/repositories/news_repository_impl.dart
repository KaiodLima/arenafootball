import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/datasources/news_datasource.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';

class NewsRepositoryImpl implements INewsRepository {
  final NewsDataSource _dataSource;

  NewsRepositoryImpl(this._dataSource);

  @override
  Stream<Either<Failure, List<NewsDTO>>> watchNews({String? region}) => _dataSource.watchNews(region: region);

  @override
  Stream<Either<Failure, List<NewsDTO>>> watchNewsByTag(String tag) => _dataSource.watchNewsByTag(tag);

  @override
  Future<Either<Failure, NewsDTO?>> getNewsById(String id) => _dataSource.getNewsById(id);

  @override
  Future<Either<Failure, void>> createNews(NewsDTO news) => _dataSource.createNews(news);

  @override
  Future<Either<Failure, void>> updateNews(NewsDTO news) => _dataSource.updateNews(news);

  @override
  Future<Either<Failure, void>> deleteNews(String id) => _dataSource.deleteNews(id);

  @override
  Future<Either<Failure, List<NewsDTO>>> getGoalCardsByPlayer(String playerId) =>
      _dataSource.getGoalCardsByPlayer(playerId);
}
