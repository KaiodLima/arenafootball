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
}
