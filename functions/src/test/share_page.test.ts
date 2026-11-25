import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  athletePageData,
  newsPageData,
  openAppHref,
  parseSharePath,
  renderSharePage,
  schemeHref,
  votePageData,
  matchPageData,
  appPath,
  nowPageData,
  fantasyPageData,
} from '../share_page';

test('caminhos válidos e inválidos', () => {
  assert.deepEqual(parseSharePath('/noticia/abc123'), { kind: 'noticia', id: 'abc123' });
  assert.deepEqual(parseSharePath('/atleta/2026/xyz'), { kind: 'atleta', season: '2026', id: 'xyz' });
  assert.deepEqual(parseSharePath('/destaque/d1?x=1'), { kind: 'destaque', id: 'd1' });
  assert.deepEqual(parseSharePath('/app'), { kind: 'app' });
  assert.equal(parseSharePath('/noticia'), null);
  assert.equal(parseSharePath('/atleta/20x6/xyz'), null);
  assert.equal(parseSharePath('/noticia/a%2Fb'), null);
  assert.equal(parseSharePath('/outra/1'), null);
});

test('botão abre o app no conteúdo e cai na Play Store sem o app', () => {
  const href = openAppHref({ kind: 'noticia', id: 'abc' });
  assert.ok(href.startsWith('intent://noticia/abc#Intent;scheme=arenafootball;package=com.caiolima.arenafootball;'));
  assert.ok(href.includes('S.browser_fallback_url=https%3A%2F%2Fplay.google.com'));
});

test('notícia: Open Graph com título, descrição curta e foto; HTML escapado', () => {
  const data = newsPageData({
    titulo: 'Final <hoje>',
    descricao: 'x'.repeat(300),
    urlImagem: 'https://img/n.png',
    fk_competicao: 'Floresta',
  });
  assert.equal(data.kicker, 'Notícia · Floresta');
  assert.equal(data.description.length, 200);
  const html = renderSharePage(data, { kind: 'noticia', id: 'n1' }, '/noticia/n1');
  assert.ok(html.includes('<meta property="og:title" content="Final &lt;hoje&gt;">'));
  assert.ok(html.includes('<meta property="og:image" content="https://img/n.png">'));
  assert.ok(html.includes('<meta property="og:url" content="https://arenasoccerflutter.web.app/noticia/n1">'));
  assert.ok(!html.includes('<hoje>'));
});

test('atleta: números da temporada; sem foto usa a logo no Open Graph', () => {
  const data = athletePageData({ nome: 'Dudu', time: 'Lava Jato', nGols: 1, nAssistencias: 3 }, '2026');
  assert.equal(data.description, '1 gol e 3 assistências na temporada 2026 · Lava Jato.');
  const html = renderSharePage(data, { kind: 'atleta', season: '2026', id: 'p1' }, '/atleta/2026/p1');
  assert.ok(html.includes('content="https://arenasoccerflutter.web.app/logo.png"'));
});

test('as duas lojas na página e o esquema do app para o iPhone', () => {
  const share = { kind: 'noticia' as const, id: 'n1' };
  const html = renderSharePage(newsPageData({ titulo: 'Final' }), share, '/noticia/n1');
  assert.ok(html.includes('href="https://play.google.com/store/apps/details?id=com.caiolima.arenafootball"'));
  assert.ok(html.includes('href="https://apps.apple.com/us/app/arena-football/id6823678208"'));
  assert.equal(schemeHref(share), 'arenafootball://noticia/n1');
  assert.ok(html.includes('"arenafootball://noticia/n1"'));
  // Capa inteira, sem corte.
  assert.ok(html.includes('object-fit:contain'));
});

test('QR codes: votação, partida, bolão e álbum', () => {
  assert.deepEqual(parseSharePath('/votacao/2026/m1'), { kind: 'votacao', season: '2026', id: 'm1' });
  assert.deepEqual(parseSharePath('/partida/2026/m1'), { kind: 'partida', season: '2026', id: 'm1' });
  assert.deepEqual(parseSharePath('/bolao'), { kind: 'bolao' });
  assert.deepEqual(parseSharePath('/album'), { kind: 'album' });
  assert.equal(parseSharePath('/votacao/26/m1'), null);
  assert.equal(parseSharePath('/votacao/2026'), null);
  assert.equal(parseSharePath('/bolao/x'), null);
  assert.equal(appPath({ kind: 'votacao', season: '2026', id: 'm1' }), 'votacao/2026/m1');
  assert.equal(appPath({ kind: 'bolao' }), 'bolao');
  const match = { timeC: 'Lava Jato', timeF: 'Volta', votacao: 'true', data: '15/11', horario: '15:30' };
  assert.equal(votePageData(match).title, 'Vote no craque: Lava Jato x Volta');
  assert.equal(votePageData(match).kicker, 'Votação aberta');
  assert.equal(votePageData({ ...match, votacao: 'false' }).kicker, 'Votação encerrada');
  assert.equal(matchPageData(match).title, 'Lava Jato x Volta');
  assert.match(matchPageData(match).description, /^15\/11 · 15:30\./);
});

test('QR fixo da região: /agora/<idRegiao>', () => {
  assert.deepEqual(parseSharePath('/agora/fl'), { kind: 'agora', regionId: 'fl' });
  assert.equal(parseSharePath('/agora'), null);
  assert.equal(parseSharePath('/agora/fl/x'), null);
  assert.equal(appPath({ kind: 'agora', regionId: 'fl' }), 'agora/fl');
  assert.equal(nowPageData('Floresta').title, 'Acontecendo agora em Floresta');
  assert.equal(nowPageData('').title, 'Acontecendo agora');
});

test('Arena Fantasy do campeonato: /fantasy/<idDocCampeonato>', () => {
  assert.deepEqual(parseSharePath('/fantasy/c1'), { kind: 'fantasy', id: 'c1' });
  assert.equal(parseSharePath('/fantasy'), null);
  assert.equal(parseSharePath('/fantasy/c1/x'), null);
  assert.equal(appPath({ kind: 'fantasy', id: 'c1' }), 'fantasy/c1');
  const page = fantasyPageData({ titulo: 'Copa Verde', urlImagem: 'https://x/logo.png' });
  assert.equal(page.title, 'Arena Fantasy · Copa Verde');
  assert.equal(page.image, 'https://x/logo.png');
  assert.equal(fantasyPageData({}).title, 'Arena Fantasy');
});
