import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/errors/firebase_error.dart';
import 'package:arena_soccer/core/firebase/either_stream.dart';
import 'package:arena_soccer/core/utils/app_logger.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';

/// Álbum de figurinhas: eventos (`album_eventos`), catálogo (subcoleção
/// `figurinhas`), o álbum da conta (`usuarios/{uid}/album/{evento}`, só as
/// functions gravam) e o pacote do dia (`album_pacotes`).
class AlbumDataSource {
  final FirebaseFirestore _firestore;

  AlbumDataSource(this._firestore);

  static const String _logName = 'AlbumDataSource';
  static const String _loadFallback = 'Não foi possível carregar o álbum.';
  static const String _saveFallback = 'Não foi possível salvar o álbum.';

  CollectionReference<Map<String, dynamic>> get _events => _firestore.collection('album_eventos');

  CollectionReference<Map<String, dynamic>> _stickers(String eventId) => _events.doc(eventId).collection('figurinhas');

  /// Evento ativo (nulo = nenhum).
  Stream<Either<Failure, AlbumEventDTO?>> watchActiveEvent() {
    return _events.where('ativo', isEqualTo: true).limit(1).snapshots().toEither(
          (snapshot) => snapshot.docs.isEmpty ? null : AlbumEventDTO.fromFirestore(snapshot.docs.first),
          fallbackMessage: _loadFallback,
          logName: _logName,
        );
  }

  Stream<Either<Failure, List<AlbumEventDTO>>> watchEvents() {
    return _events.snapshots().toEither(
          (snapshot) => snapshot.docs.map(AlbumEventDTO.fromFirestore).toList()
            ..sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0))),
          fallbackMessage: _loadFallback,
          logName: _logName,
        );
  }

  Stream<Either<Failure, List<StickerDTO>>> watchStickers(String eventId) {
    return _stickers(eventId).snapshots().toEither(
          (snapshot) =>
              snapshot.docs.map(StickerDTO.fromFirestore).toList()..sort((a, b) => a.number.compareTo(b.number)),
          fallbackMessage: _loadFallback,
          logName: _logName,
        );
  }

  Stream<Either<Failure, UserAlbumDTO>> watchMyAlbum({required String userId, required String eventId}) {
    return _firestore.doc('usuarios/$userId/album/$eventId').snapshots().toEither(
          (doc) => doc.exists ? UserAlbumDTO.fromMap(doc.data()!) : const UserAlbumDTO(),
          fallbackMessage: _loadFallback,
          logName: _logName,
        );
  }

  /// Pacote [packId] (nulo = ainda não pedido hoje).
  Stream<Either<Failure, AlbumPackDTO?>> watchPack(String packId) {
    return _firestore.collection('album_pacotes').doc(packId).snapshots().toEither(
          (doc) => doc.exists ? AlbumPackDTO.fromFirestore(doc) : null,
          fallbackMessage: _loadFallback,
          logName: _logName,
        );
  }

  /// Pede o pacote do dia (as functions sorteiam).
  Future<Either<Failure, void>> requestPack({
    required String packId,
    required String userId,
    required String eventId,
  }) async {
    try {
      await _firestore.collection('album_pacotes').doc(packId).set({
        'uid': userId,
        'idEvento': eventId,
        'status': AlbumPackStatus.requested.key,
        'pedidoEm': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      AppLogger.e('requestPack $packId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: 'Não foi possível abrir o pacote.'));
    }
  }

  // ---------------------------------------------------------------- admin

  /// Cria ([AlbumEventDTO.id] vazio) ou atualiza o evento; devolve o id.
  Future<Either<Failure, String>> saveEvent(AlbumEventDTO event) async {
    try {
      if (event.id.isEmpty) {
        final ref = _events.doc();
        await ref.set({...event.toMap(), 'ativo': false, 'criadoEm': FieldValue.serverTimestamp()});
        return Right(ref.id);
      }
      await _events.doc(event.id).set(event.toMap(), SetOptions(merge: true));
      return Right(event.id);
    } catch (e) {
      AppLogger.e('saveEvent ${event.id}', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Liga [eventId] e desliga os outros (um ativo por vez); [active] falso só desliga.
  Future<Either<Failure, void>> setActive({required String eventId, required bool active}) async {
    try {
      final batch = _firestore.batch();
      if (active) {
        final others = await _events.where('ativo', isEqualTo: true).get();
        for (final doc in others.docs) {
          if (doc.id != eventId) batch.update(doc.reference, {'ativo': false});
        }
      }
      batch.update(_events.doc(eventId), {'ativo': active});
      await batch.commit();
      return const Right(null);
    } catch (e) {
      AppLogger.e('setActive $eventId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Apaga o evento e as figurinhas dele (os álbuns das contas ficam órfãos).
  Future<Either<Failure, void>> deleteEvent(String eventId) async {
    try {
      final stickers = await _stickers(eventId).get();
      final batch = _firestore.batch();
      for (final doc in stickers.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_events.doc(eventId));
      await batch.commit();
      return const Right(null);
    } catch (e) {
      AppLogger.e('deleteEvent $eventId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// Grava as figurinhas (novas, sem id, ganham um) e o total no evento.
  Future<Either<Failure, void>> saveStickers({required String eventId, required List<StickerDTO> stickers}) async {
    try {
      final batch = _firestore.batch();
      for (final sticker in stickers) {
        final ref = sticker.id.isEmpty ? _stickers(eventId).doc() : _stickers(eventId).doc(sticker.id);
        batch.set(ref, sticker.toMap());
      }
      await batch.commit();
      await _syncTotal(eventId);
      return const Right(null);
    } catch (e) {
      AppLogger.e('saveStickers $eventId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  Future<Either<Failure, void>> deleteSticker({required String eventId, required String stickerId}) async {
    try {
      await _stickers(eventId).doc(stickerId).delete();
      await _syncTotal(eventId);
      return const Right(null);
    } catch (e) {
      AppLogger.e('deleteSticker $stickerId', name: _logName, error: e);
      return Left(mapFirebaseError(e, fallbackMessage: _saveFallback));
    }
  }

  /// `total` do evento = figurinhas do catálogo (`count()`, uma leitura).
  Future<void> _syncTotal(String eventId) async {
    final count = await _stickers(eventId).count().get();
    await _events.doc(eventId).update({'total': count.count ?? 0});
  }
}
