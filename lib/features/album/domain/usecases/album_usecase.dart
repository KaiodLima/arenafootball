import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/album_pack_id.dart';
import 'package:arena_soccer/features/album/domain/repositories/album_repository_interface.dart';

/// Álbum do torcedor: evento ativo, catálogo, as figurinhas da conta (com a
/// hora do último pacote) e o pedido do pacotinho.
class AlbumUseCase {
  final IAlbumRepository _repository;

  AlbumUseCase(this._repository);

  Stream<Either<Failure, AlbumEventDTO?>> watchActiveEvent() => _repository.watchActiveEvent();

  Stream<Either<Failure, List<StickerDTO>>> watchStickers(String eventId) => _repository.watchStickers(eventId);

  Stream<Either<Failure, UserAlbumDTO>> watchMyAlbum({required String userId, required String eventId}) =>
      _repository.watchMyAlbum(userId: userId, eventId: eventId);

  /// O pacote pedido (o sorteio do servidor chega por aqui).
  Stream<Either<Failure, AlbumPackDTO?>> watchPack(String packId) => _repository.watchPack(packId);

  /// Pede o próximo pacote da conta (que já abriu [opened]); devolve o id
  /// para acompanhar o sorteio.
  Future<Either<Failure, String>> openPack({
    required String userId,
    required String eventId,
    required int opened,
  }) async {
    final packId = AlbumPackId.next(eventId: eventId, userId: userId, opened: opened);
    final response = await _repository.requestPack(packId: packId, userId: userId, eventId: eventId);
    return response.map((_) => packId);
  }
}
