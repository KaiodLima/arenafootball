import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_cache_first_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_season_championships_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/set_team_championships_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/players/presentation/bloc/team_players_cubit.dart';
import 'package:arena_soccer/features/teams/domain/usecases/delete_team_usecase.dart';

/// Elenco geral do Lava Jato (id 1): Dudu joga a Copa (7) por ele e a Liga
/// (9) pelo Volta; Ana só a Liga pelo Lava Jato; Rafa é antigo (sem inscrição).
const _players = [
  PlayerDTO(id: 'dudu', name: 'Dudu', team: 'Lava Jato', teamId: '1', goals: 5, enrollments: [
    PlayerEnrollment(championshipId: 7, teamId: '1', team: 'Lava Jato', goals: 3),
    PlayerEnrollment(championshipId: 9, teamId: '2', team: 'Volta', goals: 2),
  ]),
  PlayerDTO(id: 'ana', name: 'Ana', team: 'Lava Jato', teamId: '1', goals: 1, enrollments: [
    PlayerEnrollment(championshipId: 9, teamId: '1', team: 'Lava Jato', goals: 1),
  ]),
  PlayerDTO(id: 'rafa', name: 'Rafa', team: 'Lava Jato', teamId: '1', goals: 4),
];

class _Watch implements WatchTeamPlayersUseCase {
  @override
  Stream<Either<Failure, List<PlayerDTO>>> call({String teamId = '', required String teamName, String? season}) =>
      Stream.value(const Right(_players));
}

class _Championships implements GetRegionChampionshipsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<ChampionshipDTO>>> call(
          {required String region, required String season, bool force = false}) =>
      Stream.value(const Right([
        ChampionshipDTO(id: 'b', championshipId: 9, title: 'Liga', teams: ['Lava Jato'], teamIds: ['1']),
        ChampionshipDTO(id: 'a', championshipId: 7, title: 'Copa', teams: ['Lava Jato'], teamIds: ['1']),
        ChampionshipDTO(id: 'c', championshipId: 11, title: 'Outra', teams: ['Riacho'], teamIds: ['3']),
      ]));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Guarda as inscrições pedidas e conta as recargas das chips.
class _ChampionshipsRepo implements IChampionshipsRepository {
  final calls = <String>[];

  @override
  Future<Either<Failure, List<ChampionshipDTO>>> getSeasonChampionships(String season) async => const Right([
        ChampionshipDTO(
            id: 'a', championshipId: 7, title: 'Copa', region: 'Floresta', teams: ['Lava Jato'], teamIds: ['1']),
        ChampionshipDTO(id: 'x', championshipId: 8, title: 'Municipal de fora', region: 'Santo inacio'),
        ChampionshipDTO(
          id: 'i',
          championshipId: 12,
          title: 'Regional',
          region: 'Santo inacio',
          scope: ChampionshipScope.intermunicipal,
        ),
      ]);

  @override
  Future<Either<Failure, ChampionshipDTO>> setTeamEnrollment({
    required String championshipDocId,
    required TeamDTO team,
    required bool enrolled,
  }) async {
    calls.add('$championshipDocId:${enrolled ? '+' : '-'}');
    return Right(ChampionshipDTO(id: championshipDocId));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CountingChampionships extends _Championships {
  int forced = 0;

  @override
  Stream<Either<Failure, List<ChampionshipDTO>>> call(
      {required String region, required String season, bool force = false}) {
    if (force) forced++;
    return super.call(region: region, season: season, force: force);
  }
}

class _Delete implements DeleteTeamUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('elenco geral, chips das competições do time e sublista com os números dela', () async {
    final cubit = TeamPlayersCubit(_Watch(), _Delete(), _Championships())
      ..watch(teamId: '1', teamName: 'Lava Jato', season: '2026', region: 'Floresta');
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.view.championships.map((c) => c.championshipId), [7, 9]);
    expect(cubit.state.squad.length, 3);
    expect(cubit.state.totalGoals, 10);

    cubit.selectChampionship(7);
    // Dudu (3 na Copa) e Rafa (antigo: conta, com 0); Ana não joga a Copa.
    expect(cubit.state.visiblePlayers.map((p) => p.id), ['dudu', 'rafa']);
    expect(cubit.state.totalGoals, 3);
    expect(cubit.state.topScorerId, 'dudu');

    cubit.selectChampionship(9);
    // Na Liga, Dudu joga pelo Volta: fica fora do Lava Jato.
    expect(cubit.state.visiblePlayers.map((p) => p.id), ['ana', 'rafa']);
    await cubit.close();
  });

  test('inscrever o time: oferece municipais da região + intermunicipais e grava só o que mudou', () async {
    final repo = _ChampionshipsRepo();
    final championships = _CountingChampionships();
    final cubit = TeamPlayersCubit(
      _Watch(),
      _Delete(),
      championships,
      GetSeasonChampionshipsUseCase(repo),
      SetTeamChampionshipsUseCase(repo),
    )..watch(teamId: '1', teamName: 'Lava Jato', season: '2026', region: 'Floresta');
    await Future<void>.delayed(Duration.zero);

    const team = TeamDTO(id: '1', name: 'Lava Jato', region: 'Floresta');
    final offered = (await cubit.eligibleChampionships(team))!;
    expect(offered.map((c) => c.championshipId), [7, 12]);

    // Sai da Copa e entra no Regional.
    expect(await cubit.saveTeamChampionships(team, offered, {12}), isNull);
    expect(repo.calls, ['a:-', 'i:+']);
    expect(championships.forced, 1);
    await cubit.close();
  });
}
