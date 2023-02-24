import 'package:arena_soccer/app/back/domain/entities/news.dart';
import 'package:arena_soccer/app/back/domain/errors/errors.dart';
import 'package:arena_soccer/app/back/domain/repositories/list_news_repository.dart';
import 'package:dartz/dartz.dart';

abstract class ListNews {
  Future<Either<FailureListNews, List<News>>> call(String fkCompeticao);
}

class ListNewsImpl implements ListNews {
  final ListNewsRepository repository;

  ListNewsImpl(this.repository);

  @override
  Future<Either<FailureListNews, List<News>>> call(String fkCompeticao) async {
    return repository.listNews(fkCompeticao);
  }
  
}