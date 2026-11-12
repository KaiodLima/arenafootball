import 'dart:async';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';
import 'package:arena_soccer/features/players/presentation/page/player_profile_page.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_state.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/owned_team_cubit.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/owned_team_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_region_matches_usecase.dart';
import 'package:arena_soccer/features/players/domain/player_season_summary.dart';
import 'package:arena_soccer/features/players/domain/usecases/get_player_awards_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/get_player_season_history_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/assign_unassigned_stats_usecase.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/services/storage_upload_service.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_cache_first_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/adjust_player_stats_usecase.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_player_goal_cards_cache_first_usecase.dart';
import 'package:arena_soccer/features/players/data/datasources/players_datasource.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/dtos/player_enrollment.dart';
import 'package:arena_soccer/features/players/domain/repositories/players_repository_interface.dart';
import 'package:arena_soccer/features/players/domain/usecases/delete_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/get_top_players_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/remove_player_from_squad_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/update_player_photo_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/update_player_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_player_usecase.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_profile_cubit.dart';
import 'package:arena_soccer/features/players/presentation/bloc/player_profile_state.dart';
import 'package:arena_soccer/features/stats/domain/ranking_entry.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_stats_ranking_cache_first_usecase.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_stats_ranking_usecase.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';

const _dudu = PlayerDTO(id: 'dudu', name: 'Dudu', team: 'Lava Jato', teamId: '1', goals: 3, assists: 1);

/// Artilharia de Floresta: Rafa 5, Dudu 3, Gabriel 3 (empate em 2º), Cassin 0.
const _all = [
  PlayerDTO(id: 'rafa', name: 'Rafa', team: 'Volta', teamId: '2', goals: 5),
  _dudu,
  PlayerDTO(id: 'gabriel', name: 'Gabriel', team: 'Volta', teamId: '2', goals: 3, assists: 4),
  PlayerDTO(id: 'cassin', name: 'Cassin', team: 'Lava Jato', teamId: '1'),
  PlayerDTO(id: 'fora', name: 'Fora', team: 'Riacho', teamId: '3', goals: 9),
];

class _FakePlayers implements IPlayersRepository {
  @override
  Future<Either<Failure, PlayerDTO?>> getPlayerByUser({required String userId, String? season}) async =>
      const Right(null);
  @override
  Future<Either<Failure, void>> setChampionships(
    PlayerDTO player, {
    required String teamId,
    required String team,
    required Set<int> selected,
    required List<int> teamChampionships,
    String? season,
  }) async =>
      const Right(null);

  @override
  Stream<Either<Failure, PlayerDTO?>> watchPlayerOfUser({required String userId, String? season}) =>
      const Stream.empty();

  @override
  Future<Either<Failure, void>> enroll(PlayerDTO player, PlayerEnrollment enrollment, {String? season}) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<PlayerDTO>>> getTopPlayersInChampionship({
    required int championshipId,
    required String field,
    int limit = 50,
    String? season,
  }) async =>
      const Right([]);

  final controller = StreamController<Either<Failure, PlayerDTO?>>();
  final updated = <PlayerDTO>[];
  final deleted = <PlayerDTO>[];
  final removed = <PlayerDTO>[];

  @override
  Future<Either<Failure, void>> removeFromSquad(PlayerDTO player, {int? championshipId, String? season}) async {
    removed.add(player);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deletePlayer(PlayerDTO player, {String? season}) async {
    deleted.add(player);
    return const Right(null);
  }

  @override
  Stream<Either<Failure, PlayerDTO?>> watchPlayer({required String id, String? season}) => controller.stream;

  @override
  Future<Either<Failure, List<PlayerDTO>>> getPlayers({String? season}) async => const Right(_all);

  /// Como a consulta: só os times pedidos, decrescente pelo quesito, limitado.
  @override
  Future<Either<Failure, List<PlayerDTO>>> getTopPlayers({
    required List<String> teamIds,
    required String field,
    int limit = 50,
    String? season,
  }) async {
    final top = _all.where((p) => teamIds.contains(p.teamId)).toList();
    return Right(PlayersDataSource.mergeTopPlayers([top], field: field, limit: limit));
  }

  @override
  Future<Either<Failure, void>> updatePlayer(PlayerDTO player, {String? season}) async {
    updated.add(player);
    return const Right(null);
  }

  /// Fotos gravadas sozinhas (o próprio atleta): (id, url).
  final photos = <(String, String)>[];

  @override
  Future<Either<Failure, void>> updatePlayerPhoto({required String id, required String url, String? season}) async {
    photos.add((id, url));
    return const Right(null);
  }

  @override
  Stream<Either<Failure, List<PlayerDTO>>> watchTeamPlayers(
          {String teamId = '', required String teamName, String? season}) =>
      const Stream.empty();

  @override
  Future<Either<Failure, void>> createPlayer(PlayerDTO player, {String? season}) async => const Right(null);

  @override
  Future<Either<Failure, int>> repairTotals(
    Map<String, ({int goals, int assists})> friendlyCounts, {
    String? season,
    Map<String, Map<int, ChampionshipStatCount>> championshipCounts = const {},
  }) async =>
      const Right(0);

  @override
  Future<Either<Failure, void>> assignUnassigned({
    required String playerId,
    int goals = 0,
    int assists = 0,
    PlayerEnrollment? enrollment,
    String? season,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> incrementStats({
    required String playerId,
    int goals = 0,
    int assists = 0,
    PlayerEnrollment? enrollment,
    bool friendly = false,
    String? season,
  }) async =>
      const Right(null);
}

class _FakeTeams implements GetTeamsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<TeamDTO>>> call({String? region, String? season, bool force = false}) =>
      Stream.fromFuture(_load(region: region, season: season));

  Future<Either<Failure, List<TeamDTO>>> _load({String? region, String? season}) async {
    const all = [
      TeamDTO(id: '1', name: 'Lava Jato', region: 'Floresta', imageUrl: 'https://img/lj.png'),
      TeamDTO(id: '2', name: 'Volta', region: 'Floresta'),
      TeamDTO(id: '3', name: 'Riacho', region: 'Santo inacio'),
    ];
    return Right(region == null ? all : all.where((t) => t.region == region).toList());
  }
}

class _FakeGoalCards implements GetPlayerGoalCardsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<NewsDTO>>> call(String playerId, {bool force = false}) =>
      Stream.fromFuture(_load(playerId));

  Future<Either<Failure, List<NewsDTO>>> _load(String playerId) async => Right([
        NewsDTO(id: 'c2', tag: NewsDTO.goalTag, date: DateTime(2026, 10, 2), scorerId: playerId, scorerName: 'Dudu'),
        NewsDTO(
            id: 'c1', tag: NewsDTO.goalTag, date: DateTime(2026, 9, 1), assistantId: playerId, assistantName: 'Dudu'),
      ]);
}

/// Ranking sem cache local: sempre o cálculo real.
class _NoCacheRanking implements GetStatsRankingCacheFirstUseCase {
  final GetStatsRankingUseCase inner;

  _NoCacheRanking(this.inner);

  @override
  Stream<Either<Failure, StatsRanking>> call({
    required StatsRankingType type,
    required String region,
    String? season,
    int? championshipId,
    bool force = false,
  }) =>
      Stream.fromFuture(inner(type: type, region: region, season: season));
}

class _NoChampionships implements GetRegionChampionshipsCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<ChampionshipDTO>>> call(
          {required String region, required String season, bool force = false}) =>
      const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStorage implements StorageUploadService {
  @override
  Future<Either<Failure, String>> uploadImage({required File file, required String folder, String? fileName}) async =>
      const Right('https://img/nova.png');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Session extends Cubit<SessionState> implements SessionCubit {
  _Session(String uid, {bool admin = false, bool playerMode = false})
      : super(SessionState(
          user: UserDTO(id: uid, name: 'Conta', email: 'c@x.com', isAdmin: admin),
          playerMode: playerMode,
        ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Owned extends Cubit<OwnedTeamState> implements OwnedTeamCubit {
  _Owned() : super(const OwnedTeamState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Region extends Cubit<RegionState> implements RegionCubit {
  _Region() : super(const RegionState(selectedSeason: '2023'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
      _NoCacheRanking(GetStatsRankingUseCase(teams, GetTopPlayersUseCase(players))),
      _FakeGoalCards(),
      UpdatePlayerUseCase(players, _FakeStorage()),
      DeletePlayerUseCase(players),
      RemovePlayerFromSquadUseCase(players),
      AdjustPlayerStatsUseCase(players),
      AssignUnassignedStatsUseCase(players),
      _NoChampionships(),
      _NoRegionMatches(),
      _NoAwards(),
      _NoHistory(),
      UpdatePlayerPhotoUseCase(players, _FakeStorage()),
    );
  });

  tearDown(() => cubit.close());

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

  Future<void> pumpPage(WidgetTester tester, {required String uid, bool admin = false, bool playerMode = false}) async {
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider<SessionCubit>(create: (_) => _Session(uid, admin: admin, playerMode: playerMode)),
        BlocProvider<OwnedTeamCubit>(create: (_) => _Owned()),
        BlocProvider<RegionCubit>(create: (_) => _Region()),
        BlocProvider<PlayerProfileCubit>.value(value: cubit),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('pt'),
        home: PlayerProfilePage(playerId: 'dudu', season: '2023'),
      ),
    ));
    players.controller.add(Right(_dudu.copyWith(userId: 'u1')));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('"Trocar minha foto" só para o próprio atleta', (tester) async {
    await pumpPage(tester, uid: 'u1');
    expect(find.text('Trocar minha foto'), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera_rounded), findsOneWidget);
  });

  testWidgets('outra conta não vê "Trocar minha foto"', (tester) async {
    await pumpPage(tester, uid: 'u2');
    expect(find.text('Trocar minha foto'), findsNothing);
  });

  testWidgets('admin no modo jogador: vê como o atleta da conta ("Trocar minha foto")', (tester) async {
    await pumpPage(tester, uid: 'u1', admin: true, playerMode: true);
    expect(find.text('Trocar minha foto'), findsOneWidget);
  });

  testWidgets('o admin tem o editor completo, não o botão do atleta', (tester) async {
    await pumpPage(tester, uid: 'u1', admin: true);
    expect(find.text('Trocar minha foto'), findsNothing);
  });

  test('o próprio atleta troca a foto: grava só a foto, não o cadastro inteiro', () async {
    cubit.watch(playerId: 'dudu', season: '2023');
    players.controller.add(const Right(_dudu));
    await settle();
    await cubit.changeOwnPhoto(File('foto.jpg'));
    expect(players.photos, [('dudu', 'https://img/nova.png')]);
    expect(players.updated, isEmpty);
    expect(cubit.state.player?.imageUrl, 'https://img/nova.png');
    expect(cubit.state.saving, isFalse);
  });

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

  test('com inscrições, o geral (soma das competições) não se ajusta direto', () async {
    cubit.watch(playerId: 'dudu');
    players.controller.add(const Right(PlayerDTO(
      id: 'dudu',
      name: 'Dudu',
      team: 'Lava Jato',
      goals: 3,
      enrollments: [PlayerEnrollment(championshipId: 7, teamId: '1', team: 'Lava Jato', goals: 3)],
      hasEnrollmentField: true,
    )));
    await settle();

    final count = players.updated.length;
    await cubit.adjustGoals(-1);
    await cubit.adjustAssists(1);
    expect(players.updated.length, count);
    expect(cubit.state.player?.goals, 3);
  });

  test('trocar a foto envia e grava a nova URL', () async {
    cubit.watch(playerId: 'dudu');
    players.controller.add(const Right(_dudu));
    await settle();
    await cubit.changePhoto(File('foto.png'));
    expect(players.updated.last.imageUrl, 'https://img/nova.png');
    expect(cubit.state.saving, isFalse);
  });

  test('excluir apaga o jogador e avisa com nome e time', () async {
    cubit.watch(playerId: 'dudu');
    players.controller.add(const Right(_dudu));
    await settle();
    await cubit.delete();
    expect(players.deleted.single.id, _dudu.id);
    expect(
      cubit.state,
      isA<DeletedPlayerProfileState>()
          .having((s) => s.name, 'name', _dudu.name)
          .having((s) => s.teamName, 'team', _dudu.team),
    );
  });

  test('vinculado: remover do elenco mantém o jogador e avisa', () async {
    const linked = PlayerDTO(id: 'kaio', name: 'Kaio', team: 'Lava Jato', goals: 7, userId: 'AbC1');
    cubit.watch(playerId: 'kaio');
    players.controller.add(const Right(linked));
    await settle();
    await cubit.removeFromSquad();
    expect(players.removed.single.id, 'kaio');
    expect(players.deleted, isEmpty);
    expect(cubit.state, isA<RemovedFromSquadPlayerProfileState>());

    // O stream chega sem time: some o time e as posições, ficam os gols.
    players.controller.add(Right(linked.copyWith(team: '')));
    await settle();
    expect(cubit.state.team, isNull);
    expect(cubit.state.goalsRank, isNull);
    expect(cubit.state.player?.goals, 7);
  });

  test('falha do stream sem jogador → estado de erro', () async {
    cubit.watch(playerId: 'dudu');
    players.controller.add(Left(ErrorWithMessage('erro')));
    await settle();
    expect(cubit.state, isA<ErrorPlayerProfileState>());
    expect(cubit.state.player, isNull);
  });
}

class _NoRegionMatches implements GetRegionMatchesUseCase {
  @override
  Future<Either<Failure, List<MatchDTO>>> call({required String region, String? season}) async => const Right([]);
}

class _NoAwards implements GetPlayerAwardsUseCase {
  @override
  Future<Either<Failure, List<MatchDTO>>> call({required String playerId, String? season}) async => const Right([]);
}

class _NoHistory implements GetPlayerSeasonHistoryUseCase {
  @override
  Future<Either<Failure, List<PlayerSeasonSummary>>> call(
          {required String userId, required List<String> seasons}) async =>
      const Right([]);
}
