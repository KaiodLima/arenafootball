import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/news_feed_page.dart';
import 'package:arena_soccer/features/news/domain/usecases/delete_news_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_news_page_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/watch_news_feed_usecase.dart';
import 'package:arena_soccer/features/news/presentation/bloc/news_feed_state.dart';

/// Feed da aba Início: a primeira página vem ao vivo (stream com limite) e
/// as mais antigas por [loadMore] (leitura única, paginada). Vive na rota da
/// home: voltar à aba com a mesma região não reabre a consulta.
class NewsFeedCubit extends Cubit<NewsFeedState> {
  final WatchNewsFeedUseCase watchNewsFeedUseCase;
  final GetNewsPageUseCase getNewsPageUseCase;
  final DeleteNewsUseCase deleteNewsUseCase;
  StreamSubscription<Either<Failure, NewsFeedPage>>? _subscription;
  String? _region;

  /// Última emissão da primeira página (nula até o stream responder).
  NewsFeedPage? _firstPage;

  /// Notícias das páginas antigas, na ordem em que chegaram.
  List<NewsDTO> _older = const [];

  /// Cursor/fim das páginas antigas; nulo enquanto nenhuma foi carregada.
  String? _olderLastId;
  bool _olderHasMore = false;
  bool _loadingMore = false;

  /// Conta as trocas de região: página que chega de uma região antiga é
  /// descartada.
  int _generation = 0;

  NewsFeedCubit(this.watchNewsFeedUseCase, this.getNewsPageUseCase, this.deleteNewsUseCase)
      : super(const LoadingNewsFeedState());

  /// Já ouve o feed desta região.
  bool isWatching(String region) => _subscription != null && _region == region;

  /// Ouve a primeira página do feed da região. Mesma região = nada a fazer;
  /// região nova começa do zero (descarta as páginas antigas).
  void watch({required String region}) {
    if (isWatching(region)) return;
    _subscription?.cancel();
    _generation++;
    _region = region;
    _firstPage = null;
    _older = const [];
    _olderLastId = null;
    _olderHasMore = false;
    _loadingMore = false;
    emit(const LoadingNewsFeedState());
    _subscription = watchNewsFeedUseCase(region: region).listen((response) {
      response.fold(
        (failure) => emit(ErrorNewsFeedState(errorMessage: failure.toString(), news: state.news, hasMore: _hasMore)),
        _onFirstPage,
      );
    });
  }

  void _onFirstPage(NewsFeedPage page) {
    final previous = _firstPage;
    _firstPage = page;
    // Com páginas antigas na tela, uma notícia nova empurra a última da
    // primeira página para fora do limite; ela passa para as antigas (senão
    // sumiria, pois a próxima página começa depois do cursor antigo). Só
    // as de data até a última da página nova: as mais novas que saíram
    // foram excluídas.
    if (_olderLastId != null && previous != null && page.news.isNotEmpty) {
      final lastDate = page.news.last.date;
      final ids = page.news.map((n) => n.id).toSet();
      final pushed = previous.news.where(
        (n) => !ids.contains(n.id) && n.date != null && lastDate != null && !n.date!.isAfter(lastDate),
      );
      if (pushed.isNotEmpty) _older = [...pushed, ..._older];
    }
    _emitList();
  }

  /// Primeira página + antigas, sem repetir id (a primeira página prevalece).
  List<NewsDTO> get _combined {
    final first = _firstPage?.news ?? const <NewsDTO>[];
    final ids = first.map((n) => n.id).toSet();
    return [...first, ..._older.where((n) => ids.add(n.id))];
  }

  bool get _hasMore => _olderLastId != null ? _olderHasMore : (_firstPage?.hasMore ?? false);

  String? get _cursor => _olderLastId ?? _firstPage?.lastId;

  void _emitList() {
    emit(SuccessNewsFeedState(news: _combined, hasMore: _hasMore, loadingMore: _loadingMore));
  }

  /// Busca a próxima página antiga e junta no fim da lista. Ignorado
  /// enquanto outra busca está em andamento ou quando não há mais páginas.
  /// Erro vira snackbar sem apagar a lista.
  Future<void> loadMore() async {
    final cursor = _cursor;
    if (_loadingMore || _firstPage == null || !_hasMore || cursor == null) return;
    final generation = _generation;
    _loadingMore = true;
    _emitList();
    final response = await getNewsPageUseCase(region: _region, afterNewsId: cursor);
    if (isClosed || generation != _generation) return;
    _loadingMore = false;
    response.fold(
      (failure) => emit(ErrorNewsFeedState(errorMessage: failure.toString(), news: _combined, hasMore: _hasMore)),
      (page) {
        _older = [..._older, ...page.news];
        _olderLastId = page.lastId ?? cursor;
        _olderHasMore = page.hasMore;
        _emitList();
      },
    );
  }

  /// O stream atualiza a primeira página sozinho após a exclusão; nas
  /// páginas antigas (leitura única) a notícia sai da lista aqui.
  Future<void> delete(String id) async {
    final response = await deleteNewsUseCase(id);
    if (isClosed) return;
    if (response.isLeft) {
      emit(ErrorNewsFeedState(errorMessage: response.left.toString(), news: state.news, hasMore: state.hasMore));
      return;
    }
    if (_older.any((n) => n.id == id)) {
      _older = _older.where((n) => n.id != id).toList();
      _emitList();
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
