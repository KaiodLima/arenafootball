import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/news/data/dtos/fantasy_news_athlete.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/art_theme.dart';
import 'package:arena_soccer/features/share_art/domain/fantasy_round_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/page/fantasy_round_art_page.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/fantasy/fantasy_round_art.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

// Prévia em PNG fora do CI: FANTASY_ART_PREVIEW=1 flutter test test/features/share_art/fantasy_round_art_test.dart
// → build/fantasy_art_previews/<modelo>_<formato>[_empate|_1].png

const _theme = ArtTheme(
  brandDark: AppColors.primaryDark,
  brand: AppColors.primary,
  accent: AppColors.gold,
  home: AppColors.primary,
  away: AppColors.primaryDark,
);

const _athletes = [
  FantasyNewsAthlete(id: 'mf', name: 'Mateus Meia', team: 'Tigres', position: 'mei', points: 18.5, rank: 2),
  FantasyNewsAthlete(id: 'fw', name: 'Ângelo Atacante', team: 'Tigres', position: 'ata', points: 22, rank: 1),
  FantasyNewsAthlete(id: 'gk', name: 'Rafael Goleiro', team: 'Leões', position: 'gol', points: 12, rank: 3),
];

NewsDTO _news({List<FantasyNewsAthlete> athletes = _athletes, String docId = 'doc1'}) => NewsDTO(
      id: 'fantasy_doc1_r3',
      tag: NewsDTO.fantasyTag,
      championshipTitle: 'Copa Verde 2026',
      championshipDocId: docId,
      fantasyRound: 3,
      fantasyAthletes: athletes,
    );

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}

Widget _app(Widget child, {Key? boundary}) => MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(body: Center(child: RepaintBoundary(key: boundary, child: child))),
    );

final _cases = {
  '': FantasyRoundArtData.of(_news()),
  '_empate': FantasyRoundArtData.of(_news(athletes: [
    _athletes[1],
    const FantasyNewsAthlete(id: 'a', name: 'Bruno Zagueiro', team: 'Leões', position: 'zag', points: 22, rank: 1),
    _athletes[2],
  ])),
  '_1': FantasyRoundArtData.of(_news(athletes: [_athletes[1]])),
};

void main() {
  test('dados: os 3 pela colocação, rodada, campeonato e o link do Fantasy', () {
    final data = FantasyRoundArtData.of(_news());
    expect(data.athletes.map((a) => a.id), ['fw', 'mf', 'gk']);
    expect(data.round, 3);
    expect(data.championship, 'Copa Verde 2026');
    expect(data.link, 'https://arenasoccerflutter.web.app/fantasy/doc1');
    expect(FantasyRoundArtData.of(_news(docId: '')).link, isEmpty);
    expect(FantasyRoundArtData.pointsText(18.5), '18,5');
    expect(FantasyRoundArtData.pointsText(22), '22');
  });

  testWidgets('texto de compartilhar: rodada, craques com pontos e o link', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(_app(Builder(builder: (context) {
      l10n = AppLocalizations.of(context);
      return const SizedBox();
    })));
    final text = fantasyRoundShareText(l10n, FantasyRoundArtData.of(_news()));
    expect(text, contains('Craques da rodada 3 do Arena Fantasy · Copa Verde 2026'));
    expect(text, contains('1º Ângelo Atacante (22 pts), 2º Mateus Meia (18,5 pts), 3º Rafael Goleiro (12 pts)'));
    expect(text, endsWith('https://arenasoccerflutter.web.app/fantasy/doc1'));
  });

  testWidgets('2 modelos × 4 formatos desenham sem estouro (3, empate e 1 atleta)', (tester) async {
    final failures = <String>[];
    for (final entry in _cases.entries) {
      for (final template in FantasyRoundArtTemplate.values) {
        for (final format in ArtFormat.values) {
          await tester.pumpWidget(_app(FantasyRoundArt(
            data: entry.value,
            template: template,
            format: format,
            colors: ArtPalette.arena.resolve(_theme),
          )));
          final error = tester.takeException();
          if (error != null) failures.add('${template.name} ${format.name}${entry.key}: $error');
        }
      }
    }
    expect(failures, isEmpty);
    // O QR (link do Fantasy) aparece com o QR ligado.
    await tester.pumpWidget(_app(FantasyRoundArt(
      data: _cases['']!,
      template: FantasyRoundArtTemplate.podium,
      format: ArtFormat.feed,
      colors: ArtPalette.arena.resolve(_theme),
    )));
    expect(find.text('ÂNGELO ATACANTE'), findsOneWidget);
    expect(find.text('22 pts'), findsOneWidget);
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
    Directory('build/fantasy_art_previews').createSync(recursive: true);
    for (final entry in _cases.entries) {
      for (final template in FantasyRoundArtTemplate.values) {
        for (final format in ArtFormat.values) {
          if (entry.key.isNotEmpty && format != ArtFormat.feed) continue;
          final key = GlobalKey();
          await tester.pumpWidget(_app(
            FantasyRoundArt(
              data: entry.value,
              template: template,
              format: format,
              colors: (template == FantasyRoundArtTemplate.mvp ? ArtPalette.night : ArtPalette.arena).resolve(_theme),
            ),
            boundary: key,
          ));
          final png = await tester.runAsync(() async {
            final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 2);
            return (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
          });
          File('build/fantasy_art_previews/${template.name}_${format.name}${entry.key}.png').writeAsBytesSync(png!);
        }
      }
    }
  }, skip: Platform.environment['FANTASY_ART_PREVIEW'] != '1');
}
