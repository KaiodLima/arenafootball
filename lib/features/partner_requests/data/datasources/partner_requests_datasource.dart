import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/highlights/data/dtos/highlight_dto.dart';
import 'package:arena_soccer/features/partner_requests/data/dtos/partner_request_dto.dart';
import 'package:arena_soccer/features/partner_requests/domain/partner_slots.dart';
import 'package:arena_soccer/features/player_requests/data/dtos/player_request_dto.dart';

/// Pedidos "Sou parceiro" (`solicitacoes_parceiro/{uid}`). O usuário grava o
/// próprio pedido; o admin aprova (com as permissões), rejeita, ajusta as
/// permissões ou remove o parceiro.
class PartnerRequestsDataSource {
  final FirebaseFirestore _firestore;

  PartnerRequestsDataSource(this._firestore);

  static const String _logName = 'PartnerRequestsDataSource';
  static const String _loadFallback = 'Não foi possível carregar os pedidos de parceiro.';
  static const String _saveFallback = 'Não foi possível salvar o pedido de parceiro.';

  CollectionReference<Map<String, dynamic>> get _requests => _firestore.collection('solicitacoes_parceiro');

  Stream<Either<Failure, PartnerRequestDTO?>> watchMyRequest(String userId) {
    return _requests.doc(userId).snapshots().toEither(
          (doc) => doc.exists ? PartnerRequestDTO.fromFirestore(doc) : null,
          fallbackMessage: _loadFallback,
          logName: _logName,
        );
  }

  Future<Either<Failure, void>> submit(PartnerRequestDTO request) async {
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

  Stream<Either<Failure, List<PartnerRequestDTO>>> watchRequests() {
    return _requests.orderBy('data', descending: true).snapshots().toEither(
          (snapshot) => snapshot.docs.map(PartnerRequestDTO.fromFirestore).toList(),
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

  /// Respostas do admin: [status] com o motivo e, na aprovação, as permissões.
  Future<Either<Failure, void>> answer({
    required String userId,
    required PlayerRequestStatus status,
    String reason = '',
    PartnerPermissions? permissions,
  }) async {
    try {
      await _requests.doc(userId).update({
        'status': status.key,
        'motivo': reason,
        if (permissions != null) ...permissions.toMap(),
        'atualizado_em': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('answer uid=$userId status=${status.key}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  Future<Either<Failure, void>> updatePermissions({
    required String userId,
    required PartnerPermissions permissions,
  }) async {
    try {
      await _requests.doc(userId).update({
        ...permissions.toMap(),
        'atualizado_em': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('updatePermissions uid=$userId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Destaques sem dono que o usuário diz serem dele ([ids] vazio = desiste).
  /// O próprio usuário (também o parceiro aprovado) ou o admin gravam.
  Future<Either<Failure, void>> setHighlightClaims({required String userId, required List<String> ids}) async {
    try {
      await _requests.doc(userId).update({
        'idsDestaquesVinculo': ids,
        'atualizado_em': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('setHighlightClaims uid=$userId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Admin vincula os destaques pedidos ao parceiro, numa escrita só: cada
  /// destaque ainda sem dono vira uma cópia na vaga livre do parceiro (região
  /// dele, `idAutor`, depois dos do admin) e o antigo é apagado; o limite sobe
  /// para caber e o pedido de vínculo é limpo. Devolve quantos vinculou.
  Future<Either<Failure, int>> linkHighlights(PartnerRequestDTO request) async {
    try {
      final highlights = _firestore.collection('destaques');
      final claimed = await Future.wait(request.claimedHighlightIds.map((id) => highlights.doc(id).get()));
      final free = [
        for (final doc in claimed)
          if (doc.exists) HighlightDTO.fromFirestore(doc),
      ].where((h) => h.authorId.isEmpty).toList();
      final slotIds = PartnerSlots.highlightIds(request.userId, PartnerPermissions.maxLimit);
      final slotDocs = await Future.wait(slotIds.map((id) => highlights.doc(id).get()));
      final plan = HighlightLinkPlan.of(
        userId: request.userId,
        currentLimit: request.permissions.highlightLimit,
        claimed: free.map((h) => h.id).toList(),
        taken: {for (final doc in slotDocs) if (doc.exists) doc.id},
        maxSlots: PartnerPermissions.maxLimit,
      );
      final batch = _firestore.batch();
      for (final highlight in free) {
        final slot = plan.slots[highlight.id];
        if (slot == null) continue;
        batch
          ..set(
            highlights.doc(slot),
            highlight
                .copyWith(
                  id: slot,
                  region: request.region,
                  authorId: request.userId,
                  priority: PartnerSlots.highlightPriority,
                )
                .toMap(),
          )
          ..delete(highlights.doc(highlight.id));
      }
      batch.update(_requests.doc(request.userId), {
        'idsDestaquesVinculo': <String>[],
        'limiteDestaques': plan.highlightLimit,
        'atualizado_em': FieldValue.serverTimestamp(),
      });
      await batch.commit();
      return Right(plan.slots.length);
    } catch (e) {
      AppLogger.e('linkHighlights uid=${request.userId}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível vincular os destaques.'));
    }
  }

  /// Quais dos docs [ids] de [collection] já existem (vagas ocupadas do
  /// parceiro: uma leitura por vaga, poucas).
  Future<Either<Failure, Set<String>>> existingIds({required String collection, required List<String> ids}) async {
    try {
      final docs = await Future.wait(ids.map((id) => _firestore.collection(collection).doc(id).get()));
      return Right({for (final doc in docs) if (doc.exists) doc.id});
    } catch (e) {
      AppLogger.e('existingIds $collection', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _loadFallback));
    }
  }
}
