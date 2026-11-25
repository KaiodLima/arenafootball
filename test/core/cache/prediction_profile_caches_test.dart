import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/season_collection.dart';
import 'package:arena_soccer/features/matches/data/datasources/matches_datasource.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/repositories/matches_repository_impl.dart';
import 'package:arena_soccer/features/players/data/datasources/players_datasource.dart';
import 'package:arena_soccer/features/players/data/dtos/player_dto.dart';
import 'package:arena_soccer/features/players/data/repositories/players_repository_impl.dart';
import 'package:arena_soccer/features/players/domain/usecases/get_player_awards_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/get_player_season_history_usecase.dart';
import 'package:arena_soccer/features/players/domain/usecases/player_awards_cache_usecases.dart';
import 'package:arena_soccer/features/players/domain/usecases/player_season_history_cache_usecases.dart';
import 'package:arena_soccer/features/predictions/data/datasources/predictions_datasource.dart';
import 'package:arena_soccer/features/predictions/data/dtos/prediction_dto.dart';
import 'package:arena_soccer/features/predictions/data/repositories/predictions_repository_impl.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/count_predictions_usecase.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/get_my_predictions_usecase.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/get_prediction_ranking_usecase.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/my_predictions_cache_usecases.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/prediction_count_cache_usecases.dart';
import 'package:arena_soccer/features/predictions/domain/usecases/prediction_ranking_cache_usecases.dart';

// Caches do bolão e do perfil do atleta (fase 2): repositórios reais (cache
// no Hive) sobre DataSources falsos que contam as leituras remotas.

class _PredictionsSource implements PredictionsDataSource {
  int topCalls = 0;
  int mineCalls = 0;
  int aheadCalls = 0;
  int countCalls = 0;
  final asked = <List<String>>[];

  List<PredictionRankingEntry> top = const [PredictionRankingEntry(uid: 'x', name: 'X', points: 50)];
  PredictionRankingEntry? mineEntry = const PredictionRankingEntry(uid: 'me', name: 'Eu', points: 7);
  int ahead = 63;
  int total = 12;
  bool failMine = false;
  bool failAhead = false;
  final predictions = <String, PredictionDTO>{'m1': const PredictionDTO(uid: 'me', home: 2, away: 1)};

  int get rankingReads => topCalls + mineCalls + aheadCalls;

  @override
  Future<Either<Failure, List<PredictionRankingEntry>>> topOfRegion({
    required String regionId,
    String? season,
    int limit = 50,
  }) async {
    topCalls++;
    return Right(top);
  }

  @override
  Future<Either<Failure, PredictionRankingEntry?>> mine(
      {required String regionId, required String uid, String? season}) async {
    mineCalls++;
    if (failMine) return Left(ErrorWithMessage('offline'));
    return Right(uid == 'me' ? mineEntry : null);
  }

  @override
  Future<Either<Failure, int>> aheadOf({required String regionId, required int points, String? season}) async {
    aheadCalls++;
    if (failAhead) return Left(ErrorWithMessage('offline'));
    return Right(ahead);
  }

  @override
  Future<Either<Failure, Map<String, PredictionDTO>>> getMine({
    required List<String> matchIds,
    required String uid,
    String? season,
  }) async {
    asked.add(matchIds);
    return Right({
      for (final id in matchIds)
        if (predictions.containsKey(id)) id: predictions[id]!,
    });
  }

  @override
  Future<Either<Failure, void>> save({
    required String matchId,
    required String uid,
    required String name,
    required int home,
    required int away,
    String? season,
  }) async {
    predictions[matchId] = PredictionDTO(uid: uid, home: home, away: away, name: name);
    return const Right(null);
  }

  @override
  Future<Either<Failure, int>> count({required String matchId, String? season}) async {
    countCalls++;
    return Right(total);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MatchesSource implements MatchesDataSource {
  int electedCalls = 0;
  int countCalls = 0;

  @override
  Future<Either<Failure, List<MatchDTO>>> getElectedMatches({required String playerId, String? season}) async {
    electedCalls++;
    return const Right([MatchDTO(id: 'm1', homeTeam: 'Lava Jato', awayTeam: 'Volta', electedPlayerId: 'p1')]);
  }

  @override
  Future<Either<Failure, int>> countElectedMatches({required String playerId, String? season}) async {
    countCalls++;
    return const Right(2);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PlayersSource implements PlayersDataSource {
  int calls = 0;

  /// Temporadas em que a conta tem cadastro.
  Set<String> seasons = {'2025', '2026'};

  @override
  Future<Either<Failure, PlayerDTO?>> getPlayerByUser({required String userId, String? season}) async {
    calls++;
    return Right(seasons.contains(season)
        ? PlayerDTO(id: 'p$season', name: 'Dudu', team: 'Lava Jato', teamId: '1', goals: 3, userId: userId)
        : null);
  }

  @override
  Future<Either<Failure, void>> updatePlayer(PlayerDTO player, {String? season}) async => const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _old = DateTime.now().subtract(const Duration(days: 2));
final _hourAgo = DateTime.now().subtract(const Duration(hours: 1));

void main() {
  late Directory dir;
  late Box<String> box;
  var boxes = 0;

  setUpAll(() {
    dir = Directory.systemTemp.createTempSync('arena_prediction_profile_caches_test');
    Hive.init(dir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  setUp(() async => box = await Hive.openBox<String>('phase2_${boxes++}'));

  tearDown(() async {
    SeasonCollection.reset();
    await box.deleteFromDisk();
  });

  /// Cache com o relógio de gravação [savedAt] (padrão: agora).
  CacheStore cache([DateTime? savedAt]) => CacheStore(box, now: savedAt == null ? null : () => savedAt);

  group('ranking do bolão (GetPredictionRankingCacheFirstUseCase)', () {
    GetPredictionRankingCacheFirstUseCase useCase(PredictionsRepositoryImpl repository) =>
        GetPredictionRankingCacheFirstUseCase(
          GetPredictionRankingUseCase(repository),
          GetCachedPredictionRankingUseCase(repository),
          SavePredictionRankingCacheUseCase(repository),
        );

    test('cache válido não lê; vencido mostra o cache e atualiza; puxar para atualizar força', () async {
      final source = _PredictionsSource();
      await useCase(PredictionsRepositoryImpl(source, cache(_old)))(regionId: 'r1', uid: 'me', season: '2026').last;
      // Fora do top: top + a linha + quantos à frente.
      expect(source.rankingReads, 3);

      source.top = const [PredictionRankingEntry(uid: 'x', name: 'X', points: 55)];
      final stale =
          await useCase(PredictionsRepositoryImpl(source, cache()))(regionId: 'r1', uid: 'me', season: '2026').toList();
      expect(stale.map((r) => r.right.top.single.points), [50, 55]);
      expect(stale.last.right.myPosition, 64);
      expect(source.rankingReads, 6);

      final fresh =
          await useCase(PredictionsRepositoryImpl(source, cache()))(regionId: 'r1', uid: 'me', season: '2026').toList();
      expect(fresh.single.right.mine?.points, 7);
      expect(fresh.single.right.myPosition, 64);
      expect(source.rankingReads, 6);

      await useCase(PredictionsRepositoryImpl(source, cache()))(regionId: 'r1', uid: 'me', season: '2026', force: true)
          .last;
      expect(source.rankingReads, 9);
    });

    test('top 50 é da região (todas as contas); a linha e a posição, por conta', () async {
      final source = _PredictionsSource()
        ..top = const [
          PredictionRankingEntry(uid: 'x', name: 'X', points: 50),
          PredictionRankingEntry(uid: 'in', name: 'No top', points: 60),
        ];
      final repository = PredictionsRepositoryImpl(source, cache());

      // Conta no top: posição pela lista, nada além do top no cache.
      final inTop = await useCase(repository)(regionId: 'r1', uid: 'in', season: '2026').last;
      expect(inTop.right.myPosition, 1);
      expect(source.rankingReads, 1);
      expect(box.keys.where((k) => k.toString().startsWith('prediction_standing_')), isEmpty);

      // Outra conta fora do top: o top vem do cache, só a linha dela é lida.
      final out = await useCase(repository)(regionId: 'r1', uid: 'me', season: '2026').last;
      expect(out.right.myPosition, 64);
      expect((source.topCalls, source.mineCalls, source.aheadCalls), (1, 1, 1));

      // Convidado e as duas contas de novo: tudo do cache.
      await useCase(repository)(regionId: 'r1', season: '2026').last;
      await useCase(repository)(regionId: 'r1', uid: 'in', season: '2026').last;
      await useCase(repository)(regionId: 'r1', uid: 'me', season: '2026').last;
      expect(source.rankingReads, 3);

      // Conta sem pontos: o "sem linha" também fica no cache.
      await useCase(repository)(regionId: 'r1', uid: 'nobody', season: '2026').last;
      final none = await useCase(repository)(regionId: 'r1', uid: 'nobody', season: '2026').last;
      expect(none.right.mine, isNull);
      expect(source.mineCalls, 2);
      expect(source.aheadCalls, 1);
    });

    test('falha ao ler a linha ou o "à frente" não vai para o cache', () async {
      final source = _PredictionsSource()..failMine = true;
      final repository = PredictionsRepositoryImpl(source, cache());

      final failed = await useCase(repository)(regionId: 'r1', uid: 'me', season: '2026').last;
      expect(failed.right.mine, isNull);
      expect(box.keys.where((k) => k.toString().startsWith('prediction_standing_')), isEmpty);

      // De novo: o top vem do cache válido, a linha é lida outra vez.
      source
        ..failMine = false
        ..failAhead = true;
      final noPosition = await useCase(repository)(regionId: 'r1', uid: 'me', season: '2026').last;
      expect(noPosition.right.myPosition, isNull);
      expect(box.keys.where((k) => k.toString().startsWith('prediction_standing_')), isEmpty);
      expect((source.topCalls, source.mineCalls, source.aheadCalls), (1, 2, 1));

      source.failAhead = false;
      final ok = await useCase(repository)(regionId: 'r1', uid: 'me', season: '2026').last;
      expect(ok.right.myPosition, 64);
      expect((source.topCalls, source.mineCalls, source.aheadCalls), (1, 3, 2));
      await useCase(repository)(regionId: 'r1', uid: 'me', season: '2026').last;
      expect(source.rankingReads, 6);
    });
  });

  group('meus palpites (GetMyPredictionsCacheFirstUseCase)', () {
    GetMyPredictionsCacheFirstUseCase useCase(PredictionsRepositoryImpl repository) =>
        GetMyPredictionsCacheFirstUseCase(
          GetMyPredictionsUseCase(repository),
          GetCachedMyPredictionsUseCase(repository),
          SaveMyPredictionsCacheUseCase(repository),
        );

    test('por partida: cache válido não lê; só as sem cache ou vencidas vão ao Firestore', () async {
      final source = _PredictionsSource();
      final first = await useCase(PredictionsRepositoryImpl(source, cache(_old)))
          .latest(matchIds: ['m1'], uid: 'me', season: '2026');
      expect(first.right.keys, ['m1']);

      // m1 vencida (mostra e atualiza), m2 sem cache.
      source.predictions['m1'] = const PredictionDTO(uid: 'me', home: 3, away: 0);
      final stale = await useCase(PredictionsRepositoryImpl(source, cache()))(
        matchIds: ['m1', 'm2'],
        uid: 'me',
        season: '2026',
      ).toList();
      expect(stale.map((r) => r.right['m1']?.home), [2, 3]);
      expect(source.asked.last, ['m1', 'm2']);

      // Válidas (m2 salva como "não palpitou"): só a m3, nova, é lida.
      final fresh = await useCase(PredictionsRepositoryImpl(source, cache()))
          .latest(matchIds: ['m1', 'm2', 'm3'], uid: 'me', season: '2026');
      expect(fresh.right.keys, ['m1']);
      expect(source.asked.last, ['m3']);

      await useCase(PredictionsRepositoryImpl(source, cache()))(matchIds: ['m1', 'm2', 'm3'], uid: 'me', season: '2026')
          .last;
      expect(source.asked.length, 3);
    });

    test('palpitar apaga o cache daquela partida: a volta da folha mostra o novo na hora', () async {
      final source = _PredictionsSource();
      final repository = PredictionsRepositoryImpl(source, cache());
      await useCase(repository).latest(matchIds: ['m1', 'm2'], uid: 'me', season: '2026');
      expect(box.containsKey(CacheKeys.myPrediction(matchId: 'm2', uid: 'me', season: '2026')), isTrue);

      await repository.save(matchId: 'm2', uid: 'me', name: 'Eu', home: 1, away: 1, season: '2026');
      expect(box.containsKey(CacheKeys.myPrediction(matchId: 'm2', uid: 'me', season: '2026')), isFalse);
      expect(box.containsKey(CacheKeys.myPrediction(matchId: 'm1', uid: 'me', season: '2026')), isTrue);

      // `refreshPrediction` do hub: lê só a partida palpitada.
      final refreshed = await useCase(repository).latest(matchIds: ['m2'], uid: 'me', season: '2026');
      expect((refreshed.right['m2']?.home, refreshed.right['m2']?.away), (1, 1));
      expect(source.asked.last, ['m2']);
    });

    test('sem conta ou sem partidas: vazio sem leitura', () async {
      final source = _PredictionsSource();
      final repository = PredictionsRepositoryImpl(source, cache());
      expect((await useCase(repository).latest(matchIds: ['m1'], uid: '')).right, isEmpty);
      expect((await useCase(repository).latest(matchIds: const [], uid: 'me')).right, isEmpty);
      expect(source.asked, isEmpty);
    });
  });

  group('contagem de palpites da partida (CountPredictionsCacheFirstUseCase)', () {
    CountPredictionsCacheFirstUseCase useCase(PredictionsRepositoryImpl repository) =>
        CountPredictionsCacheFirstUseCase(
          CountPredictionsUseCase(repository),
          GetCachedPredictionCountUseCase(repository),
          SavePredictionCountCacheUseCase(repository),
        );

    test('cache válido não lê; vencido mostra o cache e atualiza; palpitar apaga', () async {
      final source = _PredictionsSource();
      await useCase(PredictionsRepositoryImpl(source, cache(_old)))(matchId: 'm1', season: '2026').last;
      expect(source.countCalls, 1);

      source.total = 15;
      final stale = await useCase(PredictionsRepositoryImpl(source, cache()))(matchId: 'm1', season: '2026').toList();
      expect(stale.map((r) => r.right), [12, 15]);
      expect(source.countCalls, 2);

      final repository = PredictionsRepositoryImpl(source, cache());
      expect((await useCase(repository)(matchId: 'm1', season: '2026').toList()).single.right, 15);
      expect(source.countCalls, 2);

      await repository.save(matchId: 'm1', uid: 'me', name: 'Eu', home: 0, away: 0, season: '2026');
      expect(box.containsKey(CacheKeys.predictionCount(matchId: 'm1', season: '2026')), isFalse);
    });
  });

  group('perfil do atleta: troféus e histórico por temporada', () {
    setUp(() => SeasonCollection.configure(current: '2026', seasons: const ['2024', '2025', '2026']));

    GetPlayerAwardsCacheFirstUseCase awards(MatchesRepositoryImpl repository) => GetPlayerAwardsCacheFirstUseCase(
          GetPlayerAwardsUseCase(repository),
          GetCachedPlayerAwardsUseCase(repository),
          SavePlayerAwardsCacheUseCase(repository),
        );

    GetPlayerSeasonHistoryCacheFirstUseCase history(PlayersRepositoryImpl players, MatchesRepositoryImpl matches) =>
        GetPlayerSeasonHistoryCacheFirstUseCase(
          GetPlayerSeasonHistoryUseCase(players, matches),
          GetCachedPlayerSeasonSummaryUseCase(players),
          SavePlayerSeasonSummaryCacheUseCase(players),
        );

    test('troféus: temporada atual vale 10 min; as passadas, 24 h', () async {
      final source = _MatchesSource();
      await awards(MatchesRepositoryImpl(source, cache(_hourAgo)))(playerId: 'p1', season: '2026').last;
      await awards(MatchesRepositoryImpl(source, cache(_hourAgo)))(playerId: 'p1', season: '2025').last;
      expect(source.electedCalls, 2);

      // Salvos há 1 h: a atual (vencida) mostra e atualiza; a passada não lê.
      final current = await awards(MatchesRepositoryImpl(source, cache()))(playerId: 'p1', season: '2026').toList();
      expect(current.single.right.single.id, 'm1');
      expect(source.electedCalls, 3);
      final past = await awards(MatchesRepositoryImpl(source, cache()))(playerId: 'p1', season: '2025').toList();
      expect(past.single.right.single.electedPlayerId, 'p1');
      expect(source.electedCalls, 3);

      // Temporada nula = a atual (mesma chave), agora válida.
      await awards(MatchesRepositoryImpl(source, cache()))(playerId: 'p1').last;
      expect(source.electedCalls, 3);
    });

    test('histórico: cada temporada no cache (a sem cadastro também); a atual revalida antes', () async {
      final players = _PlayersSource();
      final matches = _MatchesSource();
      final seasons = ['2024', '2025', '2026'];
      final first = await history(
        PlayersRepositoryImpl(players, cache(_hourAgo)),
        MatchesRepositoryImpl(matches, cache(_hourAgo)),
      )(userId: 'u1', seasons: seasons);
      expect(first.right.map((s) => (s.season, s.awards)), [('2026', 2), ('2025', 2)]);
      expect((players.calls, matches.countCalls), (3, 2));

      final second = await history(
        PlayersRepositoryImpl(players, cache()),
        MatchesRepositoryImpl(matches, cache()),
      )(userId: 'u1', seasons: seasons);
      expect(second.right.map((s) => s.season), ['2026', '2025']);
      // Só a atual (salva há 1 h) foi lida de novo.
      expect((players.calls, matches.countCalls), (4, 3));
    });

    test('gravar um jogador apaga o histórico do cache', () async {
      final players = PlayersRepositoryImpl(_PlayersSource(), cache());
      await history(players, MatchesRepositoryImpl(_MatchesSource(), cache()))(userId: 'u1', seasons: const ['2026']);
      bool hasCache() => box.keys.any((key) => CacheKeys.isPlayerSeasonKey(key.toString()));
      expect(hasCache(), isTrue);

      await players.updatePlayer(const PlayerDTO(id: 'p2026', name: 'Dudu', team: 'Lava Jato'), season: '2026');
      expect(hasCache(), isFalse);
    });
  });
}
