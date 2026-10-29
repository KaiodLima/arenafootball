import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/album_pack_id.dart';
import 'package:arena_soccer/features/album/domain/repositories/album_repository_interface.dart';

/// Álbum do torcedor: evento ativo, catálogo, as figurinhas da conta e o
/// pacotinho do dia.
class AlbumUseCase {
  final IAlbumRepository _repository;

  AlbumUseCase(this._repository);

  Stream<Either<Failure, AlbumEventDTO?>> watchActiveEvent() => _repository.watchActiveEvent();

  Stream<Either<Failure, List<StickerDTO>>> watchStickers(String eventId) => _repository.watchStickers(eventId);

  Stream<Either<Failure, UserAlbumDTO>> watchMyAlbum({required String userId, required String eventId}) =>
      _repository.watchMyAlbum(userId: userId, eventId: eventId);

  /// Pacote de hoje (nulo = ainda disponível).
  Stream<Either<Failure, AlbumPackDTO?>> watchTodayPack({
    required String userId,
    required String eventId,
    DateTime? now,
  }) =>
      _repository.watchPack(AlbumPackId.of(eventId: eventId, userId: userId, now: now ?? DateTime.now()));

  /// Pede o pacote de hoje (as functions sorteiam e colam).
  Future<Either<Failure, void>> openTodayPack({required String userId, required String eventId, DateTime? now}) =>
      _repository.requestPack(
        packId: AlbumPackId.of(eventId: eventId, userId: userId, now: now ?? DateTime.now()),
        userId: userId,
        eventId: eventId,
      );
}
