import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/features/fan_ranking/data/dtos/fan_ranking_dto.dart';
import 'package:arena_soccer/features/fan_ranking/domain/usecases/get_fan_ranking_cache_first_usecase.dart';
import 'package:arena_soccer/features/fan_ranking/presentation/bloc/fan_ranking_cubit.dart';

const _ranking = FanRankingDTO(season: '2026', entries: [
  FanRankingEntry(teamId: '1', name: 'Açaí no Gralle', regionId: 'fl', region: 'Floresta', fans: 9),
  FanRankingEntry(teamId: '9', name: 'Riacho', regionId: 'si', region: 'Santo inacio', fans: 7),
  FanRankingEntry(teamId: '2', name: 'Lava Jato', regionId: 'fl', region: 'Floresta', fans: 4),
  FanRankingEntry(teamId: '3', name: 'Volta', regionId: 'fl', region: 'Floresta', fans: 4),
  FanRankingEntry(teamId: '4', name: 'Bairro', region: 'Floresta'),
]);

class _FakeRanking implements GetFanRankingCacheFirstUseCase {
  Either<Failure, FanRankingDTO> response = const Right(_ranking);

  @override
  Stream<Either<Failure, FanRankingDTO>> call({required String season, bool force = false}) => Stream.value(response);
}

void main() {
  setUp(() => RegionRegistry.configure(const [
        RegionRef(id: 'fl', name: 'Floresta'),
        RegionRef(id: 'si', name: 'Santo inacio'),
      ]));
  tearDown(RegionRegistry.reset);

  test('DTO: cache vai e volta', () {
    final ranking = FanRankingDTO(season: '2026', updatedAt: DateTime(2026, 10, 17, 14), entries: _ranking.entries);
    expect(FanRankingDTO.fromCache(ranking.toCache()), ranking);
  });

  test('região pelo id (renomeada continua) e, doc sem id, pelo nome', () {
    expect(_ranking.entriesOf('Floresta').map((e) => e.teamId), ['1', '2', '3', '4']);
    expect(_ranking.entriesOf('Santo inacio').single.teamId, '9');
    RegionRegistry.configure(const [RegionRef(id: 'fl', name: 'Floresta do Norte')]);
    expect(_ranking.entriesOf('Floresta do Norte').map((e) => e.teamId), ['1', '2', '3']);
  });

  group('FanRankingCubit', () {
    late _FakeRanking fake;
    late FanRankingCubit cubit;

    setUp(() {
      fake = _FakeRanking();
      cubit = FanRankingCubit(fake);
    });
    tearDown(() => cubit.close());

    test('carrega, filtra pela região e empate divide a posição', () async {
      await cubit.load(season: '2026', region: 'Floresta');
      expect(cubit.state.loading, isFalse);
      expect(cubit.state.entries.length, 4);
      expect(cubit.state.positionOf(teamId: '2'), 2);
      expect(cubit.state.positionOf(teamId: '3'), 2);
      expect(cubit.state.positionOf(teamId: '4'), 4);
      expect(cubit.state.positionOf(teamName: 'Riacho'), isNull);
      cubit.selectRegion('Santo inacio');
      expect(cubit.state.positionOf(teamId: '9'), 1);
    });

    test('ranking ainda não gerado: vazio; falha sem cache: erro', () async {
      fake.response = const Right(FanRankingDTO(season: '2026'));
      await cubit.load(season: '2026', region: 'Floresta');
      expect(cubit.state.ranking?.isEmpty, isTrue);

      final other = FanRankingCubit(_FakeRanking()..response = Left(ErrorWithMessage('sem rede')));
      await other.load(season: '2026', region: 'Floresta');
      expect(other.state.ranking, isNull);
      expect(other.state.errorMessage, 'sem rede');
      await other.close();
    });
  });
}
