// Card "Craques da rodada" do Arena Fantasy no feed. A prévia em PNG fica
// fora da suíte normal: grava em build/fantasy_card_previews/ com as fontes de
// verdade. Rodar com:
//   FANTASY_CARD_PREVIEW=1 flutter test test/features/news/fantasy_round_card_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/news/data/dtos/fantasy_news_athlete.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/news_feed_page.dart';
import 'package:arena_soccer/features/news/presentation/widgets/fantasy_round_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}

/// Doc gravado pela function (`fantasyRoundNews`).
final _doc = <String, dynamic>{
  'tag': 'fantasy',
  'exibir': 'true',
  'campeonato': 'Copa Verde 2026',
  'id_campeonato_doc': 'doc1',
  'temporada': '2026',
  'rodada': 3,
  'craques_fantasy': [
    {'idJogador': 'fw', 'nome': 'Ângelo Atacante', 'time': 'Tigres', 'posicao': 'ata', 'pontos': 22, 'colocacao': 1},
    {'idJogador': 'gk', 'nome': 'Rafael Goleiro', 'time': 'Leões', 'posicao': 'gol', 'pontos': 18.5, 'colocacao': 2},
    {'idJogador': 'mf', 'nome': 'Mateus Meia', 'time': 'Tigres', 'posicao': 'mei', 'pontos': 18.5, 'colocacao': 2},
  ],
};

NewsDTO _news({List<FantasyNewsAthlete>? athletes, bool visible = true}) => NewsDTO(
      id: 'fantasy_doc1_r3',
      title: '⭐ Craques da rodada 3 · Copa Verde 2026',
      isVisible: visible,
      tag: NewsDTO.fantasyTag,
      championshipTitle: 'Copa Verde 2026',
      championshipDocId: 'doc1',
      season: '2026',
      fantasyRound: 3,
      fantasyAthletes: athletes ?? FantasyNewsAthlete.listFrom(_doc['craques_fantasy']),
    );

Widget _app(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(body: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(16), child: child))),
    );

void main() {
  test('atletas lidos do doc, cache de ida e volta e a ordem do pódio', () {
    final athletes = FantasyNewsAthlete.listFrom(_doc['craques_fantasy']);
    expect(athletes.map((a) => (a.id, a.rank, a.points)), [('fw', 1, 22.0), ('gk', 2, 18.5), ('mf', 2, 18.5)]);
    final news = _news();
    expect(news.isFantasyRound, isTrue);
    final cached = NewsDTO.fromCache(news.toCache());
    expect(cached.fantasyRound, 3);
    expect(cached.fantasyAthletes, news.fantasyAthletes);
    expect(fantasyPodiumOrder(3), [1, 0, 2]);
    expect(fantasyPodiumOrder(2), [1, 0]);
    expect(fantasyPodiumOrder(1), [0]);
  });

  test('feed: o card do Fantasy só aparece com exibir "true"', () {
    final page = NewsFeedPage.fromRaw([_news(), _news(visible: false).copyWith(id: 'oculto')], limit: 20);
    expect(page.news.map((n) => n.id), ['fantasy_doc1_r3']);
  });

  testWidgets('card: selo da rodada, pódio 2º · 1º · 3º, pontos e os toques', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    String? athlete;
    var opened = false;
    await tester.pumpWidget(_app(FantasyRoundCard(
      news: _news(),
      onTap: () => opened = true,
      onAthleteTap: (a) => athlete = a.id,
    )));
    expect(tester.takeException(), isNull);
    expect(find.text('ARENA FANTASY · RODADA 3'), findsOneWidget);
    expect(find.text('CRAQUES DA RODADA'), findsOneWidget);
    expect(find.text('22 pts'), findsOneWidget);
    expect(find.text('18,5 pts'), findsNWidgets(2));
    expect(find.text('ATA · Tigres'), findsOneWidget);
    // 2º à esquerda, 1º no meio.
    final gk = tester.getCenter(find.byKey(const ValueKey('fantasy-card-athlete-gk'))).dx;
    final fw = tester.getCenter(find.byKey(const ValueKey('fantasy-card-athlete-fw'))).dx;
    final mf = tester.getCenter(find.byKey(const ValueKey('fantasy-card-athlete-mf'))).dx;
    expect(gk < fw && fw < mf, isTrue);
    await tester.tap(find.byKey(const ValueKey('fantasy-card-athlete-fw')));
    expect(athlete, 'fw');
    await tester.tap(find.text('Escalar meu time'));
    expect(opened, isTrue);
  });

  testWidgets('card: "Compartilhar" chama o onShare (sem ele, o botão não aparece)', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var shared = false;
    var opened = false;
    await tester.pumpWidget(_app(FantasyRoundCard(
      news: _news(),
      onTap: () => opened = true,
      onShare: () => shared = true,
    )));
    await tester.tap(find.byKey(const ValueKey('fantasy-card-share-fantasy_doc1_r3')));
    expect(shared, isTrue);
    expect(opened, isFalse, reason: 'compartilhar não abre a escalação');
    await tester.pumpWidget(_app(FantasyRoundCard(news: _news(), onTap: () {})));
    expect(find.text('Compartilhar'), findsNothing);
  });

  testWidgets('prévias do card do Fantasy', (tester) async {
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
    Directory('build/fantasy_card_previews').createSync(recursive: true);
    final all = FantasyNewsAthlete.listFrom(_doc['craques_fantasy']);
    final cases = {
      'tres': _news(),
      'dois': _news(athletes: all.take(2).toList()),
      'nomes_longos': _news(athletes: [
        for (final a in all)
          FantasyNewsAthlete(
            id: a.id,
            name: '${a.name} da Silva Sauro Júnior',
            team: 'Associação Atlética Floresta do Vale',
            position: a.position,
            points: a.points,
            rank: a.rank,
          ),
      ]),
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
                child: FantasyRoundCard(
                  news: entry.value,
                  onTap: () {},
                  trailing: const Icon(Icons.more_vert, color: Colors.white),
                ),
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
      File('build/fantasy_card_previews/${entry.key}.png').writeAsBytesSync(png!);
    }
  }, skip: Platform.environment['FANTASY_CARD_PREVIEW'] != '1');
}
