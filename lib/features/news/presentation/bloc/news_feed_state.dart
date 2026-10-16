import 'package:equatable/equatable.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

/// [news] é a primeira página (ao vivo) seguida das páginas antigas já
/// carregadas. [hasMore]: ainda há páginas para buscar; [loadingMore]: uma
/// página antiga está sendo buscada.
class NewsFeedState extends Equatable {
  final List<NewsDTO> news;
  final bool hasMore;
  final bool loadingMore;

  const NewsFeedState({this.news = const [], this.hasMore = false, this.loadingMore = false});

  @override
  List<Object?> get props => [news, hasMore, loadingMore];
}

class LoadingNewsFeedState extends NewsFeedState {
  const LoadingNewsFeedState({super.news});
}

class SuccessNewsFeedState extends NewsFeedState {
  const SuccessNewsFeedState({required super.news, super.hasMore, super.loadingMore});
}

class ErrorNewsFeedState extends NewsFeedState {
  final String errorMessage;

  const ErrorNewsFeedState({required this.errorMessage, super.news, super.hasMore});

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
