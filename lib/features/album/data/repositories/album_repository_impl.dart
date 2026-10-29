import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/album/data/datasources/album_datasource.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/repositories/album_repository_interface.dart';

class AlbumRepositoryImpl implements IAlbumRepository {
  final AlbumDataSource _dataSource;

  AlbumRepositoryImpl(this._dataSource);

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
  Future<Either<Failure, void>> requestPack(
          {required String packId, required String userId, required String eventId}) =>
      _dataSource.requestPack(packId: packId, userId: userId, eventId: eventId);

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
}
