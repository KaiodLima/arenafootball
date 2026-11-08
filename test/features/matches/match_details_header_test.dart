import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_goal.dart';
import 'package:arena_soccer/features/matches/presentation/page/match_details_page.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_details/match_details_header.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/constants/app_sizes.dart';

// Prévia em PNG fora do CI: HEADER_PREVIEW=1 flutter test test/features/matches/match_details_header_test.dart
// → build/header_previews/<caso>.png

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}

final _now = DateTime.utc(2026, 11, 15, 23);

const _finished = MatchDTO(
  id: 'm1',
  homeTeam: 'Lava Jato FC',
  awayTeam: 'Volta Redonda',
  homeGoals: 3,
  awayGoals: 1,
  date: '15/11/2026',
  time: '16:00',
  venue: 'Arena Orlandão',
  referee: 'Carlos Souza',
  manualStatus: MatchManualStatus.finished,
  goals: [
    MatchGoal(id: 'a', side: MatchSide.home, scorerId: 'd', scorerName: 'Dudu', minute: 12),
    MatchGoal(id: 'b', side: MatchSide.away, scorerId: 'r', scorerName: 'Rafa', minute: 34),
    MatchGoal(id: 'c', side: MatchSide.home, scorerId: 'd', scorerName: 'Dudu', minute: 78),
    MatchGoal(id: 'e', side: MatchSide.home, scorerId: 'c', scorerName: 'Caio Fernandes', minute: 88),
  ],
);

void main() {
  test('autores: agrupa por nome com os minutos, na ordem do 1º gol', () {
    expect(MatchDetailsHeader.scorerLines(_finished.goals, MatchSide.home), ["DUDU 12', 78'", "CAIO FERNANDES 88'"]);
    expect(MatchDetailsHeader.scorerLines(_finished.goals, MatchSide.away), ["RAFA 34'"]);
    const noMinute = [
      MatchGoal(id: 'a', side: MatchSide.home, scorerId: 'd', scorerName: 'Dudu'),
      MatchGoal(id: 'b', side: MatchSide.home, scorerId: 'd', scorerName: 'Dudu'),
      MatchGoal(id: 'c', side: MatchSide.home),
    ];
    expect(MatchDetailsHeader.scorerLines(noMinute, MatchSide.home), ['DUDU (2)']);
  });

  test('1º tempo só com todos os minutos', () {
    expect(MatchDetailsHeader.halfTimeScore(_finished), (1, 1));
    expect(
      MatchDetailsHeader.halfTimeScore(
        _finished.copyWith(goals: const [MatchGoal(id: 'a', side: MatchSide.home, scorerId: 'd', scorerName: 'Dudu')]),
      ),
      isNull,
    );
  });

  Future<void> pump(WidgetTester tester, MatchDTO match, {Color? home, Color? away, GlobalKey? key}) async {
    tester.view.physicalSize = const Size(392, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: MediaQuery(
        data: const MediaQueryData(size: Size(392, 400), padding: EdgeInsets.only(top: 24)),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: RepaintBoundary(
              key: key,
              child: SizedBox(
                width: 392,
                height: AppSizes.matchHeaderHeight,
                child: MatchDetailsHeader(
                  match: match,
                  homeCrest: null,
                  awayCrest: null,
                  homeColor: MatchDetailsPage.headerColor(home ?? const Color(0xFFD32F2F)),
                  awayColor: MatchDetailsPage.headerColor(away ?? const Color(0xFF1E88E5)),
                  now: _now,
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  testWidgets('encerrada: FIM DE JOGO, placar, autores, 1º tempo e árbitro', (tester) async {
    await pump(tester, _finished);
    expect(find.text('FIM DE JOGO'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text("DUDU 12', 78'"), findsOneWidget);
    expect(find.text('1º TEMPO 1 × 1'), findsOneWidget);
    expect(find.text('Árbitro: Carlos Souza'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('antes do jogo: o horário, sem autores', (tester) async {
    await pump(
      tester,
      _finished.copyWith(
          manualStatus: MatchManualStatus.none, date: '16/11/2026', goals: const [], homeGoals: 0, awayGoals: 0),
    );
    expect(find.text('16:00'), findsOneWidget);
    expect(find.text('FIM DE JOGO'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('prévias do cabeçalho', (tester) async {
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
    Directory('build/header_previews').createSync(recursive: true);
    final cases = <String, (MatchDTO, Color?, Color?)>{
      'encerrada': (_finished, null, null),
      'empate_sem_autores': (
        _finished.copyWith(homeGoals: 1, awayGoals: 1, goals: const [], referee: ''),
        const Color(0xFF111111),
        const Color(0xFFFFFFFF),
      ),
      'antes_do_jogo': (
        _finished.copyWith(
            manualStatus: MatchManualStatus.none, date: '16/11/2026', goals: const [], homeGoals: 0, awayGoals: 0),
        const Color(0xFF6A1B9A),
        const Color(0xFFF57C00),
      ),
    };
    for (final entry in cases.entries) {
      final key = GlobalKey();
      final (match, home, away) = entry.value;
      await pump(tester, match, home: home, away: away, key: key);
      expect(tester.takeException(), isNull, reason: entry.key);
      final png = await tester.runAsync(() async {
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2.5);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      });
      File('build/header_previews/${entry.key}.png').writeAsBytesSync(png!);
    }
  }, skip: Platform.environment['HEADER_PREVIEW'] != '1');
}
