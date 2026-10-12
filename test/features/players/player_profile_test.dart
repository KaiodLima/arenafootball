import 'dart:async';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_player_goal_cards_usecase.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';
import 'package:arena_soccer/features/players/domain/usecases/get_players_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/update_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_player_usecase.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_profile_cubit.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_profile_state.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_stats_ranking_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';

const _dudu = PlayerDTO(id: 'dudu', name: 'Dudu', team: 'Lava Jato', goals: 3, assists: 1);

/// Artilharia de Floresta: Rafa 5, Dudu 3, Gabriel 3 (empate em 2º), Cassin 0.
const _all = [
  PlayerDTO(id: 'rafa', name: 'Rafa', team: 'Volta', goals: 5),
  _dudu,
  PlayerDTO(id: 'gabriel', name: 'Gabriel', team: 'Volta', goals: 3, assists: 4),
  PlayerDTO(id: 'cassin', name: 'Cassin', team: 'Lava Jato'),
  PlayerDTO(id: 'fora', name: 'Fora', team: 'Riacho', goals: 9),
];

class _FakePlayers implements IPlayersRepository {
  final controller = StreamController<Either<Failure, PlayerDTO?>>();
  final updated = <PlayerDTO>[];

  @override
  Stream<Either<Failure, PlayerDTO?>> watchPlayer({required String id, String? season}) => controller.stream;

  @override
  Future<Either<Failure, List<PlayerDTO>>> getPlayers({String? season}) async => const Right(_all);

  @override
  Future<Either<Failure, void>> updatePlayer(PlayerDTO player, {String? season}) async {
    updated.add(player);
    return const Right(null);
  }

  @override
  Stream<Either<Failure, List<PlayerDTO>>> watchTeamPlayers({required String teamName, String? season}) =>
      const Stream.empty();

  @override
  Future<Either<Failure, void>> createPlayer(PlayerDTO player, {String? season}) async => const Right(null);

  @override
  Future<Either<Failure, void>> incrementStats({
    required String playerId,
    int goals = 0,
    int assists = 0,
    String? season,
  }) async =>
      const Right(null);
}

class _FakeTeams implements GetTeamsUseCase {
  @override
  Future<Either<Failure, List<TeamDTO>>> call({String? region, String? season}) async {
    const all = [
      TeamDTO(id: '1', name: 'Lava Jato', region: 'Floresta', imageUrl: 'https://img/lj.png'),
      TeamDTO(id: '2', name: 'Volta', region: 'Floresta'),
      TeamDTO(id: '3', name: 'Riacho', region: 'Santo inacio'),
    ];
    return Right(region == null ? all : all.where((t) => t.region == region).toList());
  }
}

class _FakeGoalCards implements GetPlayerGoalCardsUseCase {
  @override
  Future<Either<Failure, List<NewsDTO>>> call(String playerId) async => Right([
        NewsDTO(id: 'c2', tag: NewsDTO.goalTag, date: DateTime(2026, 10, 2), scorerId: playerId, scorerName: 'Dudu'),
        NewsDTO(id: 'c1', tag: NewsDTO.goalTag, date: DateTime(2026, 9, 1), assistantId: playerId, assistantName: 'Dudu'),
      ]);
}

class _FakeStorage implements StorageUploadService {
  @override
  Future<Either<Failure, String>> uploadImage({required File file, required String folder, String? fileName}) async =>
      const Right('https://img/nova.png');
}

void main() {
  late _FakePlayers players;
  late PlayerProfileCubit cubit;

  setUp(() {
    players = _FakePlayers();
    final teams = _FakeTeams();
    cubit = PlayerProfileCubit(
      WatchPlayerUseCase(players),
      teams,
      GetStatsRankingUseCase(teams, GetPlayersUseCase(players)),
      _FakeGoalCards(),
      UpdatePlayerUseCase(players, _FakeStorage()),
    );
  });

  tearDown(() => cubit.close());

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

  test('jogador, time, posições (empate divide) e participações', () async {
    cubit.watch(playerId: 'dudu', season: '2023');
    players.controller.add(const Right(_dudu));
    await settle();

    final state = cubit.state;
    expect(state.player, _dudu);
    expect(state.team?.imageUrl, 'https://img/lj.png');
    // Rafa 5 (1º); Dudu e Gabriel 3 (2º). "Fora" é de outra região.
    expect(state.goalsRank, 2);
    // Gabriel 4 (1º), Dudu 1 (2º).
    expect(state.assistsRank, 2);
    expect(state.participations.map((c) => c.id), ['c2', 'c1']);
  });

  test('sem gols → fora do ranking', () async {
    cubit.watch(playerId: 'cassin');
    players.controller.add(const Right(PlayerDTO(id: 'cassin', name: 'Cassin', team: 'Lava Jato')));
    await settle();
    expect(cubit.state.goalsRank, isNull);
    expect(cubit.state.assistsRank, isNull);
  });

  test('documento inexistente → notFound', () async {
    cubit.watch(playerId: 'x');
    players.controller.add(const Right(null));
    await settle();
    expect(cubit.state.notFound, isTrue);
  });

  test('admin: ajustes nunca ficam negativos; renomear exige 3 letras', () async {
    cubit.watch(playerId: 'dudu');
    players.controller.add(const Right(PlayerDTO(id: 'dudu', name: 'Dudu', team: 'Lava Jato', goals: 0, assists: 1)));
    await settle();

    await cubit.adjustGoals(-1);
    expect(players.updated.last.goals, 0);
    await cubit.adjustAssists(1);
    expect(players.updated.last.assists, 2);
    expect(cubit.state.player?.assists, 2);

    final count = players.updated.length;
    await cubit.rename('  ab ');
    expect(players.updated.length, count);
    await cubit.rename('  Dudu Silva ');
    expect(players.updated.last.name, 'Dudu Silva');
  });

  test('trocar a foto envia e grava a nova URL', () async {
    cubit.watch(playerId: 'dudu');
    players.controller.add(const Right(_dudu));
    await settle();
    await cubit.changePhoto(File('foto.png'));
    expect(players.updated.last.imageUrl, 'https://img/nova.png');
    expect(cubit.state.saving, isFalse);
  });

  test('falha do stream sem jogador → estado de erro', () async {
    cubit.watch(playerId: 'dudu');
    players.controller.add(Left(ErrorWithMessage('erro')));
    await settle();
    expect(cubit.state, isA<ErrorPlayerProfileState>());
    expect(cubit.state.player, isNull);
  });
}
