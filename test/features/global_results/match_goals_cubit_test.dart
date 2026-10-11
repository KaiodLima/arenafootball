import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_match_dto.dart';
import 'package:arena_soccer/features/global_results/domain/entities/global_match.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';
import 'package:arena_soccer/features/global_results/domain/repositories/global_results_repository_interface.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_match_goals_usecase.dart';
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
}

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
    final cubit = MatchGoalsCubit(GetMatchGoalsUseCase(repository));

    await cubit.load(_match);
    await cubit.load(_match);

    expect(repository.calls, 1);
    expect(cubit.state[_match.detailsUrl]!.status, GoalsStatus.loaded);
    expect(cubit.state[_match.detailsUrl]!.goals.single.scorer, 'Fulano');
  });

  test('falha marca o jogo e permite tentar de novo', () async {
    final repository = _FakeRepository()..fail = true;
    final cubit = MatchGoalsCubit(GetMatchGoalsUseCase(repository));

    await cubit.load(_match);
    expect(cubit.state[_match.detailsUrl]!.status, GoalsStatus.failed);

    repository.fail = false;
    await cubit.load(_match);
    expect(repository.calls, 2);
    expect(cubit.state[_match.detailsUrl]!.status, GoalsStatus.loaded);
  });
}
