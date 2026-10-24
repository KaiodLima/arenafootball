import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/matches/data/datasources/matches_datasource.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/matches/domain/usecases/update_match_goals_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_goals_cubit.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';

const _match = MatchDTO(
  id: 'm1',
  homeTeam: 'Lava Jato',
  awayTeam: 'Volta',
  homeTeamId: '1',
  awayTeamId: '2',
  championshipId: 7,
  homeGoals: 1,
  awayGoals: 0,
);

const _dudu = PlayerDTO(id: 'dudu', name: 'Dudu', team: 'Lava Jato', teamId: '1');
const _ana = PlayerDTO(id: 'ana', name: 'Ana', team: 'Lava Jato', teamId: '1');

class _Matches implements IMatchesRepository {
  List<MatchGoal>? saved;

  @override
  Future<Either<Failure, void>> updateGoals(
      {required String matchId, required List<MatchGoal> goals, String? season}) async {
    saved = goals;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Players implements IPlayersRepository {
  final calls = <String>[];

  @override
  Future<Either<Failure, int>> repairTotals(
    Map<String, ({int goals, int assists})> friendlyCounts, {
    String? season,
  }) async =>
      const Right(0);

  @override
  Future<Either<Failure, void>> incrementStats({
    required String playerId,
    int goals = 0,
    int assists = 0,
    PlayerEnrollment? enrollment,
    bool friendly = false,
    String? season,
  }) async {
    calls.add(
        '$playerId:g$goals:a$assists:c${enrollment?.championshipId}/${enrollment?.teamId}${friendly ? ':amistoso' : ''}');
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Squads implements WatchTeamPlayersUseCase {
  @override
  Stream<Either<Failure, List<PlayerDTO>>> call({String teamId = '', required String teamName, String? season}) =>
      Stream.value(Right(teamName == 'Lava Jato'
          ? [
              _dudu,
              _ana,
              // Joga a competição 7 pelo outro time: fora do elenco do Lava Jato nela.
              const PlayerDTO(id: 'leo', name: 'Leo', team: 'Lava Jato', teamId: '1', enrollments: [
                PlayerEnrollment(championshipId: 7, teamId: '2', team: 'Volta'),
              ]),
            ]
          : const []));
}

void main() {
  var seq = 0;
  String newId() => 'g${seq++}';

  group('MatchGoal', () {
    test('vai e volta do Firestore', () {
      const goal = MatchGoal(
          id: 'a',
          side: MatchSide.away,
          scorerId: 'dudu',
          scorerName: 'Dudu',
          assistantId: 'ana',
          assistantName: 'Ana');
      expect(MatchGoal.fromMap(goal.toMap()), goal);
      expect(MatchGoal.listFrom([goal.toMap()]), [goal]);
    });

    test('partida antiga: um gol sem autor para cada gol do placar', () {
      seq = 0;
      final list = MatchGoal.forEditing(saved: const [], homeGoals: 2, awayGoals: 1, newId: newId);
      expect(list.map((g) => g.side), [MatchSide.home, MatchSide.home, MatchSide.away]);
      expect(list.every((g) => !g.hasScorer), isTrue);
    });

    test('diferença nos números: acrescentar, tirar, trocar autor e sem autor', () {
      const a = MatchGoal(id: 'a', side: MatchSide.home, scorerId: 'dudu', assistantId: 'ana');
      const b = MatchGoal(id: 'b', side: MatchSide.home);
      // Acrescentou "a" e um gol sem autor.
      var delta = MatchGoal.statsDelta(const [], const [a, b]);
      expect(delta['dudu'], (goals: 1, assists: 0, side: MatchSide.home));
      expect(delta['ana'], (goals: 0, assists: 1, side: MatchSide.home));
      expect(delta.length, 2);
      // Tirou "a".
      delta = MatchGoal.statsDelta(const [a, b], const [b]);
      expect(delta['dudu']?.goals, -1);
      expect(delta['ana']?.assists, -1);
      // Trocou o autor de "a" para Ana, sem assistência.
      delta = MatchGoal.statsDelta(const [a], [a.copyWith(scorerId: 'ana', assistantId: '')]);
      expect(delta['dudu']?.goals, -1);
      expect(delta['ana'], (goals: 1, assists: -1, side: MatchSide.home));
      // Assistência do próprio autor: só o gol.
      delta = MatchGoal.statsDelta(
          const [], const [MatchGoal(id: 'c', side: MatchSide.away, scorerId: 'dudu', assistantId: 'dudu')]);
      expect(delta['dudu'], (goals: 1, assists: 0, side: MatchSide.away));
    });

    test('placar gravado é a contagem da lista', () {
      final fields = MatchesDataSource.goalsFields(const [
        MatchGoal(id: 'a', side: MatchSide.home),
        MatchGoal(id: 'b', side: MatchSide.away),
        MatchGoal(id: 'c', side: MatchSide.home),
      ]);
      expect([fields['golTimeCasa'], fields['golTimeFora']], [2, 1]);
    });
  });

  test('salvar grava a lista e soma nos atletas pela competição e time do lado', () async {
    final matches = _Matches();
    final players = _Players();
    final result = await UpdateMatchGoalsUseCase(matches, players)(
      match: _match,
      before: const [MatchGoal(id: 'old', side: MatchSide.home)],
      after: const [
        MatchGoal(id: 'old', side: MatchSide.home, scorerId: 'dudu', assistantId: 'ana'),
        MatchGoal(id: 'new', side: MatchSide.away),
      ],
    );
    expect(result.right.homeGoals, 1);
    expect(result.right.awayGoals, 1);
    expect(matches.saved?.length, 2);
    expect(players.calls.toSet(), {'dudu:g1:a0:c7/1', 'ana:g0:a1:c7/1'});
  });

  test('amistoso: o gol vai para a contagem à parte, fora do geral', () async {
    final players = _Players();
    await UpdateMatchGoalsUseCase(_Matches(), players)(
      match: const MatchDTO(id: 'f', homeTeam: 'Lava Jato', awayTeam: 'Volta', homeTeamId: '1', awayTeamId: '2'),
      before: const [],
      after: const [MatchGoal(id: 'n', side: MatchSide.home, scorerId: 'dudu')],
    );
    expect(players.calls, ['dudu:g1:a0:cnull/null:amistoso']);
  });

  test('cubit: elenco da competição; acrescentar e tirar mudam o placar e salvar fecha', () async {
    seq = 0;
    final matches = _Matches();
    final cubit = MatchGoalsCubit(_Squads(), UpdateMatchGoalsUseCase(matches, _Players()));
    await cubit.load(match: _match, newId: newId);
    expect(cubit.state.homeSquad.map((p) => p.id), ['ana', 'dudu']);
    expect([cubit.state.homeGoals, cubit.state.awayGoals], [1, 0]);
    expect(cubit.state.dirty, isFalse);

    cubit.addGoal(MatchSide.home, scorer: _dudu, assistant: _ana, newId: newId);
    expect(cubit.state.homeGoals, 2);
    cubit.removeGoal(cubit.state.goals.first.id);
    expect(cubit.state.homeGoals, 1);
    expect(cubit.state.dirty, isTrue);

    await cubit.save();
    expect(cubit.state.saved, isTrue);
    expect(matches.saved?.single.scorerId, 'dudu');
    await cubit.close();
  });
}
