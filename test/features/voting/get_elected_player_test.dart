import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';
import 'package:arena_soccer/features/voting/domain/elected_player.dart';
import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';
import 'package:arena_soccer/features/voting/domain/usecases/calculate_best_player_usecase.dart';
import 'package:arena_soccer/features/voting/domain/usecases/get_elected_player_usecase.dart';

class _FakeTally implements CalculateBestPlayerUseCase {
  @override
  Future<Either<Failure, List<VoteTally>>> call(MatchVoteRef ref) async =>
      const Right([VoteTally(playerName: 'Carlos', team: 'Lava Jato', votes: 3)]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTeams implements GetTeamsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) =>
      Stream.fromFuture(_load(region: region, season: season));

  Future<Either<Failure, List<TeamDTO>>> _load({String? region, String? season}) async => const Right([
        TeamDTO(id: '1', name: 'Lava Jato', imageUrl: 'lj.png', primaryColor: '#1B8E2D', secondaryColor: '#FFFFFF'),
        TeamDTO(id: '2', name: 'Real', imageUrl: 'real.png', primaryColor: '#111111'),
      ]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakePlayers implements WatchTeamPlayersUseCase {
  @override
  Stream<Either<Failure, List<PlayerDTO>>> call({String teamId = '', required String teamName, String? season}) =>
      Stream.value(const Right([PlayerDTO(name: 'Carlos', team: 'Lava Jato', goals: 8, assists: 4)]));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('apuração traz escudos e cores do mandante e do visitante', () async {
    final useCase = GetElectedPlayerUseCase(_FakeTally(), _FakeTeams(), _FakePlayers());
    final result =
        (await useCase(const MatchVoteRef(matchId: 'm1', season: '2024', homeTeam: 'Lava Jato', awayTeam: 'Real')))
            .right;

    expect(result.homeCrest, 'lj.png');
    expect(result.homePrimaryColor, '#1B8E2D');
    expect(result.homeSecondaryColor, '#FFFFFF');
    expect(result.awayPrimaryColor, '#111111');
    expect(result.awaySecondaryColor, '');
    expect(result.elected?.goals, 8);
  });

  test('pelo id: acha o time mesmo com outro nome gravado na partida', () async {
    final useCase = GetElectedPlayerUseCase(_FakeTally(), _FakeTeams(), _FakePlayers());
    final result = (await useCase(const MatchVoteRef(
      matchId: 'm1',
      season: '2024',
      homeTeam: 'Nome antigo',
      awayTeam: 'Real',
      homeTeamId: '1',
    )))
        .right;

    expect(result.homeCrest, 'lj.png');
    expect(result.homePrimaryColor, '#1B8E2D');
  });

  test('time não cadastrado: cores vazias (o card usa as do app)', () async {
    final useCase = GetElectedPlayerUseCase(_FakeTally(), _FakeTeams(), _FakePlayers());
    final result = (await useCase(
            const MatchVoteRef(matchId: 'm1', season: '2024', homeTeam: 'Lava Jato', awayTeam: 'Desconhecido')))
        .right;

    expect(result.awayPrimaryColor, '');
    expect(result.awayCrest, '');
  });
}
