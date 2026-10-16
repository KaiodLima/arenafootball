import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/news_feed_page.dart';
import 'package:arena_soccer/features/news/domain/repositories/news_repository_interface.dart';
import 'package:arena_soccer/features/news/domain/usecases/delete_news_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_news_page_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/watch_news_feed_usecase.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_feed_cubit.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_feed_state.dart';

/// Notícia [i] do feed: quanto maior o índice, mais antiga.
NewsDTO _news(int i) =>
    NewsDTO(id: 'n$i', title: 'Notícia $i', date: DateTime(2026, 1, 1).subtract(Duration(hours: i)));

List<NewsDTO> _range(int from, int to) => [for (var i = from; i < to; i++) _news(i)];

/// Repositório falso: o feed ao vivo é um controller por região e as páginas
/// antigas saem de [all] a partir do cursor.
class _FakeRepository implements INewsRepository {
  final Map<String, StreamController<Either<Failure, List<NewsDTO>>>> feeds = {};
  final List<String> watched = [];
  final List<String> pageCursors = [];
  List<NewsDTO> all = _range(0, 45);
  Failure? pageFailure;
  Completer<void>? pageGate;

  StreamController<Either<Failure, List<NewsDTO>>> feed(String region) =>
      feeds.putIfAbsent(region, StreamController<Either<Failure, List<NewsDTO>>>.broadcast);

  @override
  Stream<Either<Failure, List<NewsDTO>>> watchNews({String? region, int limit = 20}) {
    watched.add(region ?? '');
    return feed(region ?? '').stream;
  }

  @override
  Future<Either<Failure, List<NewsDTO>>> getNewsPage(
      {String? region, required String afterNewsId, int limit = 20}) async {
    pageCursors.add(afterNewsId);
    if (pageGate != null) await pageGate!.future;
    if (pageFailure != null) return Left(pageFailure!);
    final start = all.indexWhere((n) => n.id == afterNewsId) + 1;
    return Right(all.skip(start).take(limit).toList());
  }

  @override
  Future<Either<Failure, void>> deleteNews(String id) async => const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

List<String> _ids(NewsFeedState state) => state.news.map((n) => n.id).toList();

void main() {
  late _FakeRepository repository;
  late NewsFeedCubit cubit;

  setUp(() {
    repository = _FakeRepository();
    cubit = NewsFeedCubit(
      WatchNewsFeedUseCase(repository),
      GetNewsPageUseCase(repository),
      DeleteNewsUseCase(repository),
    );
  });

  tearDown(() => cubit.close());

  Future<void> emitFirstPage(String region, List<NewsDTO> news) async {
    repository.feed(region).add(Right(news));
    await Future<void>.delayed(Duration.zero);
  }

  test('primeira página vem do stream', () async {
    cubit.watch(region: 'Floresta');
    expect(cubit.state, isA<LoadingNewsFeedState>());
    await emitFirstPage('Floresta', _range(0, newsFeedPageSize));
    expect(cubit.state, isA<SuccessNewsFeedState>());
    expect(_ids(cubit.state), _ids(SuccessNewsFeedState(news: _range(0, 20))));
    expect(cubit.state.hasMore, isTrue);
  });

  test('loadMore junta a próxima página sem repetir e ignora chamadas simultâneas', () async {
    cubit.watch(region: 'Floresta');
    await emitFirstPage('Floresta', _range(0, 20));

    repository.pageGate = Completer<void>();
    final first = cubit.loadMore();
    expect(cubit.state.loadingMore, isTrue);
    await cubit.loadMore(); // ignorada: já há uma busca em andamento
    repository.pageGate!.complete();
    await first;

    expect(repository.pageCursors, ['n19']);
    expect(cubit.state.loadingMore, isFalse);
    expect(cubit.state.news.length, 40);
    expect(_ids(cubit.state).toSet().length, 40);
    expect(cubit.state.hasMore, isTrue);

    // Uma notícia nova empurra a n19 para fora da primeira página: ela
    // continua na lista, sem duplicar.
    await emitFirstPage('Floresta', [NewsDTO(id: 'novo', date: DateTime(2026, 1, 2)), ..._range(0, 19)]);
    final ids = _ids(cubit.state);
    expect(ids.first, 'novo');
    expect(ids.length, 41);
    expect(ids.toSet().length, 41);
    expect(ids.contains('n19'), isTrue);
  });

  test('página curta encerra a paginação', () async {
    cubit.watch(region: 'Floresta');
    await emitFirstPage('Floresta', _range(0, 20));
    await cubit.loadMore(); // n20..n39
    await cubit.loadMore(); // n40..n44 (curta)
    expect(repository.pageCursors, ['n19', 'n39']);
    expect(cubit.state.news.length, 45);
    expect(cubit.state.hasMore, isFalse);

    await cubit.loadMore();
    expect(repository.pageCursors.length, 2);
  });

  test('primeira página curta não busca mais', () async {
    cubit.watch(region: 'Floresta');
    await emitFirstPage('Floresta', _range(0, 5));
    expect(cubit.state.hasMore, isFalse);
    await cubit.loadMore();
    expect(repository.pageCursors, isEmpty);
  });

  test('erro no loadMore mantém a lista', () async {
    cubit.watch(region: 'Floresta');
    await emitFirstPage('Floresta', _range(0, 20));
    repository.pageFailure = ErrorWithMessage('falhou');
    await cubit.loadMore();
    expect(cubit.state, isA<ErrorNewsFeedState>());
    expect((cubit.state as ErrorNewsFeedState).errorMessage, 'falhou');
    expect(cubit.state.news.length, 20);
    expect(cubit.state.loadingMore, isFalse);
  });

  test('watch na mesma região não reabre a consulta', () async {
    cubit.watch(region: 'Floresta');
    await emitFirstPage('Floresta', _range(0, 20));
    await cubit.loadMore();
    cubit.watch(region: 'Floresta');
    expect(repository.watched, ['Floresta']);
    expect(cubit.state.news.length, 40);
  });

  test('troca de região recomeça do zero', () async {
    cubit.watch(region: 'Floresta');
    await emitFirstPage('Floresta', _range(0, 20));
    await cubit.loadMore();

    cubit.watch(region: 'Santo Inácio');
    expect(repository.watched, ['Floresta', 'Santo Inácio']);
    expect(cubit.state, isA<LoadingNewsFeedState>());
    expect(cubit.state.news, isEmpty);

    await emitFirstPage('Santo Inácio', _range(100, 103));
    expect(_ids(cubit.state), ['n100', 'n101', 'n102']);
    expect(cubit.state.hasMore, isFalse);

    // O stream da região antiga não afeta mais o feed.
    await emitFirstPage('Floresta', _range(0, 20));
    expect(cubit.state.news.length, 3);
  });

  test('excluir notícia de página antiga tira da lista', () async {
    cubit.watch(region: 'Floresta');
    await emitFirstPage('Floresta', _range(0, 20));
    await cubit.loadMore();
    await cubit.delete('n25');
    expect(_ids(cubit.state).contains('n25'), isFalse);
    expect(cubit.state.news.length, 39);
  });
}
