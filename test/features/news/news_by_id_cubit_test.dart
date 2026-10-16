import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_cached_news_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_news_by_id_cache_first_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_news_by_id_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/save_news_cache_usecase.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_by_id_cubit.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_by_id_state.dart';

class _FakeGetNewsById implements GetNewsByIdUseCase {
  final Either<Failure, NewsDTO?> response;
  int calls = 0;

  _FakeGetNewsById(this.response);

  @override
  Future<Either<Failure, NewsDTO?>> call(String id) async {
    calls++;
    return response;
  }
}

/// Só o cache local (em memória; o real é o Hive).
class _FakeCache implements INewsRepository {
  final news = <String, CachedValue<NewsDTO?>>{};

  @override
  Future<Either<Failure, CachedValue<NewsDTO?>?>> getCachedNews(String id) async => Right(news[id]);

  @override
  Future<Either<Failure, void>> saveNewsCache(String id, NewsDTO? value) async {
    news[id] = CachedValue(value, DateTime.now());
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

NewsByIdCubit _cubit(_FakeGetNewsById remote, [_FakeCache? cache]) {
  final store = cache ?? _FakeCache();
  return NewsByIdCubit(GetNewsByIdCacheFirstUseCase(remote, GetCachedNewsUseCase(store), SaveNewsCacheUseCase(store)));
}

const _news = NewsDTO(id: 'n1', title: 'Final', description: '', imageUrl: '', region: 'Floresta');

void main() {
  test('notícia encontrada', () async {
    final cubit = _cubit(_FakeGetNewsById(const Right(_news)));
    await cubit.load('n1');
    expect(cubit.state, const SuccessNewsByIdState(_news));
    await cubit.close();
  });

  test('notícia apagada', () async {
    final cubit = _cubit(_FakeGetNewsById(const Right(null)));
    await cubit.load('n1');
    expect(cubit.state, isA<NotFoundNewsByIdState>());
    await cubit.close();
  });

  test('erro de carregamento', () async {
    final cubit = _cubit(_FakeGetNewsById(Left(ErrorWithMessage('falhou'))));
    await cubit.load('n1');
    expect(cubit.state, const ErrorNewsByIdState('falhou'));
    await cubit.close();
  });

  test('cache local válido: abre sem ler o Firestore', () async {
    final cache = _FakeCache()..news['n1'] = CachedValue(_news, DateTime.now());
    final remote = _FakeGetNewsById(const Right(null));
    final cubit = _cubit(remote, cache);
    await cubit.load('n1');
    expect(cubit.state, const SuccessNewsByIdState(_news));
    expect(remote.calls, 0);
    await cubit.close();
  });

  test('cache local vencido: mostra o cache e depois o Firestore', () async {
    final cache = _FakeCache()..news['n1'] = CachedValue(_news, DateTime.now().subtract(const Duration(hours: 1)));
    final edited = _news.copyWith(title: 'Final editada');
    final remote = _FakeGetNewsById(Right(edited));
    final cubit = _cubit(remote, cache);
    final states = <Object>[];
    final sub = cubit.stream.listen(states.add);
    await cubit.load('n1');
    await Future<void>.delayed(Duration.zero);
    expect(states, [const LoadingNewsByIdState(), const SuccessNewsByIdState(_news), SuccessNewsByIdState(edited)]);
    expect(remote.calls, 1);
    expect(cache.news['n1']!.data, edited);
    await sub.cancel();
    await cubit.close();
  });
}
