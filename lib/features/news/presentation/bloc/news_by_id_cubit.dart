import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_news_by_id_cache_first_usecase.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_by_id_state.dart';

/// Busca a notícia de um deep link (`/noticia/<id>`), do cache local quando
/// houver (ver `cacheFirst`).
class NewsByIdCubit extends Cubit<NewsByIdState> {
  final GetNewsByIdCacheFirstUseCase getNewsByIdCacheFirstUseCase;

  NewsByIdCubit(this.getNewsByIdCacheFirstUseCase) : super(const LoadingNewsByIdState());

  /// [force] (tentar de novo): ignora a validade do cache.
  Future<void> load(String id, {bool force = false}) async {
    emit(const LoadingNewsByIdState());
    await for (final response in getNewsByIdCacheFirstUseCase(id, force: force)) {
      if (isClosed) return;
      response.fold(
        (failure) => emit(ErrorNewsByIdState(failure.toString())),
        (news) => emit(news == null ? const NotFoundNewsByIdState() : SuccessNewsByIdState(news)),
      );
    }
  }
}
