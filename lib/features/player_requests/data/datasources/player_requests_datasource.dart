import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';

/// Pedidos "Sou jogador" (`solicitacoes_jogador/{uid}`). O usuário grava o
/// próprio pedido; o admin edita, aprova (cria o jogador) ou rejeita.
class PlayerRequestsDataSource {
  final FirebaseFirestore _firestore;

  PlayerRequestsDataSource(this._firestore);

  static const String _logName = 'PlayerRequestsDataSource';
  static const String _loadFallback = 'Não foi possível carregar as solicitações.';
  static const String _saveFallback = 'Não foi possível salvar a solicitação.';

  CollectionReference<Map<String, dynamic>> get _requests => _firestore.collection('solicitacoes_jogador');

  /// Pedido do usuário em tempo real; `null` se ele ainda não pediu.
  Stream<Either<Failure, PlayerRequestDTO?>> watchMyRequest(String userId) {
    return _requests.doc(userId).snapshots().toEither(
          (doc) => doc.exists ? PlayerRequestDTO.fromFirestore(doc) : null,
          fallbackMessage: _loadFallback,
          logName: _logName,
        );
  }

  /// Envia (ou reenvia) o pedido: sobrescreve o anterior e volta a "pendente".
  Future<Either<Failure, void>> submit(PlayerRequestDTO request) async {
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

  /// Todos os pedidos, mais recentes primeiro (painel do admin).
  Stream<Either<Failure, List<PlayerRequestDTO>>> watchRequests() {
    return _requests.orderBy('data', descending: true).snapshots().toEither(
          (snapshot) => snapshot.docs.map(PlayerRequestDTO.fromFirestore).toList(),
          fallbackMessage: _loadFallback,
          logName: _logName,
        );
  }

  /// Quantos pedidos aguardam resposta (contador do menu do admin).
  Stream<Either<Failure, int>> watchPendingCount() {
    return _requests.where('status', isEqualTo: PlayerRequestStatus.pending.key).snapshots().toEither(
          (snapshot) => snapshot.size,
          fallbackMessage: _loadFallback,
          logName: _logName,
        );
  }

  /// Edição do admin antes de responder: nome, time e posição.
  Future<Either<Failure, void>> update(PlayerRequestDTO request) async {
    try {
      await _requests.doc(request.userId).update({
        'nome': request.name,
        'time': request.team,
        'posicao': request.position?.key ?? '',
        'atualizado_em': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('update uid=${request.userId}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Cria o jogador (vinculado à conta) e marca o pedido como aprovado, numa
  /// escrita só: não sobra jogador sem pedido aprovado nem o contrário.
  Future<Either<Failure, String>> approve(PlayerRequestDTO request) async {
    try {
      final playerRef = _firestore.collection(SeasonCollection.name('jogadores', request.season)).doc();
      final player = PlayerDTO(
        id: playerRef.id,
        name: request.name,
        team: request.team,
        imageUrl: request.imageUrl,
        userId: request.userId,
        position: request.position?.key ?? '',
      );
      final batch = _firestore.batch()
        ..set(playerRef, player.toMap())
        ..update(_requests.doc(request.userId), {
          'status': PlayerRequestStatus.approved.key,
          'idJogador': playerRef.id,
          'motivo': '',
          'atualizado_em': FieldValue.serverTimestamp(),
        });
      await batch.commit();
      return Right(playerRef.id);
    } catch (e) {
      AppLogger.e('approve uid=${request.userId}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível aprovar a solicitação.'));
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
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível rejeitar a solicitação.'));
    }
  }
}
