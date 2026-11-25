import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  albumOf,
  albumPackMessage,
  applyPack,
  brasiliaDay,
  canOpenPack,
  drawPack,
  nextPackAt,
  packId,
  parsePackId,
  stickerPhotoUpdate,
  perPackOf,
  rankingEntry,
  stickerOf,
  packKind,
  tradeConfig,
  tradeRefusal,
  applyTrade,
  nextTradeDay,
  tradesOn,
} from '../album';

const stickers = [
  { id: 'a1', teamId: 'tA' },
  { id: 'a2', teamId: 'tA' },
  { id: 'b1', teamId: 'tB' },
];

test('id do pacote em sequência e leitura de volta', () => {
  assert.equal(brasiliaDay(new Date(Date.UTC(2026, 9, 28, 2))), '2026-10-27');
  assert.equal(packId('copa_2026', 'u1', 3), 'copa_2026_u1_3');
  assert.deepEqual(parsePackId('copa_2026_u1_3'), { eventId: 'copa_2026', uid: 'u1', n: 3 });
  assert.equal(parsePackId('copa_u1_2026-10-27'), null);
  assert.equal(parsePackId('copa_u1_0'), null);
  assert.equal(parsePackId('semnumero'), null);
});

test('um pacote a cada 24 h, contadas do último pedido (não acumula)', () => {
  const last = new Date(Date.UTC(2026, 9, 28, 17)); // 14h em Brasília
  assert.equal(nextPackAt(last).toISOString(), '2026-10-29T17:00:00.000Z');
  const album = { pacotes: 2, ultimoPacote: last };
  assert.equal(canOpenPack(undefined, 1, last), true);
  assert.equal(canOpenPack(album, 3, new Date(Date.UTC(2026, 9, 29, 16, 59))), false);
  assert.equal(canOpenPack(album, 3, new Date(Date.UTC(2026, 9, 29, 17))), true);
  // Dois dias sem abrir: continua sendo um pacote só (o próximo da sequência).
  assert.equal(canOpenPack(album, 4, new Date(Date.UTC(2026, 9, 31, 17))), false);
  assert.equal(canOpenPack({ pacotes: 2, ultimoPacote: { toDate: () => last } }, 3, nextPackAt(last)), true);
});

test('push do pacotinho: para a conta, abre o álbum', () => {
  const message = albumPackMessage('u1', 'Copa Floresta', 5);
  assert.equal(message.tipo, 'album_pacote');
  assert.deepEqual(message.alvo, { topic: 'usuario_u1' });
  assert.equal(message.aba, 'album');
  assert.match(message.corpo, /5 figurinhas grátis .*Copa Floresta/);
});

test('sorteio: tamanho certo e só figurinhas do evento', () => {
  let i = 0;
  const seq = [0, 0.5, 0.99, 0.2, 0.7];
  const drawn = drawPack(stickers, 5, () => seq[i++]);
  assert.deepEqual(drawn, ['a1', 'a2', 'b1', 'a1', 'b1']);
  assert.deepEqual(drawPack([], 5), []);
  assert.equal(perPackOf(undefined), 5);
  assert.equal(perPackOf({ porPacote: 30 }), 10);
});

test('cola o pacote: novas, repetidas, páginas e álbum completo', () => {
  const first = applyPack(albumOf(undefined), ['a1', 'a1', 'b1'], stickers);
  assert.deepEqual(first.novas, ['a1', 'b1']);
  assert.deepEqual(first.album.figurinhas, { a1: 2, b1: 1 });
  assert.equal(first.album.coladas, 2);
  assert.deepEqual(first.newPages, ['tB']);
  assert.equal(first.justCompleted, false);

  const second = applyPack(first.album, ['a2'], stickers);
  assert.deepEqual(second.newPages, ['tA']);
  assert.equal(second.album.completo, true);
  assert.equal(second.justCompleted, true);
});

test('rara sai bem menos: peso 0,2 contra 1 da comum', () => {
  const pool = [
    { id: 'c1', teamId: 't' },
    { id: 'c2', teamId: 't' },
    { id: 'r1', teamId: 't', rare: true },
  ];
  // Total 2,2: [0, 1) c1, [1, 2) c2, [2, 2,2) r1.
  assert.deepEqual(drawPack(pool, 3, (() => { const s = [0.1, 0.5, 0.95]; let i = 0; return () => s[i++]; })()), ['c1', 'c2', 'r1']);
  let seed = 7;
  const random = () => ((seed = (seed * 16807) % 2147483647) - 1) / 2147483646;
  const many = drawPack(pool, 5000, random);
  const rares = many.filter((id) => id === 'r1').length;
  assert.ok(rares > 300 && rares < 650, `raras: ${rares}`); // ~9% (0,2/2,2)
  // Só raras: chance igual entre elas.
  assert.deepEqual(drawPack([{ id: 'a', teamId: 't', rare: true }], 2), ['a', 'a']);
  assert.equal(stickerOf('x', { idTime: 't', rara: true }).rare, true);
  assert.equal(stickerOf('y', { idTime: 't' }).rare, false);
});

test('ranking: coladas, raras e desempate por quem chegou primeiro', () => {
  const pool = [
    { id: 'a', teamId: 't' },
    { id: 'r', teamId: 't', rare: true },
  ];
  const t1 = new Date(Date.UTC(2026, 9, 1));
  const t2 = new Date(Date.UTC(2026, 9, 2));
  const profile = { nome: 'Ana', urlImagem: '' };
  const first = rankingEntry('u1', undefined, albumOf({ figurinhas: { a: 1 } }), pool, profile, t1);
  assert.equal(first.coladas, 1);
  assert.equal(first.raras, 0);
  assert.equal(first.alcancadoEm, t1);
  // Só repetidas: a contagem não sobe, o desempate não muda.
  const same = rankingEntry('u1', first, albumOf({ figurinhas: { a: 2 } }), pool, profile, t2);
  assert.equal(same.alcancadoEm, t1);
  // Completou com a rara.
  const done = rankingEntry('u1', same, albumOf({ figurinhas: { a: 2, r: 1 }, completo: true, coladas: 2 }), pool, profile, t2);
  assert.equal(done.raras, 1);
  assert.equal(done.alcancadoEm, t2);
});


test('stickerPhotoUpdate: só a figurinha de atleta com a foto antiga ou vazia', () => {
  assert.equal(stickerPhotoUpdate({ tipo: 'atleta', urlImagem: 'old' }, 'old', 'new'), 'new');
  assert.equal(stickerPhotoUpdate({ tipo: 'atleta', urlImagem: '' }, 'old', 'new'), 'new');
  assert.equal(stickerPhotoUpdate({ tipo: 'atleta' }, '', 'new'), 'new');
  assert.equal(stickerPhotoUpdate({ tipo: 'atleta', urlImagem: 'admin' }, 'old', 'new'), null);
  assert.equal(stickerPhotoUpdate({ tipo: 'atleta', urlImagem: 'new' }, 'old', 'new'), null);
  assert.equal(stickerPhotoUpdate({ tipo: 'escudo', urlImagem: 'old' }, 'old', 'new'), null);
  assert.equal(stickerPhotoUpdate({ tipo: 'atleta', urlImagem: 'old' }, 'old', ''), null);
});

test('troca de repetidas: config do evento (desligada sem o campo; limites)', () => {
  assert.deepEqual(tradeConfig(undefined), { size: 0, perDay: 1 });
  assert.deepEqual(tradeConfig({ trocaQtd: 5, trocasPorDia: 2 }), { size: 5, perDay: 2 });
  assert.deepEqual(tradeConfig({ trocaQtd: 1, trocasPorDia: 50 }), { size: 0, perDay: 10 });
  assert.deepEqual(tradeConfig({ trocaQtd: 31 }), { size: 0, perDay: 1 });
});

test('troca de repetidas: tamanho, diferentes, cada uma com 2+, limite do dia em Brasília', () => {
  const catalog = new Set(['a1', 'a2', 'b1']);
  const album = { figurinhas: { a1: 3, a2: 2, b1: 1 }, pacotes: 4 };
  const config = { size: 2, perDay: 1 };
  const now = new Date(Date.UTC(2026, 10, 25, 15));
  assert.equal(tradeRefusal(album, ['a1', 'a2'], config, now, catalog), null);
  assert.equal(tradeRefusal(album, ['a1', 'a2'], { size: 0, perDay: 1 }, now, catalog), 'desligada');
  assert.equal(tradeRefusal(album, ['a1'], config, now, catalog), 'tamanho');
  assert.equal(tradeRefusal(album, 'a1', config, now, catalog), 'tamanho');
  assert.equal(tradeRefusal(album, ['a1', 'a1'], config, now, catalog), 'repetida');
  assert.equal(tradeRefusal(album, ['a1', 'b1'], config, now, catalog), 'sem_repetida');
  assert.equal(tradeRefusal(album, ['a1', 'zz'], config, now, catalog), 'sem_repetida');
  const traded = { ...album, trocasDia: { dia: '2026-11-25', qtd: 1 } };
  assert.equal(tradeRefusal(traded, ['a1', 'a2'], config, now, catalog), 'limite_dia');
  // 01:00 UTC do dia 26 = ainda dia 25 em Brasília; 04:00 UTC = dia 26.
  assert.equal(tradeRefusal(traded, ['a1', 'a2'], config, new Date(Date.UTC(2026, 10, 26, 1)), catalog), 'limite_dia');
  assert.equal(tradeRefusal(traded, ['a1', 'a2'], config, new Date(Date.UTC(2026, 10, 26, 4)), catalog), null);
  assert.equal(tradesOn(traded, '2026-11-26'), 0);
  assert.deepEqual(nextTradeDay(traded, now), { dia: '2026-11-25', qtd: 2 });
  assert.deepEqual(nextTradeDay(traded, new Date(Date.UTC(2026, 10, 27, 12))), { dia: '2026-11-27', qtd: 1 });
});

test('troca: fora do relógio das 24 h, nunca vira diário nem extra; tira 1 de cada e mantém as coladas', () => {
  const album = { pacotes: 2, ultimoPacote: new Date(Date.UTC(2026, 10, 25, 12)) };
  const soon = new Date(Date.UTC(2026, 10, 25, 13));
  assert.equal(packKind(album, 3, soon, { requested: false, extraPacks: 0, trade: true }), 'troca');
  assert.equal(packKind(album, 3, soon, { requested: true, extraPacks: 3, trade: true }), null);
  assert.equal(packKind(album, 2, soon, { requested: false, extraPacks: 0, trade: true }), null);
  assert.equal(packKind(album, 3, soon), null, 'sem a troca, segue esperando as 24 h');
  const before = albumOf({ figurinhas: { a1: 3, a2: 2, b1: 1 } });
  const after = applyTrade(before, ['a1', 'a2']);
  assert.deepEqual(after.figurinhas, { a1: 2, a2: 1, b1: 1 });
  assert.equal(after.coladas, before.coladas);
});
