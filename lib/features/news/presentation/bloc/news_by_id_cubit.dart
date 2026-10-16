import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_news_by_id_usecase.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_by_id_state.dart';

/// Busca a notícia de um deep link (`/noticia/<id>`).
class NewsByIdCubit extends Cubit<NewsByIdState> {
  final GetNewsByIdUseCase getNewsByIdUseCase;

  NewsByIdCubit(this.getNewsByIdUseCase) : super(const LoadingNewsByIdState());

  Future<void> load(String id) async {
    emit(const LoadingNewsByIdState());
    final response = await getNewsByIdUseCase(id);
    if (isClosed) return;
    response.fold(
      (failure) => emit(ErrorNewsByIdState(failure.toString())),
      (news) => emit(news == null ? const NotFoundNewsByIdState() : SuccessNewsByIdState(news)),
    );
  }
}
