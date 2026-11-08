// Prévia visual do card de votação encerrada do feed (fora da suíte normal): grava
// os PNGs em build/card_previews/ com as fontes de verdade. Rodar com:
//   CARD_PREVIEW=1 flutter test test/features/news/vote_call_card_preview_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/widgets/vote_call_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}

const _base = NewsDTO(
  id: 'votacao_m1',
  title: 'Hora de escolher o melhor jogador',
  description: 'Ajude a escolher o craque.',
  isVisible: true,
  tag: NewsDTO.voteTag,
  homeTeam: 'Açaí No Gralle',
  awayTeam: 'Mulekada',
  matchId: 'm1',
  championshipTitle: 'Copa Açaí de Futsal',
  bestPlayerChecked: true,
  bestPlayerName: 'Ronaldo Lima',
  bestPlayerTeam: 'Açaí No Gralle',
  bestPlayerVotes: 34,
  bestPlayerPercent: 52,
);

void main() {
  final enabled = Platform.environment['CARD_PREVIEW'] == '1';

  testWidgets('prévias do card de votação encerrada', (tester) async {
    await tester.runAsync(() async {
      await _font('Anton', ['lib/assets/fonts/anton/Anton-Regular.ttf']);
      await _font('BarlowCondensed', [
        'lib/assets/fonts/barlow_condensed/BarlowCondensed-SemiBold.ttf',
        'lib/assets/fonts/barlow_condensed/BarlowCondensed-Bold.ttf',
      ]);
      await _font('Roboto', ['lib/assets/fonts/roboto/Roboto-Regular.ttf']);
      await _font('Montserrat', ['lib/assets/fonts/montserrat/Montserrat-VariableFont_wght.ttf']);
      final root = Platform.environment['FLUTTER_ROOT'] ?? '';
      await _font('MaterialIcons', ['$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf']);
    });
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Directory('build/card_previews').createSync(recursive: true);
    final cases = {
      'voto_craque': _base,
      'voto_sem_eleito':
          _base.copyWith(bestPlayerName: '', bestPlayerTeam: '', bestPlayerVotes: 0, bestPlayerPercent: 0),
      'voto_antigo': _base.copyWith(bestPlayerChecked: false, bestPlayerName: ''),
      'voto_nomes_longos': _base.copyWith(
        homeTeam: 'Associação Atlética Floresta do Vale',
        awayTeam: 'Esporte Clube Santo Inácio Unidos',
        bestPlayerName: 'Maximiliano Albuquerque Fernandes',
        bestPlayerTeam: 'Esporte Clube Santo Inácio Unidos',
      ),
    };
    for (final entry in cases.entries) {
      final key = GlobalKey();
      await tester.pumpWidget(MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('pt'),
        home: Scaffold(
          backgroundColor: const Color(0xFFF1F3F1),
          body: Align(
            alignment: Alignment.topCenter,
            child: RepaintBoundary(
              key: key,
              child: Container(
                width: 392,
                color: const Color(0xFFF1F3F1),
                padding: const EdgeInsets.all(16),
                child: VoteCallCard(
                    news: entry.value, onTap: () {}, trailing: const Icon(Icons.more_vert, color: Colors.white)),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: entry.key);
      final png = await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2.5);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      });
      File('build/card_previews/${entry.key}.png').writeAsBytesSync(png!);
    }
  }, skip: !enabled);
}
