import 'dart:io';
import 'dart:ui' as ui;

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/app_routes.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/firebase/region_registry.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/features/album/presentation/bloc/album_event_cubit.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_region_matches_usecase.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/watch_news_by_tag_usecase.dart';
import 'package:arena_soccer/features/qr_codes/domain/now_feed.dart';
import 'package:arena_soccer/features/qr_codes/domain/qr_target.dart';
import 'package:arena_soccer/features/qr_codes/presentation/bloc/now_cubit.dart';
import 'package:arena_soccer/features/qr_codes/presentation/page/now_page.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

// Prévia em PNG fora do CI: NOW_PREVIEW=1 flutter test test/features/qr_codes/now_page_test.dart
// → build/now_previews/<caso>.png

// 15/11/2026 13:00 em Brasília.
final _now = DateTime.utc(2026, 11, 15, 16);

const _vote = MatchDTO(
  id: 'm1',
  homeTeam: 'Lava Jato',
  awayTeam: 'Volta',
  date: '15/11',
  time: '10:00',
  homeGoals: 2,
  awayGoals: 1,
  isVotingOpen: true,
  manualStatus: MatchManualStatus.finished,
);
const _live = MatchDTO(
  id: 'm3',
  homeTeam: 'Floresta',
  awayTeam: 'Riacho',
  date: '15/11',
  time: '12:30',
  homeGoals: 1,
  manualStatus: MatchManualStatus.live,
);
const _next = MatchDTO(id: 'm2', homeTeam: 'Açaí', awayTeam: 'Gralha', date: '16/11', time: '09:00');

NewsDTO _event(String id, {String region = 'Floresta', bool closed = false}) => NewsDTO(
      id: id,
      tag: NewsDTO.eventTag,
      isVisible: true,
      title: 'Gol mais bonito da rodada',
      region: region,
      event: EventPoll(
        closesAt: _now.add(const Duration(days: 1)),
        closed: closed,
        options: const [EventPollOption(id: 'o1', title: 'A'), EventPollOption(id: 'o2', title: 'B')],
      ),
    );

class _Matches implements GetRegionMatchesUseCase {
  final List<MatchDTO> matches;

  _Matches(this.matches);

  @override
  Future<Either<Failure, List<MatchDTO>>> call({required String region, String? season}) async => Right(matches);
}

class _Events implements WatchNewsByTagUseCase {
  final List<NewsDTO> news;

  _Events(this.news);

  @override
  Stream<Either<Failure, List<NewsDTO>>> call(String tag) => Stream.value(Right(news));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Album extends Cubit<AlbumEventState> implements AlbumEventCubit {
  _Album() : super(const AlbumEventState());

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

void main() {
  setUp(() => RegionRegistry.configure(const [RegionRef(id: 'fl', name: 'Floresta')]));
  tearDown(RegionRegistry.reset);

  test('link fixo da região', () {
    expect(nowLink('fl'), 'https://arenasoccerflutter.web.app/agora/fl');
    expect(parseDeepLink(Uri.parse(nowLink('fl'))), const NowLinkTarget('fl'));
    expect(parseDeepLink(Uri.parse('https://arenasoccerflutter.web.app/agora')), isNull);
    expect(QrTarget.now(regionId: 'fl', title: 'Agora').link, nowLink('fl'));
  });

  test('destaque: votação > ao vivo > evento > próximo jogo > bolão', () {
    NowFeed feed(List<MatchDTO> m, List<NewsDTO> n) => NowFeed.of(matches: m, news: n, region: 'Floresta', now: _now);
    expect(feed([_vote, _live, _next], [_event('e1')]).highlight, NowHighlight.vote);
    expect(feed([_live, _next], [_event('e1')]).highlight, NowHighlight.live);
    expect(feed([_next], [_event('e1')]).highlight, NowHighlight.event);
    expect(feed([_next], const []).highlight, NowHighlight.upcoming);
    expect(feed(const [], const []).highlight, NowHighlight.pool);
    // Eventos só os abertos da região.
    expect(feed(const [], [_event('e2', closed: true), _event('e3', region: 'Riacho')]).events, isEmpty);
  });

  Future<List<String>> pump(
    WidgetTester tester, {
    required List<MatchDTO> matches,
    List<NewsDTO> news = const [],
    Key? boundary,
  }) async {
    tester.view.physicalSize = const Size(400, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final pushed = <String>[];
    await tester.pumpWidget(MultiBlocProvider(
      providers: [
        BlocProvider<AlbumEventCubit>(create: (_) => _Album()),
        BlocProvider<NowCubit>(create: (_) => NowCubit(_Matches(matches), _Events(news), null, () => _now)),
      ],
      child: RepaintBoundary(
        key: boundary,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          onGenerateRoute: (settings) {
            pushed.add(settings.name ?? '');
            return MaterialPageRoute(builder: (_) => const Scaffold());
          },
          home: const NowPage(regionId: 'fl'),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    return pushed;
  }

  testWidgets('votação aberta em destaque; o botão leva a votar', (tester) async {
    final pushed = await pump(tester, matches: const [_vote, _live, _next], news: [_event('e1')]);
    expect(find.byKey(const ValueKey('now-spotlight-vote')), findsOneWidget);
    expect(find.text('AO VIVO'), findsWidgets);
    expect(find.text('PRÓXIMOS JOGOS'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('now-spotlight-action')));
    await tester.pumpAndSettle();
    expect(pushed.last, AppRoutes.voteBestPlayerPage);
    expect(tester.takeException(), isNull);
  });

  testWidgets('nada ativo: o bolão em destaque e o aviso', (tester) async {
    await pump(tester, matches: const []);
    expect(find.byKey(const ValueKey('now-spotlight-pool')), findsOneWidget);
    expect(find.textContaining('Nada acontecendo agora em Floresta'), findsOneWidget);
  });

  testWidgets('região que não existe mais: o aviso', (tester) async {
    RegionRegistry.configure(const []);
    await pump(tester, matches: const [_vote]);
    expect(find.text('Esta região não existe mais no app.'), findsOneWidget);
  });

  testWidgets('prévias', (tester) async {
    await tester.runAsync(() async {
      await _font('Anton', ['lib/assets/fonts/anton/Anton-Regular.ttf']);
      await _font('Roboto', ['lib/assets/fonts/roboto/Roboto-Regular.ttf']);
      await _font('Montserrat', ['lib/assets/fonts/montserrat/Montserrat-VariableFont_wght.ttf']);
      final root = Platform.environment['FLUTTER_ROOT'] ?? '';
      await _font('MaterialIcons', ['$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
    });
    Directory('build/now_previews').createSync(recursive: true);
    final key = GlobalKey();
    await pump(tester, matches: const [_vote, _live, _next], news: [_event('e1')], boundary: key);
    final png = await tester.runAsync(() async {
      final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      return (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    });
    File('build/now_previews/agora.png').writeAsBytesSync(png!);
  }, skip: Platform.environment['NOW_PREVIEW'] != '1');
}
