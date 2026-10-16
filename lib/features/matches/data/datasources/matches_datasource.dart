import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';

class MatchesDataSource {
  final FirebaseFirestore _firestore;

  MatchesDataSource(this._firestore);

  static const String _logName = 'MatchesDataSource';
  static const String _saveFallback = 'Não foi possível salvar a partida.';

  CollectionReference<Map<String, dynamic>> _matches(String? season) =>
      _firestore.collection(SeasonCollection.name('partidas', season));

  /// Partidas da temporada, das mais recentes para as mais antigas. Com
  /// [region], só as daquela região (filtro no servidor: cada doc lido é
  /// cobrado); sem ela, todas (admin/manutenção). O filtro por campeonato/dia
  /// é feito no UseCase.
  Stream<Either<Failure, List<MatchDTO>>> watchMatches({String? season, String? region}) {
    Query<Map<String, dynamic>> query = _matches(season);
    if (region != null && region.isNotEmpty) query = RegionRegistry.where(query, region);
    return query.orderBy('dataRegistro', descending: true).snapshots().toEither(
          (snapshot) => snapshot.docs.map(MatchDTO.fromFirestore).toList(),
          fallbackMessage: 'Não foi possível carregar as partidas.',
          logName: _logName,
        );
  }

  /// Cria a partida com `id_partida` = id do documento e `dataRegistro` do
  /// servidor, numa escrita só (o app antigo fazia `add()` + `set()`).
  Future<Either<Failure, void>> createMatch(MatchDTO match, {String? season}) async {
    try {
      final ref = _matches(season).doc();
      await ref.set({
        ...match.copyWith(id: ref.id).toMap(),
        'dataRegistro': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('createMatch', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível cadastrar a partida.'));
    }
  }

  Future<Either<Failure, void>> updateScore({
    required String matchId,
    required int homeGoals,
    required int awayGoals,
    String? season,
  }) =>
      _update(matchId, {'golTimeCasa': homeGoals, 'golTimeFora': awayGoals}, season: season);

  /// `votacao` continua gravado como string.
  Future<Either<Failure, void>> setVotingOpen({required String matchId, required bool isOpen, String? season}) =>
      _update(matchId, {'votacao': isOpen.toString()}, season: season);

  Future<Either<Failure, void>> _update(String matchId, Map<String, dynamic> fields, {String? season}) async {
    try {
      await _matches(season).doc(matchId).update(fields);
      return const Right(null);
    } catch (e) {
      AppLogger.e('update id=$matchId fields=${fields.keys}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  Future<Either<Failure, void>> deleteMatch({required String matchId, String? season}) async {
    try {
      await _matches(season).doc(matchId).delete();
      return const Right(null);
    } catch (e) {
      AppLogger.e('deleteMatch id=$matchId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível excluir a partida.'));
    }
  }
}
