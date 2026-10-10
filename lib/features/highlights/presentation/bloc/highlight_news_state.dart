import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

/// Notícias ligadas a um destaque (tag == título do destaque).
class HighlightNewsState extends Equatable {
  final List<NewsDTO> news;

  const HighlightNewsState({this.news = const []});

  @override
  List<Object?> get props => [news];
}

class LoadingHighlightNewsState extends HighlightNewsState {
  const LoadingHighlightNewsState({super.news});
}

class SuccessHighlightNewsState extends HighlightNewsState {
  const SuccessHighlightNewsState({required super.news});
}

class ErrorHighlightNewsState extends HighlightNewsState {
  final String errorMessage;

  const ErrorHighlightNewsState({required this.errorMessage, super.news});

  @override
  List<Object?> get props => [news, errorMessage];
}
