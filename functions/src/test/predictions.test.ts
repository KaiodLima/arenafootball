import assert from 'node:assert/strict';
import { test } from 'node:test';
import { isOnTime, predictionDeadline, predictionPoints, rankingDelta, scorePrediction } from '../predictions';

const ts = (iso: string) => ({ toDate: () => new Date(iso) });

test('pontos: exato 10, vencedor e saldo 7, empate com outro placar 7, vencedor 5, erro 0', () => {
  assert.deepEqual(predictionPoints({ home: 2, away: 1 }, { home: 2, away: 1 }), { points: 10, exact: true });
  assert.deepEqual(predictionPoints({ home: 2, away: 1 }, { home: 3, away: 2 }), { points: 7, exact: false });
  assert.deepEqual(predictionPoints({ home: 1, away: 1 }, { home: 2, away: 2 }), { points: 7, exact: false });
  assert.deepEqual(predictionPoints({ home: 2, away: 0 }, { home: 3, away: 2 }), { points: 5, exact: false });
  assert.deepEqual(predictionPoints({ home: 0, away: 1 }, { home: 2, away: 1 }), { points: 0, exact: false });
  assert.deepEqual(predictionPoints({ home: 1, away: 1 }, { home: 2, away: 1 }), { points: 0, exact: false });
});

test('prazo: horário marcado (Brasília) ou início manual antes dele', () => {
  const match = { data: '24/10', horario: '21:00' };
  assert.equal(predictionDeadline(match, '2026')?.toISOString(), '2026-10-25T00:00:00.000Z');
  const early = { ...match, inicioEm: ts('2026-10-24T23:30:00Z') };
  assert.equal(predictionDeadline(early, '2026')?.toISOString(), '2026-10-24T23:30:00.000Z');
  assert.equal(predictionDeadline({ data: '' }, '2026'), null);
  const deadline = predictionDeadline(match, '2026');
  assert.equal(isOnTime(ts('2026-10-24T23:59:00Z'), deadline), true);
  assert.equal(isOnTime(ts('2026-10-25T00:01:00Z'), deadline), false);
  assert.equal(isOnTime(undefined, null), true);
});

test('palpite atrasado não vale', () => {
  const match = { data: '24/10', horario: '21:00', golTimeCasa: 2, golTimeFora: 1 };
  const late = { golsCasa: 2, golsFora: 1, atualizadoEm: ts('2026-10-25T00:10:00Z') };
  assert.deepEqual(scorePrediction(late, match, '2026'), { valid: false, points: 0, exact: false });
  const onTime = { ...late, atualizadoEm: ts('2026-10-24T20:00:00Z') };
  assert.deepEqual(scorePrediction(onTime, match, '2026'), { valid: true, points: 10, exact: true });
});

test('ranking soma só a diferença (placar corrigido) e nada quando não muda', () => {
  // Primeira pontuação.
  assert.deepEqual(rankingDelta({}, { valid: true, points: 10, exact: true }), { points: 10, exact: 1, counted: 1 });
  // Placar corrigido: de 10 (exato) para 7.
  assert.deepEqual(rankingDelta({ valido: true, pontos: 10, exato: true }, { valid: true, points: 7, exact: false }), {
    points: -3,
    exact: -1,
    counted: 0,
  });
  // Já pontuado igual.
  assert.equal(rankingDelta({ valido: true, pontos: 7, exato: false }, { valid: true, points: 7, exact: false }), null);
  // Atrasado: conta 0 e não entra em "palpites".
  assert.deepEqual(rankingDelta({}, { valid: false, points: 0, exact: false }), { points: 0, exact: 0, counted: 0 });
});
