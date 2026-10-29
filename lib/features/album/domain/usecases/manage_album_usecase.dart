import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/album_layout.dart';
import 'package:arena_soccer/features/album/domain/repositories/album_repository_interface.dart';

/// Admin do álbum: eventos (criar, ligar/desligar, apagar) e as figurinhas
/// (com foto própria, geradas do elenco, numeradas em sequência).
class ManageAlbumUseCase {
  final IAlbumRepository _repository;
  final StorageUploadService _storage;

  ManageAlbumUseCase(this._repository, this._storage);

  Stream<Either<Failure, List<AlbumEventDTO>>> watchEvents() => _repository.watchEvents();

  Stream<Either<Failure, List<StickerDTO>>> watchStickers(String eventId) => _repository.watchStickers(eventId);

  Future<Either<Failure, String>> saveEvent(AlbumEventDTO event) => _repository.saveEvent(event);

  Future<Either<Failure, void>> setMode(String eventId, AlbumEventMode mode) =>
      _repository.setMode(eventId: eventId, mode: mode);

  Future<Either<Failure, void>> deleteEvent(String eventId) => _repository.deleteEvent(eventId);

  /// Acrescenta [added] (ex.: geradas do elenco) e renumera o álbum.
  Future<Either<Failure, void>> addStickers({
    required AlbumEventDTO event,
    required List<StickerDTO> added,
  }) async {
    if (added.isEmpty) return const Right(null);
    final saved = await _repository.saveStickers(eventId: event.id, stickers: added);
    if (saved.isLeft) return saved;
    return _renumber(event);
  }

  /// Grava a figurinha (com [image], sobe a foto nova para `album/` antes).
  Future<Either<Failure, void>> saveSticker({
    required AlbumEventDTO event,
    required StickerDTO sticker,
    File? image,
  }) async {
    var updated = sticker;
    if (image != null) {
      final upload = await _storage.uploadImage(file: image, folder: StorageFolder.album);
      if (upload.isLeft) return Left(upload.left);
      updated = updated.copyWith(imageUrl: upload.right);
    }
    final saved = await _repository.saveStickers(eventId: event.id, stickers: [updated]);
    if (saved.isLeft) return saved;
    return _renumber(event);
  }

  Future<Either<Failure, void>> deleteSticker(AlbumEventDTO event, StickerDTO sticker) async {
    final deleted = await _repository.deleteSticker(eventId: event.id, stickerId: sticker.id);
    if (deleted.isLeft) return deleted;
    return _renumber(event);
  }

  /// Números em sequência, página por página (só grava o que mudou).
  Future<Either<Failure, void>> _renumber(AlbumEventDTO event) async {
    final current = await _repository.watchStickers(event.id).first;
    if (current.isLeft) return Left(current.left);
    final changed = AlbumLayout.renumber(event, current.right);
    if (changed.isEmpty) return const Right(null);
    return _repository.saveStickers(eventId: event.id, stickers: changed);
  }
}
