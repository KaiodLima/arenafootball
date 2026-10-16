import 'package:flutter_test/flutter_test.dart';
import 'package:arena_soccer/core/utils/share_links.dart';

void main() {
  group('links públicos', () {
    test('montam os caminhos do servidor', () {
      expect(newsLink('abc'), 'https://arenasoccerflutter.web.app/noticia/abc');
      expect(athleteLink('2024', 'p1'), 'https://arenasoccerflutter.web.app/atleta/2024/p1');
      expect(highlightLink('h_1'), 'https://arenasoccerflutter.web.app/destaque/h_1');
      expect(appLink, 'https://arenasoccerflutter.web.app/app');
    });
  });

  group('parseDeepLink', () {
    DeepLinkTarget? parse(String link) => parseDeepLink(Uri.parse(link));

    test('https do Hosting', () {
      expect(parse(newsLink('abc')), const NewsLinkTarget('abc'));
      expect(parse(athleteLink('2023', 'p-1')), const AthleteLinkTarget(season: '2023', id: 'p-1'));
      expect(parse(highlightLink('h_1')), const HighlightLinkTarget('h_1'));
      expect(parse(appLink), const AppLinkTarget());
      expect(parse('https://arenasoccerflutter.web.app/noticia/abc/'), const NewsLinkTarget('abc'));
    });

    test('esquema próprio (1º trecho no host)', () {
      expect(parse('arenafootball://noticia/abc'), const NewsLinkTarget('abc'));
      expect(parse('arenafootball://atleta/2024/p1'), const AthleteLinkTarget(season: '2024', id: 'p1'));
      expect(parse('arenafootball://destaque/h1'), const HighlightLinkTarget('h1'));
      expect(parse('arenafootball://app'), const AppLinkTarget());
    });

    test('host ou esquema errado', () {
      expect(parse('https://example.com/noticia/abc'), isNull);
      expect(parse('https://evil.arenasoccerflutter.web.app/noticia/abc'), isNull);
      expect(parse('ftp://arenasoccerflutter.web.app/noticia/abc'), isNull);
      expect(parse('otherapp://noticia/abc'), isNull);
    });

    test('id inválido', () {
      expect(parse('https://arenasoccerflutter.web.app/noticia/a.b'), isNull);
      expect(parse('arenafootball://destaque/a%20b'), isNull);
      expect(parse('https://arenasoccerflutter.web.app/noticia/${'a' * 129}'), isNull);
      expect(parse('https://arenasoccerflutter.web.app/noticia'), isNull);
      expect(parse('https://arenasoccerflutter.web.app/noticia/a/b'), isNull);
    });

    test('temporada inválida', () {
      expect(parse('https://arenasoccerflutter.web.app/atleta/24/p1'), isNull);
      expect(parse('arenafootball://atleta/abcd/p1'), isNull);
      expect(parse('https://arenasoccerflutter.web.app/atleta/p1'), isNull);
    });

    test('caminho desconhecido', () {
      expect(parse('https://arenasoccerflutter.web.app/'), isNull);
      expect(parse('https://arenasoccerflutter.web.app/time/abc'), isNull);
      expect(parse('arenafootball://app/extra'), isNull);
    });
  });
}
