import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:arena_soccer/features/voting/data/dtos/voting_rules_dto.dart';
import 'package:arena_soccer/features/voting/domain/usecases/get_voting_rules_cache_first_usecase.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/championships/data/datasources/championships_datasource.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/data/repositories/championships_repository_impl.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_cached_region_championship_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_cached_region_championships_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championship_cache_first_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championship_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_cache_first_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_region_championships_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/save_region_championship_cache_usecase.dart';
import 'package:arena_soccer/features/championships/domain/usecases/save_region_championships_cache_usecase.dart';
import 'package:arena_soccer/features/championships/presentation/bloc/championship_details_cubit.dart';
import 'package:arena_soccer/features/global_results/data/datasources/global_results_datasource.dart';
import 'package:arena_soccer/features/global_results/data/dtos/scraped_match_dto.dart';
import 'package:arena_soccer/features/global_results/data/repositories/global_results_repository_impl.dart';
import 'package:arena_soccer/features/global_results/domain/entities/results_day.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_cached_global_results_usecase.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_global_results_cache_first_usecase.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/get_global_results_usecase.dart';
import 'package:arena_soccer/features/global_results/domain/usecases/save_global_results_cache_usecase.dart';
import 'package:arena_soccer/features/global_results/presentation/bloc/global_results_cubit.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/repositories/matches_repository_interface.dart';
import 'package:arena_soccer/features/matches/domain/usecases/create_match_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_region_matches_usecase.dart';
import 'package:arena_soccer/features/matches/presentation/bloc/match_form_cubit.dart';
import 'package:arena_soccer/features/news/data/datasources/news_datasource.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/data/repositories/news_repository_impl.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_cached_goal_cards_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_player_goal_cards_cache_first_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/get_player_goal_cards_usecase.dart';
import 'package:arena_soccer/features/news/domain/usecases/save_goal_cards_cache_usecase.dart';
import 'package:arena_soccer/features/players/data/datasources/players_datasource.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/repositories/players_repository_impl.dart';
import 'package:arena_soccer/features/players/domain/usecases/get_top_players_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/watch_team_players_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_usecase.dart';
import 'package:arena_soccer/features/stats/data/repositories/stats_repository_impl.dart';
import 'package:arena_soccer/features/stats/domain/stats_ranking_type.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_cached_stats_ranking_usecase.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_stats_ranking_cache_first_usecase.dart';
import 'package:arena_soccer/features/stats/domain/usecases/get_stats_ranking_usecase.dart';
import 'package:arena_soccer/features/stats/domain/usecases/save_stats_ranking_cache_usecase.dart';
import 'package:arena_soccer/features/stats/presentation/bloc/stats_ranking_cubit.dart';
import 'package:arena_soccer/features/stats/presentation/bloc/stats_ranking_state.dart';
import 'package:arena_soccer/features/teams/data/datasources/teams_datasource.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/data/repositories/teams_repository_impl.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_cached_teams_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/save_teams_cache_usecase.dart';
import 'package:arena_soccer/features/voting/data/datasources/voting_datasource.dart';
import 'package:arena_soccer/features/voting/data/dtos/vote_dto.dart';
import 'package:arena_soccer/features/voting/data/repositories/voting_repository_impl.dart';
import 'package:arena_soccer/features/voting/domain/match_vote_ref.dart';
import 'package:arena_soccer/features/voting/domain/usecases/calculate_best_player_usecase.dart';
import 'package:arena_soccer/features/voting/domain/usecases/get_cached_votes_usecase.dart';
import 'package:arena_soccer/features/voting/domain/usecases/get_elected_player_usecase.dart';
import 'package:arena_soccer/features/voting/domain/usecases/get_votes_cache_first_usecase.dart';
import 'package:arena_soccer/features/voting/domain/usecases/get_votes_usecase.dart';
import 'package:arena_soccer/features/voting/domain/usecases/save_votes_cache_usecase.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/elected_player_cubit.dart';
import 'package:arena_soccer/features/voting/presentation/bloc/elected_player_state.dart';

// Consumidores do cache local com os repositórios reais (cache no Hive) sobre
// DataSources falsos que contam as leituras remotas.

class _TeamsSource implements TeamsDataSource {
  int calls = 0;
  List<TeamDTO> teams = const [TeamDTO(id: '1', name: 'Lava Jato', imageUrl: 'lj.png')];

  @override
  Future<Either<Failure, List<TeamDTO>>> getTeams({String? region, String? season}) async {
    calls++;
    return Right(teams);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ChampionshipsSource implements ChampionshipsDataSource {
  int calls = 0;
  List<ChampionshipDTO> list = const [ChampionshipDTO(id: 'a', championshipId: 7, title: 'Copa', region: 'Floresta')];

  @override
  Future<Either<Failure, List<ChampionshipDTO>>> getRegionChampionships({
    required String region,
    required String season,
  }) async {
    calls++;
    return Right(list);
  }

  @override
  Future<Either<Failure, ChampionshipDTO?>> getChampionshipForRegion({
    required String region,
    required String season,
  }) async {
    calls++;
    return Right(list.firstOrNull);
  }

  @override
  Future<Either<Failure, void>> deleteChampionship(String id) async => const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MatchesRepository implements IMatchesRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RegionMatches implements GetRegionMatchesUseCase {
  @override
  Future<Either<Failure, List<MatchDTO>>> call({required String region, String? season}) async => const Right([]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Regions implements GetRegionsUseCase {
  @override
  Future<Either<Failure, List<String>>> call() async => const Right(['Floresta']);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TopPlayers implements GetTopPlayersUseCase {
  int calls = 0;
  int goals = 5;

  @override
  Future<Either<Failure, List<PlayerDTO>>> call({
    required List<String> teamIds,
    required String field,
    int limit = 50,
    String? season,
  }) async {
    calls++;
    return Right([PlayerDTO(id: 'p1', name: 'Dudu', team: 'Lava Jato', teamId: '1', goals: goals)]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PlayersSource implements PlayersDataSource {
  @override
  Future<Either<Failure, void>> updatePlayer(PlayerDTO player, {String? season}) async => const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NewsSource implements NewsDataSource {
  int calls = 0;

  @override
  Future<Either<Failure, List<NewsDTO>>> getGoalCardsByPlayer(String playerId) async {
    calls++;
    return Right([NewsDTO(id: 'g1', tag: NewsDTO.goalTag, scorerId: playerId, scorerName: 'Dudu')]);
  }

  @override
  Future<Either<Failure, void>> createNews(NewsDTO news) async => const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ResultsSource implements GlobalResultsDataSource {
  int calls = 0;
  String home = 'Arsenal';

  @override
  Future<Either<Failure, List<ScrapedMatchDTO>>> getMatches(ResultsDay day) async {
    calls++;
    return Right([ScrapedMatchDTO(homeTeam: home, awayTeam: 'Chelsea', league: 'England', homeGoals: 1, awayGoals: 0)]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _VotingSource implements VotingDataSource {
  int calls = 0;

  @override
  Future<Either<Failure, List<VoteDTO>>> getVotes({required MatchVoteRef ref}) async {
    calls++;
    return const Right([
      VoteDTO(voterId: 'u1', playerName: 'Dudu', team: 'Lava Jato'),
      VoteDTO(voterId: 'u2', playerName: 'Dudu', team: 'Lava Jato'),
    ]);
  }

  @override
  Future<Either<Failure, void>> castVote({required MatchVoteRef ref, required VoteDTO vote}) async => const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TeamPlayers implements WatchTeamPlayersUseCase {
  @override
  Stream<Either<Failure, List<PlayerDTO>>> call({String teamId = '', required String teamName, String? season}) =>
      Stream.value(const Right([]));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _old = DateTime.now().subtract(const Duration(days: 1));

void main() {
  late Directory dir;
  late Box<String> box;
  var boxes = 0;

  setUpAll(() {
    dir = Directory.systemTemp.createTempSync('arena_cache_consumers_test');
    Hive.init(dir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  setUp(() async => box = await Hive.openBox<String>('consumers_${boxes++}'));

  tearDown(() async => box.deleteFromDisk());

  /// Cache com o relógio de gravação [savedAt] (padrão: agora).
  CacheStore cache([DateTime? savedAt]) => CacheStore(box, now: savedAt == null ? null : () => savedAt);

  GetTeamsCacheFirstUseCase teamsUseCase(_TeamsSource source, CacheStore store) {
    final repository = TeamsRepositoryImpl(source, store);
    return GetTeamsCacheFirstUseCase(
      GetTeamsUseCase(repository),
      GetCachedTeamsUseCase(repository),
      SaveTeamsCacheUseCase(repository),
    );
  }

  group('times (ChampionshipDetailsCubit)', () {
    const championship = ChampionshipDTO(id: 'c', region: 'Floresta', season: '2024', teams: ['Lava Jato']);

    test('cache válido: escudos sem ler o Firestore', () async {
      final source = _TeamsSource();
      await teamsUseCase(source, cache()).call(region: 'Floresta', season: '2024').last;
      source.calls = 0;

      final cubit = ChampionshipDetailsCubit(teamsUseCase(source, cache()));
      await cubit.load(championship);
      expect(source.calls, 0);
      expect(cubit.state.single.imageUrl, 'lj.png');
      await cubit.close();
    });

    test('cache vencido: mostra o cache e depois o Firestore', () async {
      final source = _TeamsSource();
      await teamsUseCase(source, cache(_old)).call(region: 'Floresta', season: '2024').last;
      source
        ..calls = 0
        ..teams = const [TeamDTO(id: '1', name: 'Lava Jato', imageUrl: 'novo.png')];

      final cubit = ChampionshipDetailsCubit(teamsUseCase(source, cache()));
      final crests = <String>[];
      final sub = cubit.stream.listen((teams) => crests.add(teams.single.imageUrl));
      await cubit.load(championship);
      await Future<void>.delayed(Duration.zero);
      expect(crests, ['', 'lj.png', 'novo.png']);
      expect(source.calls, 1);
      await sub.cancel();
      await cubit.close();
    });
  });

  group('campeonatos', () {
    MatchFormCubit formCubit(_ChampionshipsSource source, CacheStore store) {
      final repository = ChampionshipsRepositoryImpl(source, store);
      final single = GetRegionChampionshipCacheFirstUseCase(
        GetRegionChampionshipUseCase(repository),
        GetCachedRegionChampionshipUseCase(repository),
        SaveRegionChampionshipCacheUseCase(repository),
      );
      return MatchFormCubit(
        CreateMatchUseCase(_MatchesRepository(), single),
        _Regions(),
        teamsUseCase(_TeamsSource(), store),
        _RegionMatches(),
        GetRegionChampionshipsCacheFirstUseCase(
          GetRegionChampionshipsUseCase(repository),
          GetCachedRegionChampionshipsUseCase(repository),
          SaveRegionChampionshipsCacheUseCase(repository),
        ),
      );
    }

    test('formulário de partida: cache válido não lê; vencido revalida', () async {
      final source = _ChampionshipsSource();
      await formCubit(source, cache(_old)).load(initialRegion: 'Floresta');
      expect(source.calls, 1);

      // Gravado há um dia (validade de 30 min): revalida e mostra o novo.
      source.list = const [ChampionshipDTO(id: 'b', championshipId: 8, title: 'Liga', region: 'Floresta')];
      final stale = formCubit(source, cache());
      await stale.load(initialRegion: 'Floresta');
      expect(source.calls, 2);
      expect(stale.state.form.championships.single.championshipId, 8);

      // Agora dentro da validade: nenhuma leitura.
      final fresh = formCubit(source, cache());
      await fresh.load(initialRegion: 'Floresta');
      expect(source.calls, 2);
      expect(fresh.state.form.championshipId, 8);
    });

    test('apagar um campeonato limpa o cache de campeonatos', () async {
      final store = cache();
      await formCubit(_ChampionshipsSource(), store).load(initialRegion: 'Floresta');
      expect(box.keys.where((key) => CacheKeys.isChampionshipKey(key.toString())), isNotEmpty);
      await ChampionshipsRepositoryImpl(_ChampionshipsSource(), store).deleteChampionship('a');
      expect(box.keys.where((key) => CacheKeys.isChampionshipKey(key.toString())), isEmpty);
    });
  });

  group('ranking (StatsRankingCubit)', () {
    StatsRankingCubit rankingCubit(_TeamsSource teams, _TopPlayers players, CacheStore store) {
      final repository = StatsRepositoryImpl(store);
      return StatsRankingCubit(GetStatsRankingCacheFirstUseCase(
        // Times gravados sempre agora (válidos): só o ranking envelhece.
        GetStatsRankingUseCase(teamsUseCase(teams, cache()), players),
        GetCachedStatsRankingUseCase(repository),
        SaveStatsRankingCacheUseCase(repository),
      ));
    }

    test('cache válido: sem ler times nem jogadores; vencido revalida', () async {
      final teams = _TeamsSource();
      final players = _TopPlayers();
      await rankingCubit(teams, players, cache(_old))
          .load(type: StatsRankingType.goals, region: 'Floresta', season: '2024');
      expect(players.calls, 1);

      players.goals = 9;
      final stale = rankingCubit(teams, players, cache());
      final values = <int>[];
      final sub = stale.stream.listen((s) {
        if (s is SuccessStatsRankingState) values.add(s.entries.single.value);
      });
      await stale.load(type: StatsRankingType.goals, region: 'Floresta', season: '2024');
      await Future<void>.delayed(Duration.zero);
      expect(values, [5, 9]);
      expect(players.calls, 2);
      await sub.cancel();

      final fresh = rankingCubit(teams, players, cache());
      await fresh.load(type: StatsRankingType.goals, region: 'Floresta', season: '2024');
      expect(players.calls, 2);
      expect(fresh.state.entries.single.value, 9);
      // Os times do ranking também vieram do cache (lidos uma vez só).
      expect(teams.calls, 1);
    });

    test('editar os números de um jogador apaga os rankings', () async {
      final store = cache();
      await rankingCubit(_TeamsSource(), _TopPlayers(), store)
          .load(type: StatsRankingType.goals, region: 'Floresta', season: '2024');
      expect(box.keys.where((key) => CacheKeys.isRankingKey(key.toString())), isNotEmpty);
      await PlayersRepositoryImpl(_PlayersSource(), store)
          .updatePlayer(const PlayerDTO(id: 'p1', name: 'Dudu', team: 'Lava Jato', goals: 6));
      expect(box.keys.where((key) => CacheKeys.isRankingKey(key.toString())), isEmpty);
    });
  });

  test('cards de gol: cache válido não lê; notícia nova apaga o cache', () async {
    final source = _NewsSource();
    final repository = NewsRepositoryImpl(source, cache());
    final useCase = GetPlayerGoalCardsCacheFirstUseCase(
      GetPlayerGoalCardsUseCase(repository),
      GetCachedGoalCardsUseCase(repository),
      SaveGoalCardsCacheUseCase(repository),
    );
    expect((await useCase('p1').last).right.single.id, 'g1');
    expect((await useCase('p1').last).right.single.id, 'g1');
    expect(source.calls, 1);

    await repository.createNews(const NewsDTO(tag: NewsDTO.goalTag));
    await useCase('p1').last;
    expect(source.calls, 2);
  });

  group('resultados pelo mundo (GlobalResultsCubit)', () {
    GlobalResultsCubit resultsCubit(_ResultsSource source, CacheStore store) {
      final repository = GlobalResultsRepositoryImpl(source, store);
      return GlobalResultsCubit(GetGlobalResultsCacheFirstUseCase(
        GetGlobalResultsUseCase(repository),
        GetCachedGlobalResultsUseCase(repository),
        SaveGlobalResultsCacheUseCase(repository),
      ));
    }

    test('cache válido não refaz o scraping; vencido mostra o cache e busca; puxar força', () async {
      final source = _ResultsSource();
      await resultsCubit(source, cache(_old)).load(ResultsDay.yesterday);
      expect(source.calls, 1);

      source.home = 'Liverpool';
      final stale = resultsCubit(source, cache());
      final homes = <String>[];
      final sub = stale.stream.listen((s) {
        if (s.matches.isNotEmpty) homes.add(s.matches.single.homeTeam);
      });
      await stale.load(ResultsDay.yesterday);
      await Future<void>.delayed(Duration.zero);
      expect(homes, ['Arsenal', 'Liverpool']);
      expect(source.calls, 2);
      await sub.cancel();

      final fresh = resultsCubit(source, cache());
      await fresh.load(ResultsDay.yesterday);
      expect(source.calls, 2);
      expect(fresh.state.matches.single.homeTeam, 'Liverpool');

      await fresh.refresh();
      expect(source.calls, 3);
    });
  });

  group('votação encerrada (ElectedPlayerCubit)', () {
    const match = MatchDTO(id: 'm1', homeTeam: 'Lava Jato', awayTeam: 'Volta');

    ElectedPlayerCubit electedCubit(_VotingSource source, CacheStore store) {
      final repository = VotingRepositoryImpl(source, store);
      return ElectedPlayerCubit(GetElectedPlayerUseCase(
        CalculateBestPlayerUseCase(GetVotesCacheFirstUseCase(
          GetVotesUseCase(repository),
          GetCachedVotesUseCase(repository),
          SaveVotesCacheUseCase(repository),
        )),
        teamsUseCase(_TeamsSource(), store),
        _TeamPlayers(),
        _LenientRules(),
      ));
    }

    test('apuração reaberta em menos de 1 min não relê os votos; votar apaga o cache', () async {
      final source = _VotingSource();
      final store = cache();
      final first = electedCubit(source, store);
      await first.load(match: match, season: '2024');
      final second = electedCubit(source, store);
      await second.load(match: match, season: '2024');
      expect(source.calls, 1);
      expect((second.state as SuccessElectedPlayerState).result?.elected?.votes, 2);

      await VotingRepositoryImpl(source, store).castVote(
        ref: MatchVoteRef.of(match, '2024'),
        vote: const VoteDTO(voterId: 'u3', playerName: 'Dudu', team: 'Lava Jato'),
      );
      await electedCubit(source, store).load(match: match, season: '2024');
      expect(source.calls, 2);
    });
  });
}

/// Regras frouxas da votação: 1 voto já elege (o teste é do cache dos votos).
class _LenientRules implements GetVotingRulesCacheFirstUseCase {
  @override
  Stream<Either<Failure, VotingRulesDTO>> call({bool force = false}) =>
      Stream.value(const Right(VotingRulesDTO(minVotes: 1, minPercent: 0)));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
