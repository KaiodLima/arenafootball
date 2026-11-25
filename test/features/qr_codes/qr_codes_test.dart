import 'dart:io';
import 'dart:ui' as ui;

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/errors/failure.dart';
import 'package:arena_soccer/core/utils/share_links.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/usecases/get_region_matches_cache_first_usecase.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/usecases/open_events_cache_usecases.dart';
import 'package:arena_soccer/features/qr_codes/domain/qr_target.dart';
import 'package:arena_soccer/features/qr_codes/presentation/bloc/qr_codes_cubit.dart';
import 'package:arena_soccer/features/qr_codes/presentation/page/qr_poster_page.dart';
import 'package:arena_soccer/features/qr_codes/presentation/widgets/qr_poster.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/widgets/art_widgets.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

// Prévia em PNG fora do CI: QR_PREVIEW=1 flutter test test/features/qr_codes/qr_codes_test.dart
// → build/qr_previews/<caso>.png

// 15/11/2026 13:00 em Brasília.
final _now = DateTime.utc(2026, 11, 15, 16);

const _voting = MatchDTO(
  id: 'm1',
  homeTeam: 'Lava Jato',
  awayTeam: 'Volta',
  date: '15/11',
  time: '10:00',
  region: 'Floresta',
  isVotingOpen: true,
  manualStatus: MatchManualStatus.finished,
);
const _upcoming =
    MatchDTO(id: 'm2', homeTeam: 'Açaí', awayTeam: 'Gralha', date: '16/11', time: '09:00', region: 'Floresta');

class _Matches implements GetRegionMatchesCacheFirstUseCase {
  @override
  Stream<Either<Failure, List<MatchDTO>>> call({required String region, String? season, bool force = false}) =>
      Stream.value(const Right([_voting, _upcoming]));

  @override
  Future<Either<Failure, List<MatchDTO>>> latest({required String region, String? season, bool force = false}) =>
      call(region: region, season: season).last;
}

class _Events implements GetOpenEventsCacheFirstUseCase {
  @override
  Future<Either<Failure, List<NewsDTO>>> latest({bool force = false}) => call(force: force).last;

  @override
  Stream<Either<Failure, List<NewsDTO>>> call({bool force = false}) => Stream.value(Right([
        NewsDTO(
          id: 'ev1',
          tag: NewsDTO.eventTag,
          isVisible: true,
          title: 'Gol mais bonito',
          region: 'Floresta',
          event: EventPoll(closesAt: _now.add(const Duration(days: 1))),
        ),
        NewsDTO(
          id: 'ev2',
          tag: NewsDTO.eventTag,
          isVisible: true,
          title: 'Encerrado',
          region: 'Floresta',
          event: const EventPoll(closed: true),
        ),
        NewsDTO(
          id: 'ev3',
          tag: NewsDTO.eventTag,
          isVisible: true,
          title: 'Outra região',
          region: 'Riacho',
          event: EventPoll(closesAt: _now.add(const Duration(days: 1))),
        ),
      ]));

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
  group('links', () {
    test('montadores e leitura dos caminhos novos', () {
      expect(voteLink('2026', 'm1'), 'https://arenasoccerflutter.web.app/votacao/2026/m1');
      expect(parseDeepLink(Uri.parse(voteLink('2026', 'm1'))), const VoteLinkTarget(season: '2026', matchId: 'm1'));
      expect(parseDeepLink(Uri.parse(matchLink('2026', 'm2'))), const MatchLinkTarget(season: '2026', matchId: 'm2'));
      expect(parseDeepLink(Uri.parse(poolLink)), const PoolLinkTarget());
      expect(parseDeepLink(Uri.parse(albumLink)), const AlbumLinkTarget());
      expect(parseDeepLink(Uri.parse('arenafootball://votacao/2026/m1')),
          const VoteLinkTarget(season: '2026', matchId: 'm1'));
      expect(parseDeepLink(Uri.parse('https://arenasoccerflutter.web.app/votacao/26/m1')), isNull);
      expect(parseDeepLink(Uri.parse('https://arenasoccerflutter.web.app/bolao/x')), isNull);
      expect(parseDeepLink(Uri.parse('https://outro.site/bolao')), isNull);
    });

    test('QR da partida: votação aberta → votação; senão, a partida', () {
      expect(QrTarget.forMatch(_voting, season: '2026').kind, QrKind.vote);
      expect(QrTarget.forMatch(_voting, season: '2026').link, voteLink('2026', 'm1'));
      expect(QrTarget.forMatch(_upcoming, season: '2026').link, matchLink('2026', 'm2'));
      expect(QrTarget.forMatch(_voting, season: '2026', voting: false).kind, QrKind.match);
      expect(QrTarget.pool(title: 'Bolão').shortLink, 'arenasoccerflutter.web.app/bolao');
    });
  });

  test('central: só o que está ativo na região', () async {
    final cubit = QrCodesCubit(_Matches(), _Events(), null, () => _now);
    await cubit.load(region: 'Floresta', season: '2026');
    expect(cubit.state.events.map((t) => t.title), ['Gol mais bonito']);
    expect(cubit.state.events.single.link, newsLink('ev1'));
    expect(cubit.state.votes.single.link, voteLink('2026', 'm1'));
    expect(cubit.state.matches.single.link, matchLink('2026', 'm2'));
    await cubit.close();
  });

  Widget app(Widget home) => MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: home,
      );

  testWidgets('cartaz: o QR codifica o link e "Copiar link" copia', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied.add((call.arguments as Map)['text'] as String);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
    final target = QrTarget.forMatch(_voting, season: '2026');
    await tester.pumpWidget(app(QrPosterPage(target: target)));
    await tester.pumpAndSettle();
    final qr = tester.widget<ArtQrCode>(find.byKey(const ValueKey('qr-poster-code')));
    expect(qr.data, voteLink('2026', 'm1'));
    expect(find.text('VOTE NO CRAQUE'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('qr-copy')));
    await tester.pumpAndSettle();
    expect(copied.single, voteLink('2026', 'm1'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('cartaz cabe nos 4 formatos (partida e bolão)', (tester) async {
    final targets = [
      QrTarget.forMatch(_voting, season: '2026'),
      QrTarget.pool(title: 'Bolão do Arena Football', subtitle: 'Palpite nos jogos e dispute o ranking da sua região'),
    ];
    for (final target in targets) {
      for (final format in ArtFormat.values) {
        await tester.pumpWidget(app(Scaffold(
          body: Center(
            child: QrPoster(target: target, format: format, colors: ArtPalette.arena.resolve(qrArtTheme)),
          ),
        )));
        expect(tester.takeException(), isNull, reason: '${target.kind.name} ${format.name}');
      }
    }
  });

  testWidgets('prévias', (tester) async {
    await tester.runAsync(() async {
      await _font('Anton', ['lib/assets/fonts/anton/Anton-Regular.ttf']);
      await _font('BarlowCondensed', [
        'lib/assets/fonts/barlow_condensed/BarlowCondensed-SemiBold.ttf',
        'lib/assets/fonts/barlow_condensed/BarlowCondensed-Bold.ttf',
      ]);
      final root = Platform.environment['FLUTTER_ROOT'] ?? '';
      await _font('MaterialIcons', ['$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
    });
    Directory('build/qr_previews').createSync(recursive: true);
    final cases = {
      'votacao': QrTarget.forMatch(
        _voting,
        season: '2026',
        home: const ArtTeam(name: 'Lava Jato', primaryColor: '#1A237E'),
        away: const ArtTeam(name: 'Volta', primaryColor: '#E53935'),
      ),
      'bolao': QrTarget.pool(title: 'Bolão do Arena Football', subtitle: 'Palpite nos jogos e dispute o ranking'),
      'evento': QrTarget(kind: QrKind.event, title: 'Gol mais bonito da rodada', link: newsLink('ev1')),
    };
    for (final entry in cases.entries) {
      for (final format in [ArtFormat.story, ArtFormat.square, ArtFormat.landscape]) {
        final key = GlobalKey();
        await tester.pumpWidget(app(Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: key,
              child: QrPoster(target: entry.value, format: format, colors: ArtPalette.night.resolve(qrArtTheme)),
            ),
          ),
        )));
        final png = await tester.runAsync(() async {
          final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2);
          return (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
        });
        File('build/qr_previews/${entry.key}_${format.name}.png').writeAsBytesSync(png!);
      }
    }
  }, skip: Platform.environment['QR_PREVIEW'] != '1');
}
