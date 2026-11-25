import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/core/services/preferences_service.dart';
import 'package:arena_soccer/features/album/data/datasources/album_datasource.dart';
import 'package:arena_soccer/features/album/data/dtos/album_dtos.dart';
import 'package:arena_soccer/features/album/data/repositories/album_repository_impl.dart';
import 'package:arena_soccer/features/album/domain/usecases/album_usecase.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/championships/data/datasources/championships_datasource.dart';
import 'package:arena_soccer/features/championships/data/dtos/championship_dto.dart';
import 'package:arena_soccer/features/championships/data/repositories/championships_repository_impl.dart';
import 'package:arena_soccer/features/championships/domain/repositories/championships_repository_interface.dart';
import 'package:arena_soccer/features/championships/domain/usecases/get_season_championships_usecase.dart';
import 'package:arena_soccer/features/event_polls/data/datasources/event_polls_datasource.dart';
import 'package:arena_soccer/features/event_polls/data/repositories/event_polls_repository_impl.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/fantasy/data/datasources/fantasy_datasource.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_ranking_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_round_dtos.dart';
import 'package:arena_soccer/features/fantasy/data/dtos/fantasy_score_dto.dart';
import 'package:arena_soccer/features/fantasy/data/repositories/fantasy_repository_impl.dart';
import 'package:arena_soccer/features/fantasy/domain/fantasy_lineup.dart';
import 'package:arena_soccer/features/fantasy/domain/usecases/fantasy_ranking_usecases.dart';
import 'package:arena_soccer/features/news/data/datasources/news_datasource.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/data/repositories/news_repository_impl.dart';
import 'package:arena_soccer/features/news/domain/usecases/open_events_cache_usecases.dart';
import 'package:arena_soccer/features/organizer_requests/data/datasources/organizer_requests_datasource.dart';
import 'package:arena_soccer/features/organizer_requests/data/repositories/organizer_requests_repository_impl.dart';
import 'package:arena_soccer/features/organizer_requests/domain/usecases/organizer_request_usecases.dart';
import 'package:arena_soccer/features/referrals/data/datasources/referrals_datasource.dart';
import 'package:arena_soccer/features/referrals/data/repositories/referrals_repository_impl.dart';
import 'package:arena_soccer/features/referrals/domain/referral_code.dart';
import 'package:arena_soccer/features/referrals/domain/usecases/referral_usecases.dart';
import 'package:arena_soccer/features/regions/data/datasources/regions_datasource.dart';
import 'package:arena_soccer/features/regions/data/repositories/regions_repository_impl.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_cached_regions_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/get_regions_cache_first_usecase.dart';
import 'package:arena_soccer/features/regions/domain/usecases/save_regions_cache_usecase.dart';
import 'package:arena_soccer/features/teams/data/datasources/teams_datasource.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/data/repositories/teams_repository_impl.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_cached_team_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_cached_teams_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_team_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_by_ids_cache_first_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_by_ids_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_cache_first_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_teams_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/save_team_cache_usecase.dart';
import 'package:arena_soccer/features/teams/domain/usecases/save_teams_cache_usecase.dart';

// Caches da fase 3 (Fantasy, eventos abertos, formulários, campeonatos/times,
// indicações, organizador e ranking do álbum): repositórios reais (cache no
// Hive) sobre DataSources falsos que contam as leituras remotas.

Failure _offline() => ErrorWithMessage('offline');

class _FantasySource implements FantasyDataSource {
  int roundsCalls = 0;
  int countCalls = 0;
  int lineupCalls = 0;
  int scoreCalls = 0;
  bool failCount = false;

  List<FantasyRoundDTO> rounds = [
    FantasyRoundDTO(number: 1, status: 'fechada', scored: true, processedAt: DateTime(2026, 11, 1)),
  ];
  int above = 4;

  @override
  Future<Either<Failure, List<FantasyRoundDTO>>> getRounds(String fantasyId) async {
    roundsCalls++;
    return Right(rounds);
  }

  @override
  Future<Either<Failure, int>> countAbove(String fantasyId, double points, {int? round}) async {
    countCalls++;
    return failCount ? Left(_offline()) : Right(above);
  }

  @override
  Future<Either<Failure, FantasyLineupDTO?>> getLineup(String fantasyId, int round, String uid) async {
    lineupCalls++;
    return Right(FantasyLineupDTO(
      uid: uid,
      name: 'Ana',
      lineup: FantasyLineup(athletes: {const FantasySpot(FantasySlot.forward): 'fw'}, captainId: 'fw'),
      points: 12.5,
      athletePoints: const {'fw': 12.5},
      playedIds: const ['fw'],
    ));
  }

  @override
  Future<Either<Failure, FantasyAthleteScoreDTO?>> getAthleteScore(
      String fantasyId, int round, String athleteId) async {
    scoreCalls++;
    return Right(FantasyAthleteScoreDTO.fromMap(athleteId, const {
      'nome': 'Ângelo',
      'total': 9,
      'itens': [
        {'regra': 'gol', 'qtd': 1, 'pontos': 8, 'idPartida': 'm1'},
      ],
      'motivos': [
        {'codigo': 'minutos', 'idPartida': 'm1'},
      ],
      'partidas': [
        {'idPartida': 'm1', 'minutos': 70, 'pontos': 9},
      ],
      'parametros': {'minMinutos': 20, 'minMinutosDefesa': 45, 'capitao': 2},
    }));
  }

  @override
  Future<Either<Failure, void>> requestRescore(String fantasyId) async => const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NewsSource implements NewsDataSource {
  int calls = 0;
  bool fail = false;

  @override
  Future<Either<Failure, List<NewsDTO>>> getOpenEvents({int limit = 20}) async {
    calls++;
    if (fail) return Left(_offline());
    return Right([
      NewsDTO(id: 'ev$calls', tag: NewsDTO.eventTag, title: 'Gol mais bonito', event: const EventPoll()),
    ]);
  }

  @override
  Future<Either<Failure, void>> deleteNews(String id) async => const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _EventPollsSource implements EventPollsDataSource {
  @override
  Future<Either<Failure, void>> close(String id) async => const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RegionsSource implements RegionsDataSource {
  int calls = 0;

  @override
  Future<Either<Failure, List<RegionRef>>> getRegionRefs() async {
    calls++;
    return const Right([RegionRef(id: 'r1', name: 'Floresta'), RegionRef(id: 'r2', name: 'Riacho')]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Prefs implements PreferencesService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ChampionshipsSource implements ChampionshipsDataSource {
  int calls = 0;

  @override
  Future<Either<Failure, List<ChampionshipDTO>>> getSeasonChampionships(String season) async {
    calls++;
    return const Right([ChampionshipDTO(id: 'a', championshipId: 7, title: 'Copa', region: 'Floresta')]);
  }

  @override
  Future<Either<Failure, ChampionshipDTO>> updateChampionship(ChampionshipDTO championship) async =>
      Right(championship);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TeamsSource implements TeamsDataSource {
  int teamCalls = 0;
  int seasonCalls = 0;
  final byIdsAsked = <List<String>>[];

  @override
  Future<Either<Failure, TeamDTO?>> getTeam({required String id, String? season}) async {
    teamCalls++;
    return Right(TeamDTO(id: id, name: 'Lava Jato'));
  }

  @override
  Future<Either<Failure, List<TeamDTO>>> getTeams({String? region, String? season}) async {
    seasonCalls++;
    return const Right([TeamDTO(id: '1', name: 'Lava Jato'), TeamDTO(id: '2', name: 'Volta')]);
  }

  @override
  Future<Either<Failure, List<TeamDTO>>> getTeamsByIds({
    required List<String> ids,
    List<String> names = const [],
    String? season,
  }) async {
    byIdsAsked.add([...ids, ...names]);
    return Right([for (final id in ids) TeamDTO(id: id, name: 'Time $id')]);
  }

  @override
  Future<Either<Failure, void>> updateTeamDetails({
    required String id,
    required String description,
    required String imageUrl,
    String primaryColor = '',
    String secondaryColor = '',
    String? region,
    String? season,
  }) async =>
      const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ReferralsSource implements ReferralsDataSource {
  int ensureCalls = 0;
  int claimCalls = 0;
  bool fail = false;

  @override
  Future<Either<Failure, String>> ensureCode(String uid) async {
    ensureCalls++;
    return fail ? Left(_offline()) : Right(ReferralCode.of(uid));
  }

  @override
  Future<Either<Failure, String>> getClaim(String uid) async {
    claimCalls++;
    return const Right('ABCD1234');
  }

  @override
  DateTime? accountCreatedAt() => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _OrganizerSource implements OrganizerRequestsDataSource {
  final asked = <List<String>>[];
  bool fail = false;

  @override
  Future<Either<Failure, int>> ensureMyIndexes(String userId, List<ChampionshipDTO> championships) async {
    asked.add([for (final c in championships) c.id]);
    return fail ? Left(_offline()) : Right(championships.length);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoChampionships implements IChampionshipsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _AlbumSource implements AlbumDataSource {
  int topCalls = 0;
  int meCalls = 0;
  int aheadCalls = 0;
  bool failMe = false;

  int get reads => topCalls + meCalls + aheadCalls;

  @override
  Future<Either<Failure, List<AlbumRankingEntryDTO>>> getTopCollectors(String eventId, {int limit = 50}) async {
    topCalls++;
    return Right([AlbumRankingEntryDTO(userId: 'a', name: 'Ana', collected: 30, reachedAt: DateTime(2026, 11, 2))]);
  }

  @override
  Future<Either<Failure, AlbumRankingEntryDTO?>> getCollector(String eventId, String userId) async {
    meCalls++;
    if (failMe) return Left(_offline());
    return Right(AlbumRankingEntryDTO(userId: userId, name: 'Eu', collected: 12));
  }

  @override
  Future<Either<Failure, int>> collectorsAhead(String eventId, int collected) async {
    aheadCalls++;
    return const Right(8);
  }

  @override
  Future<Either<Failure, void>> requestPack({
    required String packId,
    required String userId,
    required String eventId,
    bool extra = false,
    List<String> trade = const [],
  }) async =>
      const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _old = DateTime.now().subtract(const Duration(days: 2));

void main() {
  late Directory dir;
  late Box<String> box;
  var boxes = 0;

  setUpAll(() {
    dir = Directory.systemTemp.createTempSync('arena_phase3_caches_test');
    Hive.init(dir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  setUp(() async => box = await Hive.openBox<String>('phase3_${boxes++}'));

  tearDown(() async {
    SeasonCollection.reset();
    RegionRegistry.reset();
    await box.deleteFromDisk();
  });

  /// Cache com o relógio de gravação [savedAt] (padrão: agora).
  CacheStore cache([DateTime? savedAt]) => CacheStore(box, now: savedAt == null ? null : () => savedAt);

  group('Arena Fantasy', () {
    test('rodadas: cache válido não lê; vencido atualiza; força relê; reapurar apaga', () async {
      final source = _FantasySource();
      await GetFantasyRoundsCacheFirstUseCase(FantasyRepositoryImpl(source, cache(_old))).latest('f1');
      expect(source.roundsCalls, 1);

      final repository = FantasyRepositoryImpl(source, cache());
      final useCase = GetFantasyRoundsCacheFirstUseCase(repository);
      final stale = await useCase.latest('f1');
      expect(stale.right.single.processedAt, DateTime(2026, 11, 1));
      expect(source.roundsCalls, 2);

      await useCase.latest('f1');
      expect(source.roundsCalls, 2);
      await useCase.latest('f1', force: true);
      expect(source.roundsCalls, 3);

      await repository.requestRescore('f1');
      await useCase.latest('f1');
      expect(source.roundsCalls, 4);
    });

    test('posição: vale só para os mesmos pontos; falha não vai para o cache', () async {
      final source = _FantasySource();
      final useCase = GetFantasyPositionCacheFirstUseCase(FantasyRepositoryImpl(source, cache()));

      expect((await useCase('f1', 40, uid: 'u1')).right, 5);
      expect((await useCase('f1', 40, uid: 'u1')).right, 5);
      expect(source.countCalls, 1);

      // Pontos mudaram: lê de novo; outra conta tem a chave dela.
      await useCase('f1', 42, uid: 'u1');
      await useCase('f1', 42, uid: 'u2');
      expect(source.countCalls, 3);

      // Rodada tem a chave dela.
      await useCase('f1', 42, uid: 'u1', round: 3);
      expect(source.countCalls, 4);

      source.failCount = true;
      expect((await useCase('f1', 50, uid: 'u1')).isLeft, isTrue);
      source.failCount = false;
      expect((await useCase('f1', 50, uid: 'u1')).right, 5);
      expect(source.countCalls, 6);
    });

    test('histórico: rodada fechada no cache até a reapuração; posição que falhou não fica', () async {
      final source = _FantasySource();
      final useCase = GetFantasyRoundRecordUseCase(FantasyRepositoryImpl(source, cache()));
      final round = source.rounds.single;

      final first = await useCase('f1', round, 'u1');
      expect(first.right.position, 5);
      expect(first.right.lineup?.lineup.captainId, 'fw');
      final again = await useCase('f1', round, 'u1');
      expect(again.right, first.right);
      expect((source.lineupCalls, source.countCalls), (1, 1));

      // Reapurada (versão nova): lê de novo.
      final rescored = FantasyRoundDTO(number: 1, status: 'fechada', scored: true, processedAt: DateTime(2026, 11, 3));
      await useCase('f1', rescored, 'u1');
      expect((source.lineupCalls, source.countCalls), (2, 2));

      // Puxar para atualizar força.
      await useCase('f1', rescored, 'u1', force: true);
      expect(source.lineupCalls, 3);

      // Rodada aberta: nunca vai para o cache.
      const open = FantasyRoundDTO(number: 2, status: 'aberta');
      await useCase('f1', open, 'u1');
      await useCase('f1', open, 'u1');
      expect(source.lineupCalls, 5);

      // A posição falhou: mostra sem ela e lê de novo depois.
      source.failCount = true;
      final round4 = FantasyRoundDTO(number: 4, status: 'fechada', scored: true, processedAt: DateTime(2026, 11, 4));
      final partial = await useCase('f1', round4, 'u1');
      expect(partial.right.position, isNull);
      expect(partial.right.lineup, isNotNull);
      source.failCount = false;
      expect((await useCase('f1', round4, 'u1')).right.position, 5);
      expect(source.lineupCalls, 7);
    });

    test('pontuação do atleta: com a versão da apuração fica no cache; sem ela, lê sempre', () async {
      final source = _FantasySource();
      final useCase = GetFantasyAthleteScoreCacheFirstUseCase(FantasyRepositoryImpl(source, cache()));

      final score = (await useCase('f1', 1, 'fw', version: 100)).right!;
      final cached = (await useCase('f1', 1, 'fw', version: 100)).right!;
      expect(source.scoreCalls, 1);
      // O detalhe inteiro volta do cache (itens, motivos, partidas e parâmetros).
      expect(cached, score);
      expect(cached.captain, 2);

      await useCase('f1', 1, 'fw', version: 200);
      expect(source.scoreCalls, 2);

      await useCase('f1', 1, 'fw');
      await useCase('f1', 1, 'fw');
      expect(source.scoreCalls, 4);
    });

    test('DTOs: rodada e escalação voltam iguais do cache', () {
      final round = FantasyRoundDTO(
        number: 3,
        matchIds: const ['m1'],
        closesAt: DateTime(2026, 11, 5, 18),
        status: 'fechada',
        scored: true,
        finished: true,
        matchesFinished: 1,
        lineups: 9,
        processedAt: DateTime(2026, 11, 6),
        params: (minMinutes: 20, minDefenseMinutes: 45, captain: 1.5),
        manualClosed: true,
      );
      expect(FantasyRoundDTO.fromCache(round.toCache()), round);
      final lineup = FantasyLineupDTO(
        uid: 'u1',
        name: 'Ana',
        lineup: FantasyLineup(
            athletes: {FantasySpot(FantasySlot.goalkeeper): 'gk', FantasySpot(FantasySlot.forward): 'fw'},
            captainId: 'fw'),
        copied: true,
        points: 7,
        athletePoints: {'fw': 7},
        playedIds: ['fw'],
      );
      expect(FantasyLineupDTO.fromCache(lineup.toCache()), lineup);
      final record = FantasyRoundRecord(version: 5, lineup: lineup, position: 3);
      expect(FantasyRoundRecord.fromCache(record.toCache()), record);
    });
  });

  group('eventos de votação abertos (GetOpenEventsCacheFirstUseCase)', () {
    GetOpenEventsCacheFirstUseCase useCase(NewsRepositoryImpl repository) => GetOpenEventsCacheFirstUseCase(
          GetOpenEventsUseCase(repository),
          GetCachedOpenEventsUseCase(repository),
          SaveOpenEventsCacheUseCase(repository),
        );

    test('cache válido não lê; vencido atualiza; falha não vai para o cache', () async {
      final source = _NewsSource()..fail = true;
      expect((await useCase(NewsRepositoryImpl(source, cache())).latest()).isLeft, isTrue);
      expect(box.containsKey(CacheKeys.openEvents), isFalse);

      source.fail = false;
      await useCase(NewsRepositoryImpl(source, cache(_old))).latest();
      final stale = await useCase(NewsRepositoryImpl(source, cache())).call().toList();
      expect(stale.map((r) => r.right.single.id), ['ev2', 'ev3']);
      expect(stale.last.right.single.event, isNotNull);

      await useCase(NewsRepositoryImpl(source, cache())).latest();
      expect(source.calls, 3);
    });

    test('apagar notícia ou encerrar evento apaga o cache', () async {
      final source = _NewsSource();
      final news = NewsRepositoryImpl(source, cache());
      await useCase(news).latest();
      await news.deleteNews('ev1');
      await useCase(news).latest();
      expect(source.calls, 2);

      await EventPollsRepositoryImpl(_EventPollsSource(), cache()).close('ev2');
      await useCase(news).latest();
      expect(source.calls, 3);
    });
  });

  test('formulários: nomes das regiões pelo cache (GetRegionsCacheFirstUseCase.names)', () async {
    final source = _RegionsSource();
    final repository = RegionsRepositoryImpl(source, _Prefs(), cache());
    final useCase = GetRegionsCacheFirstUseCase(
        repository, GetCachedRegionsUseCase(repository), SaveRegionsCacheUseCase(repository));
    expect((await useCase.names()).right, ['Floresta', 'Riacho']);
    expect((await useCase.names()).right, ['Floresta', 'Riacho']);
    expect(source.calls, 1);
    await useCase.names(force: true);
    expect(source.calls, 2);
  });

  group('campeonatos e times', () {
    test('competições da temporada: cache válido não lê; gravar campeonato apaga', () async {
      final source = _ChampionshipsSource();
      final repository = ChampionshipsRepositoryImpl(source, cache());
      final useCase = GetSeasonChampionshipsCacheFirstUseCase(
        GetSeasonChampionshipsUseCase(repository),
        GetCachedSeasonChampionshipsUseCase(repository),
        SaveSeasonChampionshipsCacheUseCase(repository),
      );
      expect((await useCase.latest('2026')).right.single.championshipId, 7);
      await useCase.latest('2026');
      expect(source.calls, 1);
      // Outra temporada, outra chave.
      await useCase.latest('2025');
      expect(source.calls, 2);

      await repository.updateChampionship(const ChampionshipDTO(id: 'a', title: 'Copa 2'));
      await useCase.latest('2026');
      expect(source.calls, 3);
    });

    test('"Meu time" pelo cache do time; editar o time apaga', () async {
      final source = _TeamsSource();
      final repository = TeamsRepositoryImpl(source, cache());
      final useCase = GetTeamCacheFirstUseCase(
          GetTeamUseCase(repository), GetCachedTeamUseCase(repository), SaveTeamCacheUseCase(repository));
      expect((await useCase.latest('1')).right?.name, 'Lava Jato');
      await useCase.latest('1');
      expect(source.teamCalls, 1);

      await repository.updateTeamDetails(id: '1', description: 'novo', imageUrl: '');
      await useCase.latest('1');
      expect(source.teamCalls, 2);
    });

    test('times por id: os da lista da temporada (cache) e só os que faltam no Firestore', () async {
      final source = _TeamsSource();
      final repository = TeamsRepositoryImpl(source, cache());
      final seasonTeams = GetTeamsCacheFirstUseCase(
        GetTeamsUseCase(repository),
        GetCachedTeamsUseCase(repository),
        SaveTeamsCacheUseCase(repository),
      );
      final useCase = GetTeamsByIdsCacheFirstUseCase(GetTeamsByIdsUseCase(repository), seasonTeams);

      final all = await useCase(ids: ['1', '2']);
      expect(all.right.map((t) => t.name), ['Lava Jato', 'Volta']);
      expect(source.byIdsAsked, isEmpty);

      final mixed = await useCase(ids: ['2', '9']);
      expect(mixed.right.map((t) => t.id), ['2', '9']);
      expect(source.byIdsAsked, [
        ['9'],
      ]);
      // A lista da temporada foi lida uma vez só (depois, do cache).
      expect(source.seasonCalls, 1);
    });
  });

  group('indique amigos', () {
    test('código conferido fica no cache; falha não', () async {
      final source = _ReferralsSource()..fail = true;
      final useCase = EnsureReferralCodeUseCase(ReferralsRepositoryImpl(source, cache()));
      expect((await useCase('abcdefgh123')).isLeft, isTrue);

      source.fail = false;
      expect((await useCase('abcdefgh123')).right, 'ABCDEFGH');
      expect((await useCase('abcdefgh123')).right, 'ABCDEFGH');
      expect(source.ensureCalls, 2);
    });

    test('"Fui indicado" usa o código do usuário da sessão; sem ele, lê o perfil', () async {
      final source = _ReferralsSource();
      final useCase = GetReferralClaimUseCase(ReferralsRepositoryImpl(source, cache()));
      expect((await useCase('u1', knownCode: '')).right.code, '');
      expect((await useCase('u1', knownCode: 'ZZZZ9999')).right.code, 'ZZZZ9999');
      expect(source.claimCalls, 0);
      expect((await useCase('u1')).right.code, 'ABCD1234');
      expect(source.claimCalls, 1);

      // Cache antigo da sessão sem o campo = não se sabe (nulo).
      const user = UserDTO(id: 'u1', name: 'Ana', email: 'a@x.com', referredBy: '');
      expect(UserDTO.fromCache(user.toCache()).referredBy, '');
      expect(UserDTO.fromCache(const UserDTO(id: 'u1', name: 'Ana', email: 'a@x.com').toCache()).referredBy, isNull);
    });
  });

  test('organizador: índices conferidos ficam no cache; só os novos (ou que falharam) são lidos', () async {
    final source = _OrganizerSource();
    final repository = OrganizerRequestsRepositoryImpl(source, _NoChampionships(), cache());
    final useCase = EnsureMyOrganizerIndexesUseCase(repository);
    const a = ChampionshipDTO(id: 'a', championshipId: 7, organizerId: 'u1');
    const b = ChampionshipDTO(id: 'b', championshipId: 8, organizerId: 'u1');

    await useCase('u1', [a]);
    await useCase('u1', [a]);
    expect(source.asked, [
      ['a'],
    ]);

    source.fail = true;
    expect((await useCase('u1', [a, b])).isLeft, isTrue);
    source.fail = false;
    await useCase('u1', [a, b]);
    await useCase('u1', [a, b]);
    expect(source.asked, [
      ['a'],
      ['b'],
      ['b'],
    ]);
  });

  group('ranking de colecionadores do álbum', () {
    test('cache válido não lê; puxar para atualizar força; pedir pacote apaga', () async {
      final source = _AlbumSource();
      final repository = AlbumRepositoryImpl(source, cache());
      final useCase = AlbumUseCase(repository);

      final first = await useCase.getRankingCacheFirst(eventId: 'ev', userId: 'u1');
      expect(first.right.myPosition, 9);
      expect(source.reads, 3);

      final cached = await useCase.getRankingCacheFirst(eventId: 'ev', userId: 'u1');
      expect(cached.right, first.right);
      expect(source.reads, 3);

      await useCase.getRankingCacheFirst(eventId: 'ev', userId: 'u1', force: true);
      expect(source.reads, 6);

      await repository.requestPack(packId: 'ev_u1_2', userId: 'u1', eventId: 'ev');
      await useCase.getRankingCacheFirst(eventId: 'ev', userId: 'u1');
      expect(source.reads, 9);
    });

    test('falha ao ler a linha da conta não vai para o cache', () async {
      final source = _AlbumSource()..failMe = true;
      final useCase = AlbumUseCase(AlbumRepositoryImpl(source, cache()));
      final partial = await useCase.getRankingCacheFirst(eventId: 'ev', userId: 'u1');
      expect(partial.right.me, isNull);
      expect(box.containsKey(CacheKeys.albumRanking(eventId: 'ev', uid: 'u1')), isFalse);

      source.failMe = false;
      expect((await useCase.getRankingCacheFirst(eventId: 'ev', userId: 'u1')).right.myPosition, 9);
      await useCase.getRankingCacheFirst(eventId: 'ev', userId: 'u1');
      expect(source.topCalls, 2);
    });
  });
}
