import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/widgets/result_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

const _news = NewsDTO(
  id: 'resultado_m1',
  title: 'Deu Lava Jato!',
  description: 'Apita o árbitro! Final de jogo.',
  isVisible: true,
  tag: NewsDTO.resultTag,
  homeTeam: 'Lava Jato',
  awayTeam: 'Volta',
  homeGoals: '3',
  awayGoals: '1',
  matchId: 'm1',
  homeColor: '#1B8E2D',
  awayColor: '#111111',
  championshipTitle: 'Copa Verde',
  championshipId: 7,
);

void main() {
  test('card de resultado: tag e campos vão e voltam do cache', () {
    expect(_news.isResult, isTrue);
    expect(NewsDTO.fromCache(_news.toCache()), _news);
    final map = _news.toMap();
    expect(map['id_partida'], 'm1');
    expect(map['campeonato'], 'Copa Verde');
    expect(map['tag'], 'resultado');
  });

  testWidgets('mostra "FIM DE JOGO", placar, competição e o texto', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(body: SingleChildScrollView(child: ResultCard(news: _news, onTap: () {}))),
    ));
    expect(find.text('FIM DE JOGO'), findsOneWidget);
    expect(find.text('3 × 1'), findsOneWidget);
    expect(find.text('Copa Verde'), findsOneWidget);
    expect(find.text('Deu Lava Jato!'), findsOneWidget);
    expect(find.text('Ver partida'), findsOneWidget);
  });

  testWidgets('sem cores dos times: mesmo card padrão', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(
        body: SingleChildScrollView(child: ResultCard(news: _news.copyWith(homeColor: '', awayColor: ''))),
      ),
    ));
    expect(find.text('FIM DE JOGO'), findsOneWidget);
    expect(find.text('3 × 1'), findsOneWidget);
  });
}
