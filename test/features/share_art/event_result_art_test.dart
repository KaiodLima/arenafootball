import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/event_polls/domain/event_poll.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/share_art/domain/art_format.dart';
import 'package:arena_soccer/features/share_art/domain/art_palette.dart';
import 'package:arena_soccer/features/share_art/domain/art_theme.dart';
import 'package:arena_soccer/features/share_art/domain/event_result_art_data.dart';
import 'package:arena_soccer/features/share_art/presentation/page/event_result_art_page.dart';
import 'package:arena_soccer/features/share_art/presentation/templates/event/event_result_art.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_colors.dart';

// Prévia em PNG fora do CI: EVENT_ART_PREVIEW=1 flutter test test/features/share_art/event_result_art_test.dart
// → build/event_art_previews/<modelo>_<formato>[_empate|_8].png

const _theme = ArtTheme(
  brandDark: AppColors.primaryDark,
  brand: AppColors.primary,
  accent: AppColors.gold,
  home: AppColors.primary,
  away: AppColors.primaryDark,
);

NewsDTO _event(int options) => NewsDTO(
      id: 'ev1',
      tag: NewsDTO.eventTag,
      title: 'Gol mais bonito da rodada',
      event: EventPoll(
        closed: true,
        closesAt: DateTime(2026, 11, 17, 23, 59),
        options: [
          for (var i = 1; i <= options; i++)
            EventPollOption(
                id: 'o$i',
                title: const ['Gol do Dudu', 'Gol do Rafa', 'Gol do Kaio', 'Golaço do Léo'][(i - 1) % 4] +
                    (i > 4 ? ' $i' : ''),
                subtitle: 'Lava Jato x Volta'),
        ],
      ),
    );

EventResultArtData _data({int options = 3, bool tie = false}) {
  final votes = <String, int>{};
  for (var i = 1; i <= options; i++) {
    votes['o$i'] = tie && i <= 2 ? 5 : (options - i + 1) * 2 + (i == 1 ? 3 : 0);
  }
  return EventResultArtData.of(_event(options), EventTally(votes));
}

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

void main() {
  test('dados: ordem por votos, percentual, posições com empate e vencedoras', () {
    final data = EventResultArtData.of(_event(4), const EventTally({'o1': 2, 'o2': 5, 'o3': 5, 'o4': 0}));
    expect(data.entries.map((e) => e.option.id), ['o2', 'o3', 'o1', 'o4']);
    expect(data.entries.map((e) => e.position), [1, 1, 3, 4]);
    expect(data.entries.first.percent, 42);
    expect(data.winners.map((e) => e.option.id), ['o2', 'o3']);
    expect(data.tie, isTrue);
    expect(data.total, 12);
    expect(data.link, endsWith('/noticia/ev1'));
    // O número da opção (quadro sem foto) segue o do evento.
    expect(data.entries.first.number, 2);
  });

  testWidgets('texto de compartilhar: vencedor com % ou o empate', (tester) async {
    late AppLocalizations l10n;
    await tester.pumpWidget(_app(Builder(builder: (context) {
      l10n = AppLocalizations.of(context);
      return const SizedBox();
    })));
    expect(eventResultShareText(l10n, _data()),
        startsWith('🏆 Resultado: Gol mais bonito da rodada — Gol do Dudu venceu com'));
    expect(eventResultShareText(l10n, _data(tie: true)), contains('empate entre Gol do Dudu, Gol do Rafa'));
  });

  testWidgets('3 modelos × 4 formatos desenham sem estouro (3 e 8 opções, empate)', (tester) async {
    final failures = <String>[];
    for (final data in [_data(), _data(options: 8), _data(tie: true)]) {
      for (final template in EventResultArtTemplate.values) {
        for (final format in ArtFormat.values) {
          await tester.pumpWidget(_app(EventResultArt(
            data: data,
            template: template,
            format: format,
            colors: ArtPalette.arena.resolve(_theme),
          )));
          final error = tester.takeException();
          if (error != null) failures.add('${template.name} ${format.name} ${data.entries.length}${data.tie ? ' empate' : ''}: $error');
        }
      }
    }
    expect(failures, isEmpty);
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
    Directory('build/event_art_previews').createSync(recursive: true);
    final cases = {
      '': _data(),
      '_empate': _data(tie: true),
      '_8': _data(options: 8),
    };
    for (final entry in cases.entries) {
      for (final template in EventResultArtTemplate.values) {
        for (final format in ArtFormat.values) {
          if (entry.key.isNotEmpty && format != ArtFormat.feed && format != ArtFormat.landscape) continue;
          final key = GlobalKey();
          await tester.pumpWidget(_app(
            EventResultArt(
              data: entry.value,
              template: template,
              format: format,
              colors: (template == EventResultArtTemplate.podium ? ArtPalette.night : ArtPalette.arena).resolve(_theme),
            ),
            boundary: key,
          ));
          final png = await tester.runAsync(() async {
            final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 2);
            return (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
          });
          File('build/event_art_previews/${template.name}_${format.name}${entry.key}.png').writeAsBytesSync(png!);
        }
      }
    }
  }, skip: Platform.environment['EVENT_ART_PREVIEW'] != '1');
}
