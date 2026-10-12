import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/matches_filter.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/matches/domain/usecases/watch_matches_usecase.dart';

const _matches = [
  MatchDTO(id: 'a', homeTeam: 'Lava Jato', awayTeam: 'Volta', date: '31/10', championshipId: 1),
  MatchDTO(id: 'b', homeTeam: 'Parceiros', awayTeam: 'Volta', date: '01/11', championshipId: 1),
  MatchDTO(id: 'c', homeTeam: 'Lava Jato', awayTeam: 'Parceiros', date: '02/11', championshipId: 1),
  MatchDTO(id: 'd', homeTeam: 'Outro', awayTeam: 'Time', date: '01/11', championshipId: 2),
];

class _FakeRepository implements IMatchesRepository {
  @override
  Stream<Either<Failure, List<MatchDTO>>> watchMatches({String? season}) => Stream.value(const Right(_matches));

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
}
