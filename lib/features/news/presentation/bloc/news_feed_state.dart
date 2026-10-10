import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

class NewsFeedState extends Equatable {
  final List<NewsDTO> news;

  const NewsFeedState({this.news = const []});

  @override
  List<Object?> get props => [news];
}

class LoadingNewsFeedState extends NewsFeedState {
  const LoadingNewsFeedState({super.news});
}

class SuccessNewsFeedState extends NewsFeedState {
  const SuccessNewsFeedState({required super.news});
}

class ErrorNewsFeedState extends NewsFeedState {
  final String errorMessage;

  const ErrorNewsFeedState({required this.errorMessage, super.news});

  @override
  List<Object?> get props => [news, errorMessage];
}
