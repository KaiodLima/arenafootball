import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/firebase/test_content.dart';
import 'package:arena_soccer/features/matches/data/dtos/match_dto.dart';
import 'package:arena_soccer/features/matches/domain/live_match_card.dart';
import 'package:arena_soccer/features/news/data/dtos/news_dto.dart';
import 'package:arena_soccer/features/news/domain/news_feed_page.dart';

/// Partida de teste do admin: só a conta admin vê a partida e os cards dela.
void main() {
  tearDown(() => TestContent.configure(visible: false));

  test('TestContent: comum não vê o de teste; admin vê tudo', () {
    TestContent.configure(visible: false);
    expect(TestContent.allows(false), isTrue);
    expect(TestContent.allows(true), isFalse);
    TestContent.configure(visible: true);
    expect(TestContent.allows(true), isTrue);
  });

  test('partida: grava "teste" só quando é de teste', () {
    const match = MatchDTO(id: 'm1', homeTeam: 'A', awayTeam: 'B', isTest: true);
    expect(match.toMap()['teste'], isTrue);
    expect(const MatchDTO(homeTeam: 'A', awayTeam: 'B').toMap().containsKey('teste'), isFalse);
    expect(match.copyWith(venue: 'Campo').isTest, isTrue);
  });

  test('card ao vivo e o vermelho oculto copiam o teste da partida', () {
    const match = MatchDTO(id: 'm1', homeTeam: 'A', awayTeam: 'B', isTest: true);
    final card = LiveMatchCard.build(match, const {});
    expect(card.isTest, isTrue);
    expect(card.toMap()['teste'], isTrue);
    expect(NewsDTO.fromCache(card.toCache()).isTest, isTrue);
  });

  test('feed: o card de teste só aparece para o admin', () {
    const normal = NewsDTO(id: 'n1', title: 'Notícia', isVisible: true);
    const test = NewsDTO(id: 'aovivo_m1', tag: NewsDTO.liveTag, isVisible: true, isTest: true);
    TestContent.configure(visible: false);
    expect(NewsFeedPage.fromRaw(const [normal, test], limit: 20).news.map((n) => n.id), ['n1']);
    TestContent.configure(visible: true);
    expect(NewsFeedPage.fromRaw(const [normal, test], limit: 20).news.map((n) => n.id), ['n1', 'aovivo_m1']);
  });
}
