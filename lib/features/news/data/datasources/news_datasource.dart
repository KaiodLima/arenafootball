import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/features/partner_requests/domain/partner_slots.dart';
import 'package:arena_soccer/features/news/data/dtos/pending_news_dto.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';

class NewsDataSource {
  final FirebaseFirestore _firestore;

  NewsDataSource(this._firestore);

  static const String _collection = 'noticias';
  static const String _loadFallback = 'Não foi possível carregar as notícias.';
  static const String _saveFallback = 'Não foi possível salvar a notícia.';
  static const String _deleteFallback = 'Não foi possível excluir a notícia.';

  CollectionReference<Map<String, dynamic>> get _news => _firestore.collection(_collection);

  /// Último doc de cada página entregue (feed ao vivo e páginas antigas),
  /// pelo id. É o cursor do `startAfterDocument` de [getNewsPage]: os DTOs
  /// não carregam o snapshot, então ele fica guardado aqui. Se o id não
  /// estiver no cache, [getNewsPage] relê o doc (1 leitura a mais).
  final Map<String, DocumentSnapshot<Map<String, dynamic>>> _cursors = {};
  static const int _maxCursors = 100;

  Query<Map<String, dynamic>> _feedQuery(String? region) {
    Query<Map<String, dynamic>> query = _news;
    if (region != null) query = RegionRegistry.where(query, region);
    return query.orderBy('data', descending: true);
  }

  /// Guarda o último doc do lote como cursor da próxima página.
  List<NewsDTO> _mapPage(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    if (docs.isNotEmpty) {
      if (_cursors.length >= _maxCursors) _cursors.clear();
      _cursors[docs.last.id] = docs.last;
    }
    return docs.map(NewsDTO.fromFirestore).toList();
  }

  /// Primeira página do feed da região (ao vivo), mais recentes primeiro.
  /// Sem região, todas. As mais antigas vêm por [getNewsPage].
  Stream<Either<Failure, List<NewsDTO>>> watchNews({String? region, int limit = 20}) {
    return _feedQuery(region).limit(limit).snapshots().toEither(
          (snapshot) => _mapPage(snapshot.docs),
          fallbackMessage: _loadFallback,
          logName: 'NewsDataSource',
        );
  }

  /// Próxima página do feed (leitura única), começando depois da notícia
  /// [afterNewsId] (o último item cru da página anterior).
  Future<Either<Failure, List<NewsDTO>>> getNewsPage({
    String? region,
    required String afterNewsId,
    int limit = 20,
  }) async {
    try {
      final cursor = _cursors[afterNewsId] ?? await _news.doc(afterNewsId).get();
      if (!cursor.exists) return const Right([]);
      final result = await _feedQuery(region).startAfterDocument(cursor).limit(limit).get();
      return Right(_mapPage(result.docs));
    } catch (e) {
      AppLogger.e('getNewsPage after=$afterNewsId', name: 'NewsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _loadFallback));
    }
  }

  /// Notícias com a [tag] informada (ex.: título de um destaque).
  Stream<Either<Failure, List<NewsDTO>>> watchNewsByTag(String tag) {
    return _news.where('tag', isEqualTo: tag).orderBy('id', descending: true).snapshots().toEither(
          (snapshot) => snapshot.docs.map(NewsDTO.fromFirestore).toList(),
          fallbackMessage: _loadFallback,
          logName: 'NewsDataSource',
        );
  }

  /// Uma notícia pelo id (link compartilhado). Nulo se não existe mais.
  Future<Either<Failure, NewsDTO?>> getNewsById(String id) async {
    try {
      final doc = await _news.doc(id).get();
      return Right(doc.exists ? NewsDTO.fromFirestore(doc) : null);
    } catch (e) {
      AppLogger.e('getNewsById id=$id', name: 'NewsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _loadFallback));
    }
  }

  Future<Either<Failure, void>> createNews(NewsDTO news) async {
    try {
      if (news.id.isEmpty) {
        final ref = _news.doc();
        await ref.set({...news.copyWith(id: ref.id).toMap(), 'data': FieldValue.serverTimestamp()});
        return const Right(null);
      }
      // Notícia/publicidade do parceiro: já vem com o id da vaga do dia
      // (`PartnerSlots`) e grava junto o marcador da vaga.
      final batch = _firestore.batch()
        ..set(_news.doc(news.id), {...news.toMap(), 'data': FieldValue.serverTimestamp()})
        ..set(_firestore.collection(PartnerSlots.markersCollection).doc(news.id), {
          'idAutor': news.authorId,
          'criadoEm': FieldValue.serverTimestamp(),
        });
      await batch.commit();
      return const Right(null);
    } catch (e) {
      AppLogger.e('createNews tag=${news.tag}', name: 'NewsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  Future<Either<Failure, void>> updateNews(NewsDTO news) async {
    try {
      await _news.doc(news.id).set({
        ...news.toMap(),
        'data': news.date != null ? Timestamp.fromDate(news.date!) : FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('updateNews id=${news.id}', name: 'NewsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  Future<Either<Failure, void>> deleteNews(String id) async {
    try {
      await _news.doc(id).delete();
      return const Right(null);
    } catch (e) {
      AppLogger.e('deleteNews id=$id', name: 'NewsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _deleteFallback));
    }
  }

  /// Cards de gol em que o jogador marcou ou deu o passe, mais recentes
  /// primeiro. Duas consultas por igualdade (sem índice composto), juntadas
  /// no app.
  Future<Either<Failure, List<NewsDTO>>> getGoalCardsByPlayer(String playerId) async {
    try {
      final results = await Future.wait([
        _news.where('autor_gol_id', isEqualTo: playerId).get(),
        _news.where('assistencia_id', isEqualTo: playerId).get(),
      ]);
      final byId = <String, NewsDTO>{};
      for (final result in results) {
        for (final doc in result.docs) {
          byId[doc.id] = NewsDTO.fromFirestore(doc);
        }
      }
      final cards = byId.values.toList()..sort((a, b) => (b.date ?? DateTime(0)).compareTo(a.date ?? DateTime(0)));
      return Right(cards);
    } catch (e) {
      AppLogger.e('getGoalCardsByPlayer id=$playerId', name: 'NewsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _loadFallback));
    }
  }

  // ---------------------------------------------------------------- pendentes

  CollectionReference<Map<String, dynamic>> get _pending => _firestore.collection('noticias_pendentes');

  /// Notícia do parceiro além do limite do dia: espera o admin.
  Future<Either<Failure, void>> createPendingNews(NewsDTO news) async {
    try {
      final ref = _pending.doc();
      await ref.set({
        ...PendingNewsDTO(news: news.copyWith(id: ref.id)).toSubmitMap(),
        'data': FieldValue.serverTimestamp(),
        'criadoEm': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('createPendingNews', name: 'NewsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível enviar a notícia para aprovação.'));
    }
  }

  /// Pendentes e respondidas do parceiro [authorId].
  Stream<Either<Failure, List<PendingNewsDTO>>> watchMyPendingNews(String authorId) {
    return _pending.where('idAutor', isEqualTo: authorId).snapshots().toEither(
          (snapshot) => _sortPending(snapshot.docs.map(PendingNewsDTO.fromFirestore).toList()),
          fallbackMessage: _loadFallback,
          logName: 'NewsDataSource',
        );
  }

  /// Só as que esperam o admin.
  Stream<Either<Failure, List<PendingNewsDTO>>> watchPendingNews() {
    return _pending.where('status', isEqualTo: PendingNewsStatus.pending.key).snapshots().toEither(
          (snapshot) => _sortPending(snapshot.docs.map(PendingNewsDTO.fromFirestore).toList()),
          fallbackMessage: _loadFallback,
          logName: 'NewsDataSource',
        );
  }

  /// Mais antigas primeiro (ordena no app: sem índice composto).
  List<PendingNewsDTO> _sortPending(List<PendingNewsDTO> items) => items
    ..sort((a, b) => (a.createdAt ?? DateTime(3000)).compareTo(b.createdAt ?? DateTime(3000)));

  /// Admin aprova: publica em `noticias` (hora do servidor, autor do parceiro)
  /// e marca a pendente, numa escrita só.
  Future<Either<Failure, void>> approvePendingNews(PendingNewsDTO pending) async {
    try {
      final ref = _news.doc();
      final batch = _firestore.batch()
        ..set(ref, {...pending.news.copyWith(id: ref.id).toMap(), 'data': FieldValue.serverTimestamp()})
        ..update(_pending.doc(pending.id), {
          'status': PendingNewsStatus.approved.key,
          'idNoticia': ref.id,
          'motivo': '',
        });
      await batch.commit();
      return const Right(null);
    } catch (e) {
      AppLogger.e('approvePendingNews id=${pending.id}', name: 'NewsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível publicar a notícia.'));
    }
  }

  Future<Either<Failure, void>> rejectPendingNews({required String id, required String reason}) async {
    try {
      await _pending.doc(id).update({'status': PendingNewsStatus.rejected.key, 'motivo': reason});
      return const Right(null);
    } catch (e) {
      AppLogger.e('rejectPendingNews id=$id', name: 'NewsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível rejeitar a notícia.'));
    }
  }

  Future<Either<Failure, void>> deletePendingNews(String id) async {
    try {
      await _pending.doc(id).delete();
      return const Right(null);
    } catch (e) {
      AppLogger.e('deletePendingNews id=$id', name: 'NewsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _deleteFallback));
    }
  }

}
