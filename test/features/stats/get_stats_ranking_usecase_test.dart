import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/datasources/players_datasource.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/players/domain/usecases/get_top_players_in_championship_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/get_top_players_usecase.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_stats_ranking_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

PlayerDTO _player(String id, String teamId, {int goals = 0, int assists = 0}) =>
    PlayerDTO(id: id, name: id, team: 'Time $teamId', teamId: teamId, goals: goals, assists: assists);

class _FakeTeams implements GetTeamsCacheFirstUseCase {
  final List<TeamDTO> teams;

  _FakeTeams(this.teams);

  @override
  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) =>
      Stream.fromFuture(_load(region: region, season: season));

  Future<Either<Failure, List<TeamDTO>>> _load({String? region, String? season}) async => Right(teams);
}

/// Simula a consulta do DataSource: blocos de até 30 ids, cada um ordenado e
/// limitado, depois juntados. Guarda os blocos e o quesito pedidos.
class _FakeTopPlayers implements GetTopPlayersUseCase {
  final List<PlayerDTO> players;
  final chunks = <List<String>>[];
  String? field;

  _FakeTopPlayers(this.players);

  @override
  Future<Either<Failure, List<PlayerDTO>>> call({
    required List<String> teamIds,
    required String field,
    int limit = 50,
    String? season,
  }) async {
    this.field = field;
    final perChunk = <List<PlayerDTO>>[];
    for (final chunk in PlayersDataSource.chunkIds(teamIds)) {
      chunks.add(chunk);
      final top = players.where((p) => chunk.contains(p.teamId)).toList()
        ..sort((a, b) => b.statOf(field).compareTo(a.statOf(field)));
      perChunk.add(top.take(limit).toList());
    }
    return Right(PlayersDataSource.mergeTopPlayers(perChunk, field: field, limit: limit));
  }
}

/// Ordena pelos números da inscrição na competição (como a consulta).
class _FakeTopInChampionship implements GetTopPlayersInChampionshipUseCase {
  final List<PlayerDTO> players;

  _FakeTopInChampionship(this.players);

  @override
  Future<Either<Failure, List<PlayerDTO>>> call({
    required int championshipId,
    required String field,
    int limit = 50,
    String? season,
  }) async =>
      Right(players.where((p) => p.enrollmentIn(championshipId) != null).toList()
        ..sort((a, b) => b.statIn(field, championshipId).compareTo(a.statIn(field, championshipId))));
}

void main() {
  group('PlayersDataSource.chunkIds', () {
    test('mais de 30 ids viram blocos de até 30, sem vazios nem repetidos', () {
      final ids = [for (var i = 0; i < 65; i++) 't$i', '', 't0'];
      final chunks = PlayersDataSource.chunkIds(ids);
      expect(chunks.map((c) => c.length), [30, 30, 5]);
      expect(chunks.expand((c) => c).toSet().length, 65);
      expect(chunks.expand((c) => c), isNot(contains('')));
    });

    test('sem ids, sem consulta', () {
      expect(PlayersDataSource.chunkIds(const ['']), isEmpty);
    });
  });

  group('PlayersDataSource.mergeTopPlayers', () {
    test('junta os blocos em ordem decrescente e corta no limite', () {
      final merged = PlayersDataSource.mergeTopPlayers(
        [
          [_player('a', '1', goals: 9), _player('b', '1', goals: 2)],
          [_player('c', '40', goals: 7), _player('d', '40', goals: 2)],
        ],
        field: PlayerDTO.goalsField,
        limit: 3,
      );
      expect(merged.map((p) => p.id), ['a', 'c', 'b']);
    });
  });

  group('GetStatsRankingUseCase', () {
    test('mais de 30 times: consulta em blocos e ranking juntado', () async {
      final teams = [
        for (var i = 0; i < 35; i++) TeamDTO(id: 't$i', name: 'Time t$i', region: 'Floresta'),
        const TeamDTO(id: '', name: 'Sem id', region: 'Floresta'),
      ];
      final top = _FakeTopPlayers([
        _player('a', 't0', goals: 4),
        _player('b', 't34', goals: 8),
        _player('c', 't31', goals: 6),
        _player('fora', 'outra', goals: 20),
      ]);
      final result = await GetStatsRankingUseCase(_FakeTeams(teams), top)(
        type: StatsRankingType.goals,
        region: 'Floresta',
      );

      expect(top.chunks.map((c) => c.length), [30, 5]);
      expect(top.field, PlayerDTO.goalsField);
      expect(result.right.entries.map((e) => e.player.id), ['b', 'c', 'a']);
      expect(result.right.entries.map((e) => e.position), [1, 2, 3]);
    });

    test('empate divide a posição e mantém a ordem; zero não entra', () async {
      const teams = [TeamDTO(id: '1', name: 'Time 1', region: 'Floresta', imageUrl: 'https://img/1.png')];
      final top = _FakeTopPlayers([
        _player('a', '1', assists: 3),
        _player('b', '1', assists: 5),
        _player('c', '1', assists: 3),
        _player('zero', '1'),
      ]);
      final result = await GetStatsRankingUseCase(_FakeTeams(teams), top)(
        type: StatsRankingType.assists,
        region: 'Floresta',
      );

      expect(top.field, PlayerDTO.assistsField);
      expect(result.right.entries.map((e) => e.player.id), ['b', 'a', 'c']);
      expect(result.right.entries.map((e) => e.position), [1, 2, 2]);
      expect(result.right.crests, {'Time 1': 'https://img/1.png'});
    });
  });

  test('ranking da competição: números e time da inscrição', () async {
    const teams = [
      TeamDTO(id: '1', name: 'Lava Jato', region: 'Floresta'),
      TeamDTO(id: '2', name: 'Volta', region: 'Floresta'),
    ];
    const dudu = PlayerDTO(id: 'dudu', name: 'Dudu', team: 'Lava Jato', teamId: '1', goals: 9, enrollments: [
      PlayerEnrollment(championshipId: 7, teamId: '2', team: 'Volta', goals: 2),
      PlayerEnrollment(championshipId: 9, teamId: '1', team: 'Lava Jato', goals: 7),
    ]);
    const ana = PlayerDTO(id: 'ana', name: 'Ana', team: 'Volta', teamId: '2', goals: 3, enrollments: [
      PlayerEnrollment(championshipId: 7, teamId: '2', team: 'Volta', goals: 3),
    ]);
    final result = await GetStatsRankingUseCase(
      _FakeTeams(teams),
      _FakeTopPlayers(const []),
      _FakeTopInChampionship(const [dudu, ana]),
    )(type: StatsRankingType.goals, region: 'Floresta', championshipId: 7);

    expect(result.right.entries.map((e) => e.player.id), ['ana', 'dudu']);
    expect(result.right.entries.map((e) => e.value), [3, 2]);
    // Na Copa, Dudu aparece pelo Volta (time da inscrição), não pelo principal.
    expect(result.right.entries.last.player.team, 'Volta');
  });
}
