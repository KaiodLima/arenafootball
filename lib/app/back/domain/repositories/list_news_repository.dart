import 'package:dartz/dartz.dart';
import 'package:arena_soccer/app/back/domain/entities/news.dart';
import 'package:arena_soccer/app/back/domain/errors/errors.dart';

abstract class ListNewsRepository {
  Future<Either<FailureListNews, List<News>>> listNews(String fkCompeticao);
}