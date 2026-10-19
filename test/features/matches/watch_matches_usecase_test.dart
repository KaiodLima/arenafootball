import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/matches_filter.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/matches/domain/usecases/watch_matches_usecase.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/matches_tab.dart';

const _matches = [
  MatchDTO(id: 'a', homeTeam: 'Lava Jato', awayTeam: 'Volta', date: '31/10', championshipId: 1),
  MatchDTO(id: 'b', homeTeam: 'Parceiros', awayTeam: 'Volta', date: '01/11', championshipId: 1),
  MatchDTO(id: 'c', homeTeam: 'Lava Jato', awayTeam: 'Parceiros', date: '02/11', championshipId: 1),
  MatchDTO(id: 'd', homeTeam: 'Outro', awayTeam: 'Time', date: '01/11', championshipId: 2),
  MatchDTO(id: 'e', homeTeam: 'Amigos', awayTeam: 'Volta', date: '01/11'),
];

class _FakeRepository implements IMatchesRepository {
  @override
  Stream<Either<Failure, List<MatchDTO>>> watchMatches({String? season, String? region}) =>
      Stream.value(const Right(_matches));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final useCase = WatchMatchesUseCase(_FakeRepository());
  final now = DateTime(2026, 11, 1, 23, 30);

  Future<List<String>> ids(MatchesFilter filter) async {
    final response = await useCase(championshipId: 1, filter: filter, now: now).first;
    return response.right.map((m) => m.id).toList();
  }

  test('ontem, hoje e amanhã atravessam a virada do mês', () async {
    expect(await ids(MatchesFilter.yesterday), ['a']);
    expect(await ids(MatchesFilter.today), ['b']);
    expect(await ids(MatchesFilter.tomorrow), ['c']);
  });

  test('todos: sem recorte por data, só o campeonato', () async {
    expect(await ids(MatchesFilter.all), ['a', 'b', 'c']);
  });

  test('todas as competições: o mesmo dia de qualquer competição e amistosos', () async {
    final response = await useCase(filter: MatchesFilter.today, now: now).first;
    expect(response.right.map((m) => m.id), ['b', 'd', 'e']);
  });

  test('aba: competições da temporada, inclusive intermunicipal com sede em outra região', () {
    const all = [
      ChampionshipDTO(
          id: 'x', championshipId: 9, region: 'Santo inacio', season: '2026', scope: ChampionshipScope.intermunicipal),
      ChampionshipDTO(id: 'y', championshipId: 3, region: 'Floresta', season: '2026'),
      ChampionshipDTO(id: 'z', championshipId: 1, region: 'Floresta', season: '2024'),
    ];
    expect(tableChampionships(all, season: '2026').map((c) => c.championshipId), [3, 9]);
  });
}
