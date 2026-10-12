import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';

class HighlightsDataSource {
  final FirebaseFirestore _firestore;

  HighlightsDataSource(this._firestore);

  static const String _loadFallback = 'Não foi possível carregar os destaques.';
  static const String _saveFallback = 'Não foi possível salvar o destaque.';

  CollectionReference<Map<String, dynamic>> get _highlights => _firestore.collection('destaques');

  /// Notícias: a `tag` delas é o título do destaque.
  CollectionReference<Map<String, dynamic>> get _news => _firestore.collection('noticias');

  /// Destaques com `exibir == "true"`, na ordem de `priority`.
  Stream<Either<Failure, List<HighlightDTO>>> watchVisibleHighlights() {
    return _highlights.where('exibir', isEqualTo: 'true').orderBy('priority', descending: false).snapshots().toEither(
          (snapshot) => snapshot.docs.map(HighlightDTO.fromFirestore).toList(),
          fallbackMessage: _loadFallback,
          logName: 'HighlightsDataSource',
        );
  }

  /// Todos os destaques cadastrados (visíveis ou não).
  Future<Either<Failure, List<HighlightDTO>>> getHighlights() async {
    try {
      final result = await _highlights.get();
      return Right(result.docs.map(HighlightDTO.fromFirestore).toList());
    } catch (e) {
      AppLogger.e('getHighlights', name: 'HighlightsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _loadFallback));
    }
  }

  Future<Either<Failure, void>> createHighlight(HighlightDTO highlight) async {
    try {
      final ref = _highlights.doc();
      await ref.set(highlight.copyWith(id: ref.id).toMap());
      return const Right(null);
    } catch (e) {
      AppLogger.e('createHighlight', name: 'HighlightsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Todos os destaques (visíveis ou não), na ordem do carrossel. Ordena no
  /// app: `orderBy` deixaria de fora os documentos sem `priority`.
  Stream<Either<Failure, List<HighlightDTO>>> watchAllHighlights() {
    return _highlights.snapshots().toEither(
          (snapshot) => sortHighlightsByPriority(snapshot.docs.map(HighlightDTO.fromFirestore).toList()),
          fallbackMessage: _loadFallback,
          logName: 'HighlightsDataSource',
        );
  }

  /// Atualiza o destaque. Renomeado ([oldTitle] diferente), as notícias
  /// marcadas com o título antigo passam para o novo.
  Future<Either<Failure, void>> updateHighlight(HighlightDTO highlight, {String? oldTitle}) async {
    try {
      final writes = <void Function(WriteBatch)>[
        (batch) => batch.update(_highlights.doc(highlight.id), highlight.toMap()),
      ];
      if (oldTitle != null && oldTitle != highlight.title) {
        final tagged = await _news.where('tag', isEqualTo: oldTitle).get();
        for (final doc in tagged.docs) {
          writes.add((batch) => batch.update(doc.reference, {'tag': highlight.title}));
        }
      }
      await _commit(writes);
      return const Right(null);
    } catch (e) {
      AppLogger.e('updateHighlight id=${highlight.id}', name: 'HighlightsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Exclui o destaque; as notícias marcadas com ele continuam no feed, só
  /// perdem a marcação.
  Future<Either<Failure, void>> deleteHighlight(HighlightDTO highlight) async {
    try {
      final tagged = await _news.where('tag', isEqualTo: highlight.title).get();
      await _commit([
        (batch) => batch.delete(_highlights.doc(highlight.id)),
        for (final doc in tagged.docs) (batch) => batch.update(doc.reference, {'tag': ''}),
      ]);
      return const Right(null);
    } catch (e) {
      AppLogger.e('deleteHighlight id=${highlight.id}', name: 'HighlightsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Grava a ordem do carrossel: `priority` = posição em [ids].
  Future<Either<Failure, void>> reorderHighlights(List<String> ids) async {
    try {
      await _commit([
        for (var i = 0; i < ids.length; i++)
          (batch) => batch.update(_highlights.doc(ids[i]), {'priority': highlightPriorityAt(i)}),
      ]);
      return const Right(null);
    } catch (e) {
      AppLogger.e('reorderHighlights', name: 'HighlightsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  Future<Either<Failure, void>> setHighlightVisible({required String id, required bool visible}) async {
    try {
      await _highlights.doc(id).update({'exibir': visible.toString()});
      return const Right(null);
    } catch (e) {
      AppLogger.e('setHighlightVisible id=$id', name: 'HighlightsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Grava em lotes (limite de 500 operações por batch do Firestore).
  Future<void> _commit(List<void Function(WriteBatch)> writes) async {
    const chunk = 450;
    for (var start = 0; start < writes.length; start += chunk) {
      final batch = _firestore.batch();
      for (final write in writes.skip(start).take(chunk)) {
        write(batch);
      }
      await batch.commit();
    }
  }
}
