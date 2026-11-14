import 'dart:io';
import 'dart:ui' as ui;

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_dto.dart';
import 'package:arena_soccer/features/achievements/data/dtos/achievement_progress_dto.dart';
import 'package:arena_soccer/features/achievements/domain/achievement_metric.dart';
import 'package:arena_soccer/features/achievements/presentation/bloc/achievements_cubit.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/domain/usecases/get_account_created_at_usecase.dart';
import 'package:arena_soccer/features/auth/domain/usecases/update_user_photo_usecase.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';
import 'package:arena_soccer/features/fan_card/presentation/bloc/fan_card_cubit.dart';
import 'package:arena_soccer/features/fan_card/presentation/page/fan_card_page.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/my_player_cubit.dart';
import 'package:arena_soccer/features/player_requests/presentation/bloc/my_player_state.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_state.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/owned_team_cubit.dart';
import 'package:arena_soccer/features/team_requests/presentation/bloc/owned_team_state.dart';
import 'package:arena_soccer/features/teams/data/dtos/team_dto.dart';
import 'package:arena_soccer/features/teams/domain/usecases/get_team_by_name_cache_first_usecase.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

// Prévia em PNG fora do CI: FAN_CARD_PREVIEW=1 flutter test test/features/fan_card/fan_card_page_test.dart
// → build/fan_card_previews/<caso>.png

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}

const _fan = UserDTO(id: 'aB3d9Xy7Zq', name: 'Kaio Lima', email: 'k@x.com', favoriteTeam: 'Lava Jato');

class _Teams implements GetTeamByNameCacheFirstUseCase {
  @override
  Stream<Either<Failure, TeamDTO?>> call(String name, {String id = '', bool force = false}) => Stream.value(Right(
        TeamDTO(
          id: 't1',
          name: name,
          region: 'Floresta',
          primaryColor: TeamColor.navy.hex,
          secondaryColor: TeamColor.yellow.hex,
        ),
      ));
}

class _Photo implements UpdateUserPhotoUseCase {
  @override
  Future<Either<Failure, String>> call({required String userId, required File photo}) async => const Right('');
}

class _CreatedAt implements GetAccountCreatedAtUseCase {
  @override
  DateTime? call() => DateTime(2024, 3, 1);
}

class _Session extends Cubit<SessionState> implements SessionCubit {
  _Session(UserDTO user) : super(AuthenticatedSessionState(user: user));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Region extends Cubit<RegionState> implements RegionCubit {
  _Region() : super(const RegionState(regions: ['Floresta'], selectedRegion: 'Floresta', selectedSeason: '2026'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MyPlayer extends Cubit<MyPlayerState> implements MyPlayerCubit {
  _MyPlayer() : super(const MyPlayerState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Owned extends Cubit<OwnedTeamState> implements OwnedTeamCubit {
  _Owned() : super(const OwnedTeamState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Achievements extends Cubit<AchievementsState> implements AchievementsCubit {
  _Achievements()
      : super(const AchievementsState(
          loading: false,
          catalog: [
            AchievementDTO(
                id: 'a1', title: 'A', metric: AchievementMetric.votes, tier: AchievementTier.gold, points: 120),
            AchievementDTO(
                id: 'a2',
                title: 'B',
                metric: AchievementMetric.shares,
                tier: AchievementTier.silver,
                icon: 'share',
                points: 60),
            AchievementDTO(id: 'a3', title: 'C', metric: AchievementMetric.newsRead, icon: 'heart', points: 40),
            AchievementDTO(id: 'a4', title: 'D', metric: AchievementMetric.activeDays, goal: 30, points: 50),
          ],
          unlocks: {
            'a1': AchievementUnlockDTO(achievementId: 'a1'),
            'a2': AchievementUnlockDTO(achievementId: 'a2'),
            'a3': AchievementUnlockDTO(achievementId: 'a3'),
          },
        ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Future<void> pump(WidgetTester tester, {UserDTO user = _fan, Key? boundary}) async {
    tester.view.physicalSize = const Size(392, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(KeyedSubtree(
      key: ValueKey(user.id),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>(create: (_) => _Session(user)),
          BlocProvider<RegionCubit>(create: (_) => _Region()),
          BlocProvider<MyPlayerCubit>(create: (_) => _MyPlayer()),
          BlocProvider<OwnedTeamCubit>(create: (_) => _Owned()),
          BlocProvider<AchievementsCubit>(create: (_) => _Achievements()),
          BlocProvider<FanCardCubit>(create: (_) => FanCardCubit(_Teams(), _Photo(), _CreatedAt())),
        ],
        child: RepaintBoundary(
          key: boundary,
          child: const MediaQuery(
            // Sem a balançada contínua (pumpAndSettle termina).
            data: MediaQueryData(disableAnimations: true, size: Size(392, 900)),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: Locale('pt'),
              home: FanCardPage(),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('frente com nome, número e nível; o toque vira para o verso', (tester) async {
    await pump(tester);
    expect(find.text('KAIO LIMA'), findsOneWidget);
    expect(find.text('AB3D  9XY7'), findsOneWidget);
    expect(find.text('SÓCIO TORCEDOR'), findsOneWidget);
    expect(find.text('SEU NÍVEL DE TORCEDOR'), findsOneWidget);
    expect(find.byKey(const ValueKey('fan-card-back')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('fan-card-front')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('fan-card-back')), findsOneWidget);
    expect(find.text('VÁLIDA NA TEMPORADA 2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('troca de time travada: o botão mostra o aviso com a data', (tester) async {
    await pump(tester, user: _fan.copyWith(teamChangedAt: DateTime.now().subtract(const Duration(days: 2))));
    expect(find.byIcon(Icons.lock_clock_rounded), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('fan-card-team')));
    await tester.pumpAndSettle();
    expect(find.textContaining('15 dias'), findsWidgets);
  });

  testWidgets('prévias da carteirinha', (tester) async {
    await tester.runAsync(() async {
      await _font('Anton', ['lib/assets/fonts/anton/Anton-Regular.ttf']);
      await _font('BarlowCondensed', [
        'lib/assets/fonts/barlow_condensed/BarlowCondensed-SemiBold.ttf',
        'lib/assets/fonts/barlow_condensed/BarlowCondensed-Bold.ttf',
      ]);
      await _font('Alkatra', ['lib/assets/fonts/alkatra/Alkatra-Regular.ttf']);
      await _font('Roboto', ['lib/assets/fonts/roboto/Roboto-Regular.ttf']);
      await _font('Montserrat', ['lib/assets/fonts/montserrat/Montserrat-VariableFont_wght.ttf']);
      final root = Platform.environment['FLUTTER_ROOT'] ?? '';
      await _font('MaterialIcons', ['$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
    });
    Directory('build/fan_card_previews').createSync(recursive: true);
    Future<void> shot(String name, GlobalKey key) async {
      final png = await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      });
      File('build/fan_card_previews/$name.png').writeAsBytesSync(png!);
    }

    final key = GlobalKey();
    await pump(tester, boundary: key);
    await shot('tela_frente', key);
    await tester.tap(find.byKey(const ValueKey('fan-card-front')));
    await tester.pumpAndSettle();
    await shot('tela_verso', key);
    final noTeam = GlobalKey();
    await pump(tester,
        user: const UserDTO(id: 'zz91kk20', name: 'Ana Beatriz Souza', email: 'a@x.com'), boundary: noTeam);
    await shot('sem_time', noTeam);
  }, skip: Platform.environment['FAN_CARD_PREVIEW'] != '1');
}
