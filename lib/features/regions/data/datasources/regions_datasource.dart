import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';

/// Regiões (competições) cadastradas na coleção `competicao`.
class RegionsDataSource {
  final FirebaseFirestore _firestore;

  RegionsDataSource(this._firestore);

  Future<Either<Failure, List<String>>> getRegions() async {
    const fallback = 'Não foi possível carregar as regiões.';
    try {
      final result = await _firestore.collection('competicao').get();
      return Right(result.docs.map((doc) => doc.data()['nome']?.toString() ?? '').where((n) => n.isNotEmpty).toList());
    } catch (e) {
      AppLogger.e('getRegions', name: 'RegionsDataSource', error: e);
      return Left(mapFirebaseError(e, fallbackMessage: fallback));
    }
  }
}
