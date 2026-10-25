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

import { expectedEnd, shouldAutoFinish } from '../voting_close';

const ts = (iso: string) => ({ toDate: () => new Date(iso) });
// Real Luiz × Capão FC: 21:00 (Brasília), 40 min, iniciada na mão às 20:28.
const forgotten = { data: '24/10', horario: '21:00', duracao: 40, status: 'andamento', inicioEm: ts('2026-10-24T23:28:00Z') };

test('iniciada na mão e esquecida: encerra 30 min depois do fim esperado', () => {
  // Fim esperado 20:28 + 40 = 21:08 (00:08 UTC); encerra a partir de 21:38.
  assert.equal(expectedEnd(forgotten, '2026')?.toISOString(), '2026-10-25T00:08:00.000Z');
  assert.equal(shouldAutoFinish(forgotten, '2026', new Date('2026-10-25T00:20:00Z')), false);
  assert.equal(shouldAutoFinish(forgotten, '2026', new Date('2026-10-25T00:49:00Z')), true);
  assert.equal(shouldAutoFinish({ ...forgotten, status: 'encerrada' }, '2026', new Date('2026-10-26T00:00:00Z')), false);
});

test('fim esperado: 2º tempo marcado e intervalo esquecido', () => {
  const second = { ...forgotten, segundoTempoEm: ts('2026-10-24T23:55:00Z') };
  assert.equal(expectedEnd(second, '2026')?.toISOString(), '2026-10-25T00:15:00.000Z');
  const halfTime = { ...forgotten, status: 'intervalo', intervaloEm: ts('2026-10-24T23:50:00Z') };
  // 23:50 + 15 de pausa + 20 do 2º tempo = 00:25 UTC.
  assert.equal(expectedEnd(halfTime, '2026')?.toISOString(), '2026-10-25T00:25:00.000Z');
  assert.equal(shouldAutoFinish(halfTime, '2026', new Date('2026-10-25T00:56:00Z')), true);
});
