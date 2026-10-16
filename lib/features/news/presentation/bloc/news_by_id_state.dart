import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

/// Notícia aberta por um link (só o id): carregando, achada, apagada ou erro.
sealed class NewsByIdState extends Equatable {
  const NewsByIdState();

  @override
  List<Object?> get props => [];
}

class LoadingNewsByIdState extends NewsByIdState {
  const LoadingNewsByIdState();
}

class SuccessNewsByIdState extends NewsByIdState {
  final NewsDTO news;

  const SuccessNewsByIdState(this.news);

  @override
  List<Object?> get props => [news];
}

class NotFoundNewsByIdState extends NewsByIdState {
  const NotFoundNewsByIdState();
}

class ErrorNewsByIdState extends NewsByIdState {
  final String errorMessage;

  const ErrorNewsByIdState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
