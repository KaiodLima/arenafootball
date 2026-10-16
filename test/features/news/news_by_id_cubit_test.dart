import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_news_by_id_usecase.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_by_id_cubit.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_by_id_state.dart';

class _FakeGetNewsById implements GetNewsByIdUseCase {
  final Either<Failure, NewsDTO?> response;

  _FakeGetNewsById(this.response);

  @override
  Future<Either<Failure, NewsDTO?>> call(String id) async => response;
}

const _news = NewsDTO(id: 'n1', title: 'Final', description: '', imageUrl: '', region: 'Floresta');

void main() {
  test('notícia encontrada', () async {
    final cubit = NewsByIdCubit(_FakeGetNewsById(const Right(_news)));
    await cubit.load('n1');
    expect(cubit.state, const SuccessNewsByIdState(_news));
    await cubit.close();
  });

  test('notícia apagada', () async {
    final cubit = NewsByIdCubit(_FakeGetNewsById(const Right(null)));
    await cubit.load('n1');
    expect(cubit.state, isA<NotFoundNewsByIdState>());
    await cubit.close();
  });

  test('erro de carregamento', () async {
    final cubit = NewsByIdCubit(_FakeGetNewsById(Left(ErrorWithMessage('falhou'))));
    await cubit.load('n1');
    expect(cubit.state, const ErrorNewsByIdState('falhou'));
    await cubit.close();
  });
}
