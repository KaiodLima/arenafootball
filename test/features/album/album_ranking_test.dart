import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/domain/repositories/album_repository_interface.dart';
import 'package:arena_soccer/features/album/domain/usecases/album_usecase.dart';

class _Repository implements IAlbumRepository {
  final List<AlbumRankingEntryDTO> top;
  final AlbumRankingEntryDTO? me;
  final int ahead;

  _Repository({this.top = const [], this.me, this.ahead = 0});

  @override
  Future<Either<Failure, List<AlbumRankingEntryDTO>>> getTopCollectors(String eventId) async => Right(top);

  @override
  Future<Either<Failure, AlbumRankingEntryDTO?>> getCollector(String eventId, String userId) async => Right(me);

  @override
  Future<Either<Failure, int>> collectorsAhead(String eventId, int collected) async => Right(ahead);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final t1 = DateTime(2026, 10, 1);
  final t2 = DateTime(2026, 10, 2);

  test('ranking: mais coladas; empate = quem chegou primeiro; depois o nome', () {
    final sorted = AlbumRankingEntryDTO.sorted([
      AlbumRankingEntryDTO(userId: 'c', name: 'Caio', collected: 10, reachedAt: t2),
      AlbumRankingEntryDTO(userId: 'a', name: 'Ana', collected: 12, reachedAt: t2),
      AlbumRankingEntryDTO(userId: 'b', name: 'Bia', collected: 10, reachedAt: t1),
      const AlbumRankingEntryDTO(userId: 'z', name: 'Zé', collected: 10),
      AlbumRankingEntryDTO(userId: 'd', name: 'Davi', collected: 10, reachedAt: t2),
    ]);
    expect(sorted.map((e) => e.userId), ['a', 'b', 'c', 'd', 'z']);
  });

  test('figurinha rara: lida e gravada no campo rara', () {
    const rare = StickerDTO(id: 'x', name: 'Craque', rare: true);
    expect(rare.toMap()['rara'], isTrue);
    expect(rare.copyWith(rare: false).rare, isFalse);
    expect(const StickerDTO(id: 'y').toMap()['rara'], isFalse);
  });

  group('posição da conta', () {
    final top = [
      AlbumRankingEntryDTO(userId: 'a', collected: 12, reachedAt: t1),
      AlbumRankingEntryDTO(userId: 'u1', collected: 10, reachedAt: t1),
    ];

    test('dentro do top: a posição na lista, sem leitura extra', () async {
      final view = (await AlbumUseCase(_Repository(top: top)).getRanking(eventId: 'ev', userId: 'u1')).right;
      expect(view.myPosition, 2);
      expect(view.me?.userId, 'u1');
    });

    test('fora do top: quem tem mais coladas + 1', () async {
      final repo = _Repository(top: top, me: const AlbumRankingEntryDTO(userId: 'u9', collected: 3), ahead: 57);
      final view = (await AlbumUseCase(repo).getRanking(eventId: 'ev', userId: 'u9')).right;
      expect(view.myPosition, 58);
    });

    test('ainda não abriu pacote: sem linha', () async {
      final view = (await AlbumUseCase(_Repository(top: top)).getRanking(eventId: 'ev', userId: 'u9')).right;
      expect(view.me, isNull);
      expect(view.myPosition, isNull);
    });
  });
}
