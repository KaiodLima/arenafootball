import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/team_requests/data/dtos/team_request_dto.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';

/// Pedidos "Sou dono de time" (`solicitacoes_time/{uid}`). O usuário grava o
/// próprio pedido; o admin edita, aprova (cria o time com o dono) ou rejeita.
class TeamRequestsDataSource {
  final FirebaseFirestore _firestore;

  TeamRequestsDataSource(this._firestore);

  static const String _logName = 'TeamRequestsDataSource';
  static const String _loadFallback = 'Não foi possível carregar os pedidos de time.';
  static const String _saveFallback = 'Não foi possível salvar o pedido de time.';

  CollectionReference<Map<String, dynamic>> get _requests => _firestore.collection('solicitacoes_time');

  Stream<Either<Failure, TeamRequestDTO?>> watchMyRequest(String userId) {
    return _requests.doc(userId).snapshots().toEither(
          (doc) => doc.exists ? TeamRequestDTO.fromFirestore(doc) : null,
          fallbackMessage: _loadFallback,
          logName: _logName,
        );
  }

  Future<Either<Failure, void>> submit(TeamRequestDTO request) async {
    try {
      await _requests.doc(request.userId).set({
        ...request.toSubmitMap(),
        'data': FieldValue.serverTimestamp(),
        'atualizado_em': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('submit uid=${request.userId}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  Future<Either<Failure, void>> cancel(String userId) async {
    try {
      await _requests.doc(userId).delete();
      return const Right(null);
    } catch (e) {
      AppLogger.e('cancel uid=$userId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  Stream<Either<Failure, List<TeamRequestDTO>>> watchRequests() {
    return _requests.orderBy('data', descending: true).snapshots().toEither(
          (snapshot) => snapshot.docs.map(TeamRequestDTO.fromFirestore).toList(),
          fallbackMessage: _loadFallback,
          logName: _logName,
        );
  }

  Stream<Either<Failure, int>> watchPendingCount() {
    return _requests.where('status', isEqualTo: PlayerRequestStatus.pending.key).snapshots().toEither(
          (snapshot) => snapshot.size,
          fallbackMessage: _loadFallback,
          logName: _logName,
        );
  }

  /// Edição do admin antes de responder: nome, região e descrição.
  Future<Either<Failure, void>> update(TeamRequestDTO request) async {
    try {
      await _requests.doc(request.userId).update({
        'nome': request.name,
        ...RegionRegistry.fieldsFor(request.region, nameKey: 'regiao'),
        'descricao': request.description,
        'atualizado_em': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('update uid=${request.userId}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Cria o time [team] (com o dono) e a linha zerada da classificação na
  /// temporada atual, e marca o pedido como aprovado — numa escrita só.
  Future<Either<Failure, void>> approve({required TeamRequestDTO request, required TeamDTO team}) async {
    try {
      final batch = _firestore.batch()
        ..set(_firestore.collection(SeasonCollection.name('times', null)).doc(team.id), team.toMap())
        ..set(_firestore.collection(SeasonCollection.name('classificacao', null)).doc(team.id), team.toStandingsMap())
        ..update(_requests.doc(request.userId), {
          'status': PlayerRequestStatus.approved.key,
          'idTime': team.id,
          'temporada': SeasonCollection.currentSeason,
          'motivo': '',
          'atualizado_em': FieldValue.serverTimestamp(),
        });
      await batch.commit();
      return const Right(null);
    } catch (e) {
      AppLogger.e('approve uid=${request.userId}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível aprovar o time.'));
    }
  }

  Future<Either<Failure, void>> reject({required String userId, required String reason}) async {
    try {
      await _requests.doc(userId).update({
        'status': PlayerRequestStatus.rejected.key,
        'motivo': reason,
        'atualizado_em': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('reject uid=$userId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível rejeitar o pedido.'));
    }
  }
}
