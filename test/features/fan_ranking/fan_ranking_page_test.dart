import 'dart:io';
import 'dart:ui' as ui;

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/features/auth/data/dtos/user_dto.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_cubit.dart';
import 'package:arena_soccer/features/auth/presentation/bloc/session_state.dart';
import 'package:arena_soccer/features/fan_ranking/data/dtos/fan_ranking_dto.dart';
import 'package:arena_soccer/features/fan_ranking/domain/fan_ranking_view.dart';
import 'package:arena_soccer/features/fan_ranking/domain/usecases/get_fan_ranking_cache_first_usecase.dart';
import 'package:arena_soccer/features/fan_ranking/presentation/bloc/fan_ranking_cubit.dart';
import 'package:arena_soccer/features/fan_ranking/presentation/page/fan_ranking_page.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_cubit.dart';
import 'package:arena_soccer/features/regions/presentation/bloc/region_state.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/team_colors.dart';

// Prévia em PNG fora do CI: FAN_RANKING_PREVIEW=1 flutter test test/features/fan_ranking/fan_ranking_page_test.dart
// → build/fan_ranking_previews/<caso>.png

final _ranking = FanRankingDTO(season: '2026', updatedAt: DateTime(2026, 11, 15, 14), entries: [
  FanRankingEntry(
      teamId: '1',
      name: 'Açaí no Gralle',
      regionId: 'fl',
      region: 'Floresta',
      fans: 48,
      primaryColor: TeamColor.purple.hex),
  FanRankingEntry(
      teamId: '9', name: 'Riacho', regionId: 'si', region: 'Santo inacio', fans: 41, primaryColor: TeamColor.blue.hex),
  FanRankingEntry(
      teamId: '2', name: 'Lava Jato', regionId: 'fl', region: 'Floresta', fans: 30, primaryColor: TeamColor.navy.hex),
  FanRankingEntry(
      teamId: '3', name: 'Volta', regionId: 'fl', region: 'Floresta', fans: 22, primaryColor: TeamColor.red.hex),
  FanRankingEntry(
      teamId: '4', name: 'Bairro', regionId: 'fl', region: 'Floresta', fans: 12, primaryColor: TeamColor.orange.hex),
  FanRankingEntry(
      teamId: '5', name: 'Unidos', regionId: 'fl', region: 'Floresta', fans: 6, primaryColor: TeamColor.black.hex),
  FanRankingEntry(teamId: '6', name: 'Estrela', regionId: 'fl', region: 'Floresta', fans: 2),
]);

class _Fake implements GetFanRankingCacheFirstUseCase {
  @override
  Stream<Either<Failure, FanRankingDTO>> call({required String season, bool force = false}) =>
      Stream.value(Right(_ranking));
}

class _Session extends Cubit<SessionState> implements SessionCubit {
  _Session(UserDTO? user) : super(user == null ? const GuestSessionState() : AuthenticatedSessionState(user: user));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Region extends Cubit<RegionState> implements RegionCubit {
  _Region() : super(const RegionState(regions: ['Floresta', 'Santo inacio'], selectedRegion: 'Floresta'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}

const _fan = UserDTO(id: 'u1', name: 'Kaio', email: 'k@x.com', favoriteTeam: 'Volta', favoriteTeamId: '3');

void main() {
  setUp(() => RegionRegistry.configure(const [
        RegionRef(id: 'fl', name: 'Floresta'),
        RegionRef(id: 'si', name: 'Santo inacio'),
      ]));
  tearDown(RegionRegistry.reset);

  group('FanRankingView', () {
    final floresta = _ranking.entriesOf('Floresta');

    test('fatias: os 5 maiores e "Outros", somando 100%', () {
      final slices = FanRankingView.slices(floresta);
      expect(slices.length, 6);
      expect(slices.last.isOthers, isTrue);
      expect(slices.last.fans, 2);
      expect(slices.fold<double>(0, (sum, s) => sum + s.share), closeTo(1, 1e-9));
    });

    test('quem está acima e quantos faltam; líder e empate no topo', () {
      final volta = floresta.firstWhere((e) => e.teamId == '3');
      final next = FanRankingView.gapToNext(floresta, volta)!;
      expect((next.team.name, next.gap), ('Lava Jato', 9));
      expect(FanRankingView.gapToNext(floresta, floresta.first), isNull);
      expect(FanRankingView.leaders(floresta).single.teamId, '1');
      expect(
        FanRankingView.leaders(const [
          FanRankingEntry(teamId: 'a', name: 'A', fans: 5),
          FanRankingEntry(teamId: 'b', name: 'B', fans: 5),
        ]).length,
        2,
      );
      expect(FanRankingView.percent(48, 120), 40);
    });

    test('Geral: todas as regiões, do maior para o menor', () {
      expect(FanRankingView.overall(_ranking).map((e) => e.teamId).take(3), ['1', '9', '2']);
    });
  });

  Future<void> pump(WidgetTester tester, {UserDTO? user = _fan, Key? boundary, double height = 1600}) async {
    tester.view.physicalSize = Size(360, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(KeyedSubtree(
      key: ValueKey(user?.id ?? 'guest'),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>(create: (_) => _Session(user)),
          BlocProvider<RegionCubit>(create: (_) => _Region()),
          BlocProvider<FanRankingCubit>(create: (_) => FanRankingCubit(_Fake())),
        ],
        child: RepaintBoundary(
          key: boundary,
          child: const MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('pt'),
            home: FanRankingPage(),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('líder, sua torcida com quem está acima e convocar a torcida', (tester) async {
    final shared = <String>[];
    final original = fanRankingShare;
    fanRankingShare = (text) async => shared.add(text);
    addTearDown(() => fanRankingShare = original);
    await pump(tester);
    expect(find.text('MAIOR TORCIDA DE FLORESTA'), findsOneWidget);
    expect(find.text('48'), findsOneWidget);
    expect(find.text('Faltam 9 torcedores para passar Lava Jato'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('fan-rally')));
    expect(shared.single, startsWith('Ajude o Volta a subir no ranking de torcidas'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('sem time do coração: a chamada para escolher', (tester) async {
    await pump(tester, user: const UserDTO(id: 'u2', name: 'Ana', email: 'a@x.com'));
    expect(find.text('Entre na disputa!'), findsOneWidget);
    expect(find.byKey(const ValueKey('fan-mine')), findsNothing);
  });

  testWidgets('Geral: times de outras regiões, com a região', (tester) async {
    await pump(tester);
    expect(find.text('Riacho'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('fan-scope-overall')));
    await tester.pumpAndSettle();
    // No 2º lugar e na legenda da divisão.
    expect(find.text('Riacho'), findsWidgets);
    expect(find.text('Santo inacio'), findsOneWidget);
    expect(find.text('MAIOR TORCIDA DO APP'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('prévias', (tester) async {
    await tester.runAsync(() async {
      await _font('Anton', ['lib/assets/fonts/anton/Anton-Regular.ttf']);
      await _font('Roboto', ['lib/assets/fonts/roboto/Roboto-Regular.ttf']);
      await _font('Montserrat', ['lib/assets/fonts/montserrat/Montserrat-VariableFont_wght.ttf']);
      final root = Platform.environment['FLUTTER_ROOT'] ?? '';
      await _font('MaterialIcons', ['$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
    });
    Directory('build/fan_ranking_previews').createSync(recursive: true);
    Future<void> shot(String name, GlobalKey key) async {
      final png = await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        return (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
      });
      File('build/fan_ranking_previews/$name.png').writeAsBytesSync(png!);
    }

    final region = GlobalKey();
    await pump(tester, boundary: region, height: 1700);
    await shot('regiao', region);
    await tester.tap(find.byKey(const ValueKey('fan-scope-overall')));
    await tester.pumpAndSettle();
    await shot('geral', region);
  }, skip: Platform.environment['FAN_RANKING_PREVIEW'] != '1');
}
