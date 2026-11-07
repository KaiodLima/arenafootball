import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/news/data/dtos/live_event.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/widgets/live_match_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

const _goal = LiveEvent(
  id: 'g1',
  type: LiveEventType.goal,
  home: true,
  minute: 12,
  player: 'Fulano de Tal com Nome Comprido',
  playerId: 'p1',
  assistant: 'Ciclano',
);
const _yellow = LiveEvent(id: 'c1', type: LiveEventType.yellow, home: false, minute: 20, player: 'Zé', playerId: 'p9');
const _red = LiveEvent(
  id: 'c2',
  type: LiveEventType.red,
  home: false,
  minute: 55,
  player: 'Zé',
  playerId: 'p9',
  secondYellow: true,
);
const _sub = LiveEvent(
  id: 's1',
  type: LiveEventType.substitution,
  home: true,
  minute: 60,
  playerIn: 'Rui',
  playerInId: 'p8',
  playerOut: 'Ana',
);

NewsDTO _card(LiveEvent? last, List<LiveEvent> events) => NewsDTO(
      id: 'aovivo_m1',
      tag: NewsDTO.liveTag,
      isVisible: true,
      homeTeam: 'Associação Atlética dos Leões do Norte',
      awayTeam: 'Tigres',
      homeGoals: '2',
      awayGoals: '1',
      homeColor: '#D32F2F',
      awayColor: '#FFFFFF',
      matchId: 'm1',
      lastEvent: last,
      liveEvents: events,
    );

Future<void> _pump(WidgetTester tester, NewsDTO news, double width) async {
  await tester.pumpWidget(MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: width,
            child: LiveMatchCard(news: news, onTap: () {}, onPlayerTap: (_, __) {}),
          ),
        ),
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  final cases = <String, NewsDTO>{
    'gol com garçom': _card(_goal, const [_goal]),
    'amarelo': _card(_yellow, const [_goal, _yellow]),
    'vermelho de 2º amarelo': _card(_red, const [_goal, _yellow, _red]),
    'substituição': _card(_sub, const [_goal, _yellow, _red, _sub]),
    'sem lances': _card(null, const []),
  };
  for (final width in [320.0, 412.0]) {
    cases.forEach((name, news) {
      testWidgets('card ao vivo ($name) em ${width.toInt()} px sem estourar', (tester) async {
        await _pump(tester, news, width);
        expect(tester.takeException(), isNull);
        expect(find.text('AO VIVO'), findsOneWidget);
        expect(find.text('2 – 1'), findsOneWidget);
      });
    });
  }

  testWidgets('textos do destaque e da mini linha do tempo', (tester) async {
    await _pump(tester, _card(_sub, const [_goal, _yellow, _red, _sub]), 412);
    expect(find.text('SUBSTITUIÇÃO'), findsOneWidget);
    expect(find.text('Rui'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    // Os 3 anteriores na linha do tempo (o vermelho, o amarelo e o gol).
    expect(find.text("55'"), findsOneWidget);
    expect(find.text("20'"), findsOneWidget);
    expect(find.text("12'"), findsOneWidget);
    expect(find.text('Ver partida'), findsOneWidget);
  });
}
