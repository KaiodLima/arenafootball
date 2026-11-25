import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/album/data/datasources/album_datasource.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/repositories/album_repository_interface.dart';

class AlbumRepositoryImpl implements IAlbumRepository {
  final AlbumDataSource _dataSource;
  final CacheStore _cache;

  AlbumRepositoryImpl(this._dataSource, this._cache);

  @override
  Future<Either<Failure, CachedValue<AlbumRankingView>?>> getCachedRanking(
          {required String eventId, required String userId}) =>
      _cache.read(
        CacheKeys.albumRanking(eventId: eventId, uid: userId),
        (json) => AlbumRankingView.fromCache(Map<String, dynamic>.from(json as Map)),
      );

  @override
  Future<Either<Failure, void>> saveRankingCache(AlbumRankingView view,
          {required String eventId, required String userId}) =>
      _cache.save(CacheKeys.albumRanking(eventId: eventId, uid: userId), view.toCache());

  @override
  Stream<Either<Failure, AlbumEventDTO?>> watchActiveEvent() => _dataSource.watchActiveEvent();

  @override
  Stream<Either<Failure, List<AlbumEventDTO>>> watchEvents() => _dataSource.watchEvents();

  @override
  Stream<Either<Failure, List<StickerDTO>>> watchStickers(String eventId) => _dataSource.watchStickers(eventId);

  @override
  Stream<Either<Failure, UserAlbumDTO>> watchMyAlbum({required String userId, required String eventId}) =>
      _dataSource.watchMyAlbum(userId: userId, eventId: eventId);

  @override
  Stream<Either<Failure, AlbumPackDTO?>> watchPack(String packId) => _dataSource.watchPack(packId);

  @override
  Future<Either<Failure, List<AlbumRankingEntryDTO>>> getTopCollectors(String eventId) =>
      _dataSource.getTopCollectors(eventId);

  @override
  Future<Either<Failure, AlbumRankingEntryDTO?>> getCollector(String eventId, String userId) =>
      _dataSource.getCollector(eventId, userId);

  @override
  Future<Either<Failure, int>> collectorsAhead(String eventId, int collected) =>
      _dataSource.collectorsAhead(eventId, collected);

  @override
  Future<Either<Failure, void>> requestPack({
    required String packId,
    required String userId,
    required String eventId,
    bool extra = false,
    List<String> trade = const [],
  }) async {
    final response =
        await _dataSource.requestPack(packId: packId, userId: userId, eventId: eventId, extra: extra, trade: trade);
    // As functions colam as figurinhas e mudam o ranking da conta.
    if (response.isRight) await _cache.deleteWhere((key) => CacheKeys.isAlbumRankingKey(key, eventId));
    return response;
  }

  @override
  Future<Either<Failure, String>> saveEvent(AlbumEventDTO event) => _dataSource.saveEvent(event);

  @override
  Future<Either<Failure, void>> setMode({required String eventId, required AlbumEventMode mode}) =>
      _dataSource.setMode(eventId: eventId, mode: mode);

  @override
  Future<Either<Failure, void>> deleteEvent(String eventId) => _dataSource.deleteEvent(eventId);

  @override
  Future<Either<Failure, void>> saveStickers({required String eventId, required List<StickerDTO> stickers}) =>
      _dataSource.saveStickers(eventId: eventId, stickers: stickers);

  @override
  Future<Either<Failure, void>> deleteSticker({required String eventId, required String stickerId}) =>
      _dataSource.deleteSticker(eventId: eventId, stickerId: stickerId);

  @override
  Future<Either<Failure, void>> deleteStickers({required String eventId, required List<String> stickerIds}) =>
      _dataSource.deleteStickers(eventId: eventId, stickerIds: stickerIds);

  @override
  Future<Either<Failure, void>> updateStickerPhotos({required String eventId, required Map<String, String> photos}) =>
      _dataSource.updateStickerPhotos(eventId: eventId, photos: photos);
}
