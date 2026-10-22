import assert from 'node:assert/strict';
import { test } from 'node:test';
import { matchEnd, shouldCloseVoting } from '../voting_close';

const match = { data: '22/10', horario: '15:45', duracao: 90, votacao: 'true' };

test('fim da partida: data da temporada + horário (Brasília) + duração', () => {
  // 15:45 em Brasília = 18:45 UTC; + 90 min = 20:15 UTC.
  assert.equal(matchEnd(match, '2026')?.toISOString(), '2026-10-22T20:15:00.000Z');
  assert.equal(matchEnd({ ...match, duracao: undefined }, '2026')?.toISOString(), '2026-10-22T20:15:00.000Z');
  assert.equal(matchEnd({ data: '' }, '2026'), null);
});

test('fecha 24h depois do fim; antes disso, ou já fechada, não', () => {
  assert.equal(shouldCloseVoting(match, '2026', new Date('2026-10-23T20:14:00Z')), false);
  assert.equal(shouldCloseVoting(match, '2026', new Date('2026-10-23T20:15:00Z')), true);
  assert.equal(shouldCloseVoting({ ...match, votacao: 'false' }, '2026', new Date('2026-12-01T00:00:00Z')), false);
});

test('sem horário legível: conta do fim do dia', () => {
  const noTime = { data: '22/10', horario: '', votacao: 'true' };
  assert.equal(shouldCloseVoting(noTime, '2026', new Date('2026-10-24T02:58:00Z')), false);
  assert.equal(shouldCloseVoting(noTime, '2026', new Date('2026-10-24T02:59:00Z')), true);
});
