import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_match_dto.dart';
import 'package:arena_soccer/features/global_results/domain/entities/global_match.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';
import 'package:arena_soccer/features/global_results/domain/repositories/global_results_repository_interface.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_cached_match_goals_usecase.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_match_goals_cache_first_usecase.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_match_goals_usecase.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/save_match_goals_cache_usecase.dart';
import 'package:arena_soccer/features/global_results/presentation/bloc/match_goals_cubit.dart';

class _FakeRepository implements IGlobalResultsRepository {
  int calls = 0;
  bool fail = false;

  @override
  Future<Either<Failure, List<ScrapedGoalDTO>>> getMatchGoals(String url) async {
    calls++;
    if (fail) return Left(ErrorWithMessage('erro'));
    return const Right([ScrapedGoalDTO(homeScore: 1, awayScore: 0, scorer: 'Fulano', minute: '10', isHome: true)]);
  }

  @override
  Future<Either<Failure, List<ScrapedMatchDTO>>> getMatches(ResultsDay day) async => const Right([]);

  /// Cache local em memória (o real é o Hive), por URL.
  final goalsCache = <String, CachedValue<List<ScrapedGoalDTO>>>{};

  @override
  Future<Either<Failure, CachedValue<List<ScrapedGoalDTO>>?>> getCachedMatchGoals(String url) async =>
      Right(goalsCache[url]);

  @override
  Future<Either<Failure, void>> saveMatchGoalsCache(String url, List<ScrapedGoalDTO> goals) async {
    goalsCache[url] = CachedValue(goals, DateTime.now());
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

MatchGoalsCubit _cubit(_FakeRepository repository) => MatchGoalsCubit(GetMatchGoalsCacheFirstUseCase(
      GetMatchGoalsUseCase(repository),
      GetCachedMatchGoalsUseCase(repository),
      SaveMatchGoalsCacheUseCase(repository),
    ));

const _match = GlobalMatch(
  league: 'L',
  homeTeam: 'A',
  awayTeam: 'B',
  status: MatchStatus.finished,
  homeGoals: 1,
  awayGoals: 0,
  detailsUrl: 'https://x/round_details.asp?m=1',
);

void main() {
  test('carrega uma vez e guarda no cache', () async {
    final repository = _FakeRepository();
    final cubit = _cubit(repository);

    await cubit.load(_match);
    await cubit.load(_match);

    expect(repository.calls, 1);
    expect(cubit.state[_match.detailsUrl]!.status, GoalsStatus.loaded);
    expect(cubit.state[_match.detailsUrl]!.goals.single.scorer, 'Fulano');
  });

  test('cache local: reaberto dentro da validade não refaz o scraping', () async {
    final repository = _FakeRepository();
    await _cubit(repository).load(_match);
    final reopened = _cubit(repository);
    await reopened.load(_match);
    expect(repository.calls, 1);
    expect(reopened.state[_match.detailsUrl]!.goals.single.scorer, 'Fulano');
  });

  test('cache local vencido: mostra o cache e busca de novo', () async {
    final repository = _FakeRepository();
    repository.goalsCache[_match.detailsUrl] = CachedValue(
      const [ScrapedGoalDTO(homeScore: 1, awayScore: 0, scorer: 'Antigo', minute: '5', isHome: true)],
      DateTime.now().subtract(const Duration(minutes: 10)),
    );
    final cubit = _cubit(repository);
    final scorers = <String>[];
    final sub = cubit.stream.listen((s) {
      final goals = s[_match.detailsUrl]?.goals ?? const [];
      if (goals.isNotEmpty) scorers.add(goals.single.scorer);
    });
    await cubit.load(_match);
    await Future<void>.delayed(Duration.zero);
    expect(scorers, ['Antigo', 'Fulano']);
    expect(repository.calls, 1);
    await sub.cancel();
  });

  test('falha marca o jogo e permite tentar de novo', () async {
    final repository = _FakeRepository()..fail = true;
    final cubit = _cubit(repository);

    await cubit.load(_match);
    expect(cubit.state[_match.detailsUrl]!.status, GoalsStatus.failed);

    repository.fail = false;
    await cubit.load(_match);
    expect(repository.calls, 2);
    expect(cubit.state[_match.detailsUrl]!.status, GoalsStatus.loaded);
  });
}
