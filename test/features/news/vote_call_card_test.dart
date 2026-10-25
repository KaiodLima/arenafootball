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
}
