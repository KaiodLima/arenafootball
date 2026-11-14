import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/presentation/widgets/match_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';
import 'package:arena_soccer/utils/components/card_menu_button.dart';

// Prévia em PNG fora do CI: COMPACT_PREVIEW=1 flutter test test/features/matches/match_card_compact_test.dart
// → build/compact_previews/cards.png

// Quinta, 13/11/2026, 15h em Brasília.
final _now = DateTime.utc(2026, 11, 13, 18);

const _upcoming = MatchDTO(id: 'a', homeTeam: 'Lava Jato FC', awayTeam: 'Volta Redonda', date: '13/11/2026', time: '19:30');
const _finished = MatchDTO(
  id: 'b',
  homeTeam: 'Associação Atlética Floresta do Vale Unidos',
  awayTeam: 'Mulekada',
  date: '12/11/2026',
  time: '18:00',
  homeGoals: 3,
  awayGoals: 1,
);
const _live = MatchDTO(
  id: 'c',
  homeTeam: 'Açaí No Gralle',
  awayTeam: 'Santo Inácio EC',
  date: '13/11/2026',
  time: '14:30',
  homeGoals: 0,
  awayGoals: 2,
);
const _tomorrow = MatchDTO(id: 'd', homeTeam: 'Riacho FC', awayTeam: 'Volta Redonda', date: '14/11/2026', time: '16:00');

Widget _card(MatchDTO match, {bool admin = false, VoidCallback? onTap, VoidCallback? onPredict}) => MatchCard(
      match: match,
      compact: true,
      isAdmin: admin,
      now: _now,
      onTap: onTap,
      onPredict: onPredict,
      onShareArt: () {},
      onVotingTap: () {},
      onToggleVoting: () {},
      onEditScore: () {},
      onDelete: () {},
      homeColor: const Color(0xFFD32F2F),
      awayColor: const Color(0xFF1E88E5),
    );

Future<void> _pump(WidgetTester tester, List<Widget> cards) async {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      body: ListView(padding: const EdgeInsets.all(12), children: cards),
    ),
  ));
}

void main() {
  testWidgets('antes do jogo: horário e "HOJE", sem placar; atalhos de palpite e divulgar', (tester) async {
    await _pump(tester, [_card(_upcoming, onPredict: () {})]);
    expect(find.text('19:30'), findsOneWidget);
    expect(find.text('HOJE'), findsOneWidget);
    expect(find.text('0'), findsNothing);
    expect(find.byIcon(Icons.scoreboard_outlined), findsOneWidget);
    expect(find.byIcon(Icons.campaign_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('encerrada: "FIM", placar e o vencedor em negrito; nome longo sem estourar', (tester) async {
    await _pump(tester, [_card(_finished)]);
    expect(find.text('FIM'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    final winner = tester.widget<Text>(find.text('Associação Atlética Floresta do Vale Unidos'));
    expect(winner.style?.fontWeight, FontWeight.w800);
    expect(tester.takeException(), isNull);
  });

  testWidgets('admin vê o menu; torcedor não; toque abre os detalhes', (tester) async {
    var taps = 0;
    await _pump(tester, [_card(_finished, admin: true, onTap: () => taps++)]);
    expect(find.byType(CardMenuButton), findsOneWidget);
    await tester.tap(find.text('Mulekada'));
    expect(taps, 1);
    await _pump(tester, [_card(_finished)]);
    expect(find.byType(CardMenuButton), findsNothing);
  });

  testWidgets('prévia PNG', (tester) async {
    await _pump(tester, [
      RepaintBoundary(
        key: const Key('cards'),
        child: Column(children: [
          _card(_upcoming, onPredict: () {}),
          _card(_live, admin: true),
          _card(_finished, admin: true),
          _card(_tomorrow),
        ]),
      ),
    ]);
    await tester.runAsync(() async {
      final loader = FontLoader('Roboto');
      final root = Platform.environment['FLUTTER_ROOT'] ?? '';
      for (final path in ['lib/assets/fonts/roboto/Roboto-Regular.ttf']) {
        if (File(path).existsSync()) loader.addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
      }
      await loader.load();
      final icons = FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(
            File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf').readAsBytesSync())));
      await icons.load();
    });
    await tester.pumpAndSettle();
    final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('cards')));
    final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 2));
    final bytes = await tester.runAsync(() => image!.toByteData(format: ui.ImageByteFormat.png));
    Directory('build/compact_previews').createSync(recursive: true);
    File('build/compact_previews/cards.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  }, skip: Platform.environment['COMPACT_PREVIEW'] != '1');
}
