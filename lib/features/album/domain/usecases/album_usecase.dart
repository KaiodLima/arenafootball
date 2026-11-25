import 'package:either_dart/either.dart';
import 'package:arena_soccer/core/cache/cache_first.dart';
import 'package:arena_soccer/core/cache/cache_ttl.dart';
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

  /// Ranking de colecionadores: top 50, a linha da conta e a posição dela
  /// (quem tem mais coladas + 1; dentro do top 50, a posição na lista).
  Future<Either<Failure, AlbumRankingView>> getRanking({required String eventId, required String userId}) async {
    final result = await _fetchRanking(eventId: eventId, userId: userId);
    return result.map((r) => r.view);
  }

  /// [complete] falso = a linha da conta ou a contagem "à frente" falhou (o
  /// ranking sai sem elas e não vai para o cache).
  Future<Either<Failure, ({AlbumRankingView view, bool complete})>> _fetchRanking({
    required String eventId,
    required String userId,
  }) async {
    final top = await _repository.getTopCollectors(eventId);
    if (top.isLeft) return Left(top.left);
    final index = top.right.indexWhere((e) => e.userId == userId);
    if (index >= 0) {
      return Right((view: AlbumRankingView(top: top.right, me: top.right[index], myPosition: index + 1), complete: true));
    }
    final me = await _repository.getCollector(eventId, userId);
    if (me.isLeft) return Right((view: AlbumRankingView(top: top.right), complete: false));
    if (me.right == null) return Right((view: AlbumRankingView(top: top.right), complete: true));
    final ahead = await _repository.collectorsAhead(eventId, me.right!.collected);
    return Right((
      view: AlbumRankingView(top: top.right, me: me.right, myPosition: ahead.isRight ? ahead.right + 1 : null),
      complete: ahead.isRight,
    ));
  }

  /// [getRanking] pelo fluxo [cacheFirst] (validade
  /// [CacheTtl.albumRanking]) por evento e conta; [force] (puxar para
  /// atualizar) ignora a validade. Pedir pacote apaga (as functions mudam o
  /// ranking da conta); falha não vai para o cache.
  Future<Either<Failure, AlbumRankingView>> getRankingCacheFirst({
    required String eventId,
    required String userId,
    bool force = false,
  }) {
    var complete = true;
    return cacheFirst<AlbumRankingView>(
      readCache: () => _repository.getCachedRanking(eventId: eventId, userId: userId),
      fetchRemote: () async {
        final result = await _fetchRanking(eventId: eventId, userId: userId);
        if (result.isLeft) return Left(result.left);
        complete = result.right.complete;
        return Right(result.right.view);
      },
      saveCache: (view) => complete
          ? _repository.saveRankingCache(view, eventId: eventId, userId: userId)
          : Future.value(const Right<Failure, void>(null)),
      ttl: CacheTtl.albumRanking,
      force: force,
      logName: 'AlbumUseCase.getRankingCacheFirst',
    ).last;
  }

  /// O pacote pedido (o sorteio do servidor chega por aqui).
  Stream<Either<Failure, AlbumPackDTO?>> watchPack(String packId) => _repository.watchPack(packId);

  /// Pede o próximo pacote da conta (que já abriu [opened]); devolve o id
  /// para acompanhar o sorteio. [extra] = pacotinho extra da indicação.
  Future<Either<Failure, String>> openPack({
    required String userId,
    required String eventId,
    required int opened,
    bool extra = false,
  }) async {
    final packId = AlbumPackId.next(eventId: eventId, userId: userId, opened: opened);
    final response = await _repository.requestPack(packId: packId, userId: userId, eventId: eventId, extra: extra);
    return response.map((_) => packId);
  }
}
