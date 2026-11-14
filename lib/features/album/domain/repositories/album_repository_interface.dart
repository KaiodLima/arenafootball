import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';

abstract class IAlbumRepository {
  Stream<Either<Failure, AlbumEventDTO?>> watchActiveEvent();

  Stream<Either<Failure, List<AlbumEventDTO>>> watchEvents();

  Stream<Either<Failure, List<StickerDTO>>> watchStickers(String eventId);

  Stream<Either<Failure, UserAlbumDTO>> watchMyAlbum({required String userId, required String eventId});

  Stream<Either<Failure, AlbumPackDTO?>> watchPack(String packId);

  Future<Either<Failure, List<AlbumRankingEntryDTO>>> getTopCollectors(String eventId);

  Future<Either<Failure, AlbumRankingEntryDTO?>> getCollector(String eventId, String userId);

  Future<Either<Failure, int>> collectorsAhead(String eventId, int collected);

  Future<Either<Failure, void>> requestPack({
    required String packId,
    required String userId,
    required String eventId,
    bool extra = false,
  });

  Future<Either<Failure, String>> saveEvent(AlbumEventDTO event);

  Future<Either<Failure, void>> setMode({required String eventId, required AlbumEventMode mode});

  Future<Either<Failure, void>> deleteEvent(String eventId);

  Future<Either<Failure, void>> saveStickers({required String eventId, required List<StickerDTO> stickers});

  Future<Either<Failure, void>> deleteSticker({required String eventId, required String stickerId});

  /// Várias de uma vez (em lotes).
  Future<Either<Failure, void>> deleteStickers({required String eventId, required List<String> stickerIds});
}
