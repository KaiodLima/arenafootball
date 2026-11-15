import assert from 'node:assert/strict';
import { test } from 'node:test';
import { eventOptionIds, eventPushTitle, tallyDoc } from '../event_poll';
import { newsMessage } from '../messages';

test('ids das opções: pela lista; sem ela, pelas opções; outra tag, nenhum', () => {
  assert.deepEqual(eventOptionIds({ tag: 'evento', idsOpcoes: ['a', 'b'] }), ['a', 'b']);
  assert.deepEqual(eventOptionIds({ tag: 'evento', opcoes: [{ id: 'x' }, { titulo: 'sem id' }, { id: 'y' }] }), ['x', 'y']);
  assert.deepEqual(eventOptionIds({ tag: 'gol', idsOpcoes: ['a'] }), []);
  assert.deepEqual(eventOptionIds(undefined), []);
});

test('apuração: todas as opções, inteiros não negativos e o total', () => {
  assert.deepEqual(tallyDoc({ a: 3, b: 0, c: 2 }), { votos: { a: 3, b: 0, c: 2 }, total: 5 });
  assert.deepEqual(tallyDoc({ a: -1, b: Number.NaN }), { votos: { a: 0, b: 0 }, total: 0 });
});

test('push do evento: "Vote:" no título e abre a notícia', () => {
  const message = newsMessage(
    { tag: 'evento', exibir: 'true', titulo: 'Gol mais bonito da rodada', fk_competicao: 'Floresta', descricao: 'Escolha' },
    'ev1',
  );
  assert.equal(message?.titulo, eventPushTitle('Gol mais bonito da rodada'));
  assert.deepEqual(message?.abrir, { tela: 'noticia', id: 'ev1' });
});
