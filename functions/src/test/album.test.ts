import assert from 'node:assert/strict';
import { test } from 'node:test';
import { albumOf, applyPack, brasiliaDay, drawPack, packId, parsePackId, perPackOf } from '../album';

const stickers = [
  { id: 'a1', teamId: 'tA' },
  { id: 'a2', teamId: 'tA' },
  { id: 'b1', teamId: 'tB' },
];

test('id do pacote do dia (Brasília) e leitura de volta', () => {
  const now = new Date(Date.UTC(2026, 9, 28, 2)); // 23h do dia 27 em Brasília
  assert.equal(brasiliaDay(now), '2026-10-27');
  assert.equal(packId('copa_2026', 'u1', now), 'copa_2026_u1_2026-10-27');
  assert.deepEqual(parsePackId('copa_2026_u1_2026-10-27'), { eventId: 'copa_2026', uid: 'u1', day: '2026-10-27' });
  assert.equal(parsePackId('semdia'), null);
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
