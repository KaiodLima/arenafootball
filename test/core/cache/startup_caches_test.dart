import 'dart:async';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:arena_soccer/core/cache/cache_keys.dart';
import 'package:arena_soccer/core/cache/cache_store.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/test_content.dart';
import 'package:arena_soccer/features/achievements/data/datasources/achievements_datasource.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_progress_dto.dart';
import 'package:arena_soccer/features/achievements/data/repositories/achievements_repository_impl.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/get_achievements_catalog_cache_first_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/get_achievements_catalog_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/get_cached_achievements_catalog_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/mark_achievement_seen_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/record_achievement_action_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/record_daily_visit_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/save_achievements_catalog_cache_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/watch_achievement_progress_usecase.dart';
import 'package:arena_soccer/features/achievements/domain/usecases/watch_achievement_unlocks_usecase.dart';
import 'package:arena_soccer/features/achievements/presentation/bloc/achievements_cubit.dart';
import 'package:arena_soccer/features/app_version/data/datasources/app_version_datasource.dart';
import 'package:arena_soccer/features/app_version/data/repositories/app_version_repository_impl.dart';
import 'package:arena_soccer/features/app_version/domain/app_update.dart';
import 'package:arena_soccer/features/app_version/domain/usecases/app_version_usecases.dart';
import 'package:arena_soccer/features/auth/data/datasources/auth_datasource.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:arena_soccer/features/matches/data/datasources/matches_datasource.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/repositories/matches_repository_impl.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_cached_region_matches_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_region_matches_cache_first_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_region_matches_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_today_matches_usecase.dart';
import 'package:arena_soccer/features/matches/domain/usecases/save_region_matches_cache_usecase.dart';

// Caches da abertura do app (fase 1): repositórios reais (cache no Hive) sobre
// DataSources falsos que contam as leituras remotas.

class _AuthSource implements AuthDataSource {
  @override
  String? get currentUserId => 'u1';

  @override
  Future<Either<Failure, void>> updateFavoriteTeam({
    required String userId,
    required String team,
    required String teamId,
    bool stampChange = false,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateName({required String userId, required String name}) async => const Right(null);

  @override
  Future<Either<Failure, void>> updatePhoto({required String userId, required String photoUrl}) async =>
      const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _VersionSource implements AppVersionDataSource {
  int calls = 0;
  AppVersionConfig config = const AppVersionConfig(recommendedAndroid: 44);

  @override
  Future<Either<Failure, AppVersionConfig>> getConfig() async {
    calls++;
    return Right(config);
  }

  @override
  Future<Either<Failure, void>> saveConfig(AppVersionConfig config) async {
    this.config = config;
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MatchesSource implements MatchesDataSource {
  int calls = 0;
  List<MatchDTO> matches = const [
    MatchDTO(id: 'm1', homeTeam: 'Lava Jato', awayTeam: 'Volta', region: 'Floresta', date: '18/10', time: '18:00'),
    MatchDTO(id: 'm2', homeTeam: 'Riacho', awayTeam: 'Volta', region: 'Floresta', date: '18/10', time: '09:00'),
    MatchDTO(id: 'm3', homeTeam: 'Riacho', awayTeam: 'Lava Jato', region: 'Floresta', date: '19/10'),
  ];

  @override
  Stream<Either<Failure, List<MatchDTO>>> watchMatches({String? season, String? region}) {
    calls++;
    return Stream.value(Right(matches));
  }

  @override
  Future<Either<Failure, void>> updateScore({
    required String matchId,
    required int homeGoals,
    required int awayGoals,
    String? season,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> createMatch(MatchDTO match, {String? season}) async => const Right(null);

  @override
  Future<Either<Failure, void>> deleteMatch({required String matchId, String? season}) async => const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _AchievementsSource implements AchievementsDataSource {
  int calls = 0;
  List<AchievementDTO> catalog = const [AchievementDTO(id: 'a1', title: 'Votou', metric: AchievementMetric.votes)];
  final progress = StreamController<Either<Failure, AchievementProgressDTO>>.broadcast();
  final unlocks = StreamController<Either<Failure, List<AchievementUnlockDTO>>>.broadcast();

  @override
  Future<Either<Failure, List<AchievementDTO>>> getCatalog() async {
    calls++;
    return Right(catalog);
  }

  @override
  Stream<Either<Failure, AchievementProgressDTO>> watchProgress(String uid) => progress.stream;

  @override
  Stream<Either<Failure, List<AchievementUnlockDTO>>> watchUnlocks(String uid) => unlocks.stream;

  @override
  Future<Either<Failure, void>> recordVisit(
    String uid, {
    required int activeDays,
    required int streak,
    required int bestStreak,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> saveAchievement(AchievementDTO achievement) async => const Right(null);

  @override
  Future<Either<Failure, void>> deleteAchievement(String id) async => const Right(null);

  @override
  Future<Either<Failure, void>> createAchievements(List<AchievementDTO> achievements) async => const Right(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final _old = DateTime.now().subtract(const Duration(days: 1));

void main() {
  late Directory dir;
  late Box<String> box;
  var boxes = 0;

  setUpAll(() {
    dir = Directory.systemTemp.createTempSync('arena_startup_caches_test');
    Hive.init(dir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  setUp(() async => box = await Hive.openBox<String>('startup_${boxes++}'));

  tearDown(() async {
    TestContent.configure(visible: false);
    await box.deleteFromDisk();
  });

  /// Cache com o relógio de gravação [savedAt] (padrão: agora).
  CacheStore cache([DateTime? savedAt]) => CacheStore(box, now: savedAt == null ? null : () => savedAt);

  group('sessão (usuário da conta)', () {
    const user = UserDTO(id: 'u1', name: 'Kaio', email: 'k@x.com', favoriteTeam: 'Lava Jato');

    test('gravar time do coração, nome ou foto apaga a conta do cache', () async {
      final store = cache();
      final repository = AuthRepositoryImpl(_AuthSource(), store);
      Future<bool> cached() async => (await repository.getCachedUser()).right != null;

      await repository.saveUserCache(user);
      expect(await cached(), isTrue);
      await repository.updateFavoriteTeam(userId: 'u1', team: 'Volta', teamId: '2');
      expect(await cached(), isFalse);

      await repository.saveUserCache(user);
      await repository.updateName(userId: 'u1', name: 'Kaio L');
      expect(await cached(), isFalse);

      await repository.saveUserCache(user);
      await repository.updatePhoto(userId: 'u1', photoUrl: 'https://img/u.png');
      expect(await cached(), isFalse);
    });
  });

  group('config/versao (AppVersionCacheFirstUseCase)', () {
    AppVersionCacheFirstUseCase useCase(AppVersionRepositoryImpl repository) => AppVersionCacheFirstUseCase(
          GetAppVersionConfigUseCase(repository),
          GetCachedAppVersionConfigUseCase(repository),
          SaveAppVersionConfigCacheUseCase(repository),
        );

    test('cache válido não lê; vencido mostra o cache e atualiza', () async {
      final source = _VersionSource();
      await useCase(AppVersionRepositoryImpl(source, cache(_old)))().last;
      expect(source.calls, 1);

      source.config = const AppVersionConfig(recommendedAndroid: 45);
      final stale = await useCase(AppVersionRepositoryImpl(source, cache()))().toList();
      expect(stale.map((r) => r.right.recommendedAndroid), [44, 45]);
      expect(source.calls, 2);

      final fresh = await useCase(AppVersionRepositoryImpl(source, cache()))().toList();
      expect(fresh.single.right.recommendedAndroid, 45);
      expect(source.calls, 2);
    });

    test('o admin gravar apaga o cache; o painel (sem cache) lê sempre', () async {
      final source = _VersionSource();
      final repository = AppVersionRepositoryImpl(source, cache());
      await useCase(repository)().last;
      await GetAppVersionConfigUseCase(repository)();
      expect(source.calls, 2);

      await SaveAppVersionConfigUseCase(repository)(const AppVersionConfig(minAndroid: 46, recommendedAndroid: 46));
      expect(box.containsKey(CacheKeys.appVersion), isFalse);
      expect((await useCase(repository)().last).right.minAndroid, 46);
      expect(source.calls, 3);
    });
  });

  group('partidas da região (GetRegionMatchesCacheFirstUseCase)', () {
    GetRegionMatchesCacheFirstUseCase useCase(MatchesRepositoryImpl repository) => GetRegionMatchesCacheFirstUseCase(
          GetRegionMatchesUseCase(repository),
          GetCachedRegionMatchesUseCase(repository),
          SaveRegionMatchesCacheUseCase(repository),
        );

    test('cache válido não lê; vencido mostra o cache e atualiza', () async {
      final source = _MatchesSource();
      await useCase(MatchesRepositoryImpl(source, cache(_old)))(region: 'Floresta', season: '2026').last;
      expect(source.calls, 1);

      source.matches = [source.matches.first.copyWith(homeGoals: 3)];
      final stale = await useCase(MatchesRepositoryImpl(source, cache()))(region: 'Floresta', season: '2026').toList();
      expect(stale.map((r) => r.right.length), [3, 1]);
      expect(source.calls, 2);

      final fresh = await useCase(MatchesRepositoryImpl(source, cache())).latest(region: 'Floresta', season: '2026');
      expect(fresh.right.single.homeGoals, 3);
      expect(source.calls, 2);
    });

    test('jogos de hoje: a mesma lista em cache, filtrada e por horário (sem outra leitura)', () async {
      final source = _MatchesSource();
      final cached = useCase(MatchesRepositoryImpl(source, cache()));
      await cached.latest(region: 'Floresta', season: '2026');
      final today = await GetTodayMatchesUseCase(cached)(
        region: 'Floresta',
        season: '2026',
        now: DateTime(2026, 10, 18, 12),
      );
      expect(today.right.map((m) => m.id), ['m2', 'm1']);
      expect(source.calls, 1);
    });

    test('gravar uma partida (placar, cadastro, exclusão) apaga o cache', () async {
      final source = _MatchesSource();
      final repository = MatchesRepositoryImpl(source, cache());
      bool hasCache() => box.keys.any((key) => CacheKeys.isRegionMatchesKey(key.toString()));

      await useCase(repository).latest(region: 'Floresta', season: '2026');
      expect(hasCache(), isTrue);
      await repository.updateScore(matchId: 'm1', homeGoals: 1, awayGoals: 0, season: '2026');
      expect(hasCache(), isFalse);

      await useCase(repository).latest(region: 'Floresta', season: '2026');
      expect(source.calls, 2);
      await repository.createMatch(const MatchDTO(homeTeam: 'A', awayTeam: 'B'), season: '2026');
      expect(hasCache(), isFalse);

      await useCase(repository).latest(region: 'Floresta', season: '2026');
      await repository.deleteMatch(matchId: 'm1', season: '2026');
      expect(hasCache(), isFalse);
    });

    test('a conta admin (vê as partidas de teste) tem a chave dela', () {
      final common = CacheKeys.regionMatches(region: 'Floresta', season: '2026');
      TestContent.configure(visible: true);
      expect(CacheKeys.regionMatches(region: 'Floresta', season: '2026'), isNot(common));
      expect(CacheKeys.isRegionMatchesKey(CacheKeys.regionMatches(region: 'Floresta', season: '2026')), isTrue);
    });
  });

  group('catálogo de conquistas', () {
    GetAchievementsCatalogCacheFirstUseCase useCase(AchievementsRepositoryImpl repository) =>
        GetAchievementsCatalogCacheFirstUseCase(
          GetAchievementsCatalogUseCase(repository),
          GetCachedAchievementsCatalogUseCase(repository),
          SaveAchievementsCatalogCacheUseCase(repository),
        );

    test('cache válido não lê; vencido mostra o cache e atualiza', () async {
      final source = _AchievementsSource();
      await useCase(AchievementsRepositoryImpl(source, cache(_old)))().last;
      expect(source.calls, 1);

      source.catalog = [
        ...source.catalog,
        const AchievementDTO(id: 'a2', title: 'Leu', metric: AchievementMetric.newsRead)
      ];
      final stale = await useCase(AchievementsRepositoryImpl(source, cache()))().toList();
      expect(stale.map((r) => r.right.length), [1, 2]);
      expect(source.calls, 2);

      await useCase(AchievementsRepositoryImpl(source, cache()))().last;
      expect(source.calls, 2);
    });

    test('o admin salvar, excluir ou criar as sugeridas apaga o cache', () async {
      final source = _AchievementsSource();
      final repository = AchievementsRepositoryImpl(source, cache());
      bool hasCache() => box.containsKey(CacheKeys.achievementsCatalog);

      await useCase(repository)().last;
      expect(hasCache(), isTrue);
      await repository.saveAchievement(source.catalog.first);
      expect(hasCache(), isFalse);

      await useCase(repository)().last;
      await repository.deleteAchievement('a1');
      expect(hasCache(), isFalse);

      await useCase(repository)().last;
      await repository.createAchievements(source.catalog);
      expect(hasCache(), isFalse);
      expect(source.calls, 3);
    });

    test('AchievementsCubit: catálogo do cache; progresso e desbloqueios seguem ao vivo', () async {
      final source = _AchievementsSource();
      final repository = AchievementsRepositoryImpl(source, cache());
      await useCase(repository)().last;
      source.calls = 0;

      final cubit = AchievementsCubit(
        useCase(repository),
        WatchAchievementProgressUseCase(repository),
        WatchAchievementUnlocksUseCase(repository),
        RecordAchievementActionUseCase(repository),
        RecordDailyVisitUseCase(repository),
        MarkAchievementSeenUseCase(repository),
      );
      cubit.follow('u1');
      await Future<void>.delayed(Duration.zero);
      expect(source.calls, 0);
      expect(cubit.state.catalog.single.id, 'a1');
      expect(cubit.state.loading, isFalse);

      // Desbloqueio novo chega pelo stream: comemoração (não vista).
      source.unlocks.add(const Right([AchievementUnlockDTO(achievementId: 'a1')]));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.unseen.single.id, 'a1');
      await cubit.close();
    });
  });
}
