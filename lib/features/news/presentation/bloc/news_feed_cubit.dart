import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/delete_news_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/watch_news_feed_usecase.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_feed_state.dart';

class NewsFeedCubit extends Cubit<NewsFeedState> {
  final WatchNewsFeedUseCase watchNewsFeedUseCase;
  final DeleteNewsUseCase deleteNewsUseCase;
  StreamSubscription<Either<Failure, List<NewsDTO>>>? _subscription;

  NewsFeedCubit(this.watchNewsFeedUseCase, this.deleteNewsUseCase) : super(const LoadingNewsFeedState());

  void watch({required String region}) {
    _subscription?.cancel();
    emit(LoadingNewsFeedState(news: state.news));
    _subscription = watchNewsFeedUseCase(region: region).listen((response) {
      response.fold(
        (failure) => emit(ErrorNewsFeedState(errorMessage: failure.toString(), news: state.news)),
        (news) => emit(SuccessNewsFeedState(news: news)),
      );
    });
  }

  /// O stream do feed atualiza a lista sozinho após a exclusão.
  Future<void> delete(String id) async {
    final response = await deleteNewsUseCase(id);
    if (response.isLeft) {
      emit(ErrorNewsFeedState(errorMessage: response.left.toString(), news: state.news));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
