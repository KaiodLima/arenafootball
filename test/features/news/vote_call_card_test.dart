import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/presentation/widgets/vote_call_card.dart';
import 'package:arena_soccer/l10n/app_localizations.dart';

const _news = NewsDTO(
  id: 'votacao_m1',
  title: 'Quem foi o craque de Lava Jato × Volta?',
  description: 'Vote no craque do jogo!',
  isVisible: true,
  tag: NewsDTO.voteTag,
  homeTeam: 'Lava Jato',
  awayTeam: 'Volta',
  matchId: 'm1',
  votingOpen: true,
);

Future<void> _pump(WidgetTester tester, NewsDTO news) => tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(body: SingleChildScrollView(child: VoteCallCard(news: news, onTap: () {}))),
    ));

void main() {
  test('card de votação: tag e "votacao" vão e voltam', () {
    expect(_news.isVoteCall, isTrue);
    expect(NewsDTO.fromCache(_news.toCache()), _news);
    expect(_news.toMap()['votacao'], 'true');
    expect(_news.copyWith(votingOpen: false).toMap()['votacao'], 'false');
  });

  testWidgets('aberta: "VOTE NO CRAQUE" e "Votar agora"', (tester) async {
    await _pump(tester, _news);
    expect(find.text('VOTE NO CRAQUE'), findsOneWidget);
    expect(find.text('Votar agora'), findsOneWidget);
  });

  testWidgets('encerrada: "VOTAÇÃO ENCERRADA" e "Ver resultado"', (tester) async {
    await _pump(tester, _news.copyWith(votingOpen: false));
    expect(find.text('VOTAÇÃO ENCERRADA'), findsOneWidget);
    expect(find.text('Ver resultado'), findsOneWidget);
  });

  test('apuração do craque vai e volta do cache e do mapa', () {
    final closed = _news.copyWith(
      votingOpen: false,
      bestPlayerChecked: true,
      bestPlayerName: 'Dudu',
      bestPlayerTeam: 'Volta',
      bestPlayerVotes: 12,
      bestPlayerPercent: 48,
    );
    expect(NewsDTO.fromCache(closed.toCache()), closed);
    final map = closed.toMap();
    expect(map['craque_apurado'], true);
    expect(map['craque_nome'], 'Dudu');
    expect(map['craque_votos'], 12);
    expect(_news.toMap().containsKey('craque_apurado'), isFalse);
  });

  testWidgets('encerrada com craque: nome, time, votos e %', (tester) async {
    await _pump(
      tester,
      _news.copyWith(
        votingOpen: false,
        bestPlayerChecked: true,
        bestPlayerName: 'Dudu',
        bestPlayerTeam: 'Volta',
        bestPlayerVotes: 12,
        bestPlayerPercent: 48,
      ),
    );
    expect(find.text('CRAQUE DA PARTIDA'), findsOneWidget);
    expect(find.text('DUDU'), findsOneWidget);
    expect(find.text('VOLTA'), findsOneWidget);
    expect(find.text('12 votos · 48%'), findsOneWidget);
    expect(find.text('Quem foi o craque de Lava Jato × Volta?'), findsNothing, reason: 'sem o título de chamada');
  });

  testWidgets('encerrada sem eleito e card antigo', (tester) async {
    await _pump(tester, _news.copyWith(votingOpen: false, bestPlayerChecked: true));
    expect(find.text('SEM CRAQUE ELEITO'), findsOneWidget);
    await _pump(tester, _news.copyWith(votingOpen: false));
    expect(find.text('RESULTADO DISPONÍVEL'), findsOneWidget);
    expect(find.text('Confira quem foi eleito o craque de Lava Jato × Volta.'), findsOneWidget);
  });
}
