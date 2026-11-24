import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/preferences_service.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_cache_first_usecase.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_stats_ranking_cache_first_usecase.dart';
import 'package:arena_soccer/features/stats/presentation/bloc/stats_ranking_cubit.dart';

class _Ranking implements GetStatsRankingCacheFirstUseCase {
  final asked = <int?>[];

  @override
  Stream<Either<Failure, StatsRanking>> call({
    required StatsRankingType type,
    required String region,
    String? season,
    int? championshipId,
    bool force = false,
  }) {
    asked.add(championshipId);
    return Stream.value(const Right(StatsRanking()));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Championships implements GetRegionChampionshipsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<ChampionshipDTO>>> call(
          {required String region, required String season, bool force = false}) =>
      Stream.value(
          const Right([ChampionshipDTO(id: 'a', championshipId: 1), ChampionshipDTO(id: 'b', championshipId: 2)]));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('preferências: grava, lê por região/temporada e "todas" apaga', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PreferencesService();
    expect(await prefs.getChampionshipFilter('Floresta', '2026'), isNull);
    await prefs.setChampionshipFilter('Floresta', '2026', 2);
    expect(await prefs.getChampionshipFilter('Floresta', '2026'), 2);
    expect(await prefs.getChampionshipFilter('Floresta', '2025'), isNull);
    await prefs.setChampionshipFilter('Floresta', '2026', null);
    expect(await prefs.getChampionshipFilter('Floresta', '2026'), isNull);
  });

  test('artilharia: abre no filtro guardado, argumento explícito vence e a escolha grava', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PreferencesService();
    await prefs.setChampionshipFilter('Floresta', '2026', 2);

    final ranking = _Ranking();
    final cubit = StatsRankingCubit(ranking, _Championships(), prefs);
    await cubit.open(type: StatsRankingType.goals, region: 'Floresta', season: '2026');
    expect(cubit.state.championshipId, 2);
    cubit.setChampionship(1);
    await Future<void>.delayed(Duration.zero);
    expect(await prefs.getChampionshipFilter('Floresta', '2026'), 1);
    await cubit.close();

    final explicit = StatsRankingCubit(_Ranking(), _Championships(), prefs);
    await explicit.open(type: StatsRankingType.goals, region: 'Floresta', season: '2026', championshipId: 2);
    expect(explicit.state.championshipId, 2);
    expect(await prefs.getChampionshipFilter('Floresta', '2026'), 1, reason: 'abrir não grava');
    await explicit.close();
  });

  test('artilharia: competição guardada que não existe mais volta ao geral', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PreferencesService();
    await prefs.setChampionshipFilter('Floresta', '2026', 9);
    final cubit = StatsRankingCubit(_Ranking(), _Championships(), prefs);
    await cubit.open(type: StatsRankingType.goals, region: 'Floresta', season: '2026');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state.championshipId, isNull);
    await cubit.close();
  });
}
