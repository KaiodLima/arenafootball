import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/highlights/presentation/bloc/highlight_news_state.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/watch_news_by_tag_usecase.dart';

class HighlightNewsCubit extends Cubit<HighlightNewsState> {
  final WatchNewsByTagUseCase watchNewsByTagUseCase;
  StreamSubscription<Either<Failure, List<NewsDTO>>>? _subscription;

  HighlightNewsCubit(this.watchNewsByTagUseCase) : super(const LoadingHighlightNewsState());

  /// As notícias de um destaque são as que têm o título dele como tag.
  void watch({required String highlightTitle}) {
    _subscription?.cancel();
    emit(LoadingHighlightNewsState(news: state.news));
    _subscription = watchNewsByTagUseCase(highlightTitle).listen((response) {
      response.fold(
        (failure) => emit(ErrorHighlightNewsState(errorMessage: failure.toString(), news: state.news)),
        (news) => emit(SuccessHighlightNewsState(news: news)),
      );
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
