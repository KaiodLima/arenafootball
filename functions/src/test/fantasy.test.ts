import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  currentRound,
  fantasyRounds,
  frozenParams,
  lineupCopy,
  matchdayOf,
  nextOpenRound,
  previousClosedRound,
  roundFieldsChanged,
  roundSync,
} from '../fantasy';

const match = (id: string, rodada: unknown, data: string, horario: string) => ({ id, data: { rodada, data, horario } });

test('rodada da partida: inteiro de 1 a 99', () => {
  assert.equal(matchdayOf(3), 3);
  assert.equal(matchdayOf('4'), 4);
  assert.equal(matchdayOf(0), null);
  assert.equal(matchdayOf(undefined), null);
  assert.equal(matchdayOf(100), null);
});

test('rodadas pelas partidas: prazo = 1º jogo (Brasília), sem rodada fica de fora', () => {
  const rounds = fantasyRounds(
    [
      match('b', 1, '15/11/2026', '18:00'),
      match('a', 1, '14/11/2026', '16:00'),
      match('c', 2, '21/11/2026', '15:00'),
      match('d', undefined, '22/11/2026', '15:00'),
    ],
    '2026',
  );
  assert.deepEqual(rounds.map((r) => [r.numero, r.idsPartidas]), [[1, ['a', 'b']], [2, ['c']]]);
  // 14/11 16:00 em Brasília = 19:00 UTC.
  assert.equal(rounds[0].fechaEm?.toISOString(), '2026-11-14T19:00:00.000Z');
});

test('rodada atual: a menor aberta com prazo no futuro', () => {
  const now = new Date('2026-11-15T12:00:00Z');
  const rounds = [
    { numero: 1, fechaEm: new Date('2026-11-14T19:00:00Z'), status: 'aberta' },
    { numero: 2, fechaEm: new Date('2026-11-21T18:00:00Z'), status: 'aberta' },
    { numero: 3, fechaEm: new Date('2026-11-28T18:00:00Z'), status: 'aberta' },
  ];
  assert.equal(currentRound(rounds, now), 2);
  assert.equal(currentRound([{ ...rounds[1], status: 'fechada' }, rounds[2]], now), 3);
  assert.equal(currentRound([rounds[0]], now), 0);
});

test('sincronia: nova abre; aberta acompanha o prazo; fechada só as partidas', () => {
  const computed = { numero: 2, idsPartidas: ['c', 'e'], fechaEm: new Date('2026-11-21T18:00:00Z') };
  assert.deepEqual(roundSync(undefined, computed), {
    numero: 2,
    idsPartidas: ['c', 'e'],
    fechaEm: computed.fechaEm,
    status: 'aberta',
  });
  assert.equal(roundSync({ status: 'aberta', fechaEm: computed.fechaEm, idsPartidas: ['c', 'e'] }, computed), null);
  const moved = roundSync({ status: 'aberta', fechaEm: new Date('2026-11-22T18:00:00Z'), idsPartidas: ['c', 'e'] }, computed);
  assert.equal((moved?.fechaEm as Date).toISOString(), '2026-11-21T18:00:00.000Z');
  // Fechada: o prazo não muda (D1), só a lista de partidas.
  assert.deepEqual(roundSync({ status: 'fechada', fechaEm: new Date('2026-11-20T18:00:00Z'), idsPartidas: ['c'] }, computed), {
    idsPartidas: ['c', 'e'],
  });
  assert.equal(roundSync(undefined, { ...computed, fechaEm: null }), null);
});

test('campos que mexem nas rodadas', () => {
  assert.equal(roundFieldsChanged({ rodada: 1, data: 'x' }, { rodada: 2, data: 'x' }), true);
  assert.equal(roundFieldsChanged({ rodada: 1, golTimeCasa: 0 }, { rodada: 1, golTimeCasa: 1 }), false);
  assert.equal(roundFieldsChanged({ horario: '18:00' }, { horario: '19:00' }), true);
});

test('parâmetros congelados (padrões quando faltam)', () => {
  assert.deepEqual(frozenParams({ minMinutos: 30, capitao: 2 }), { minMinutos: 30, minMinutosDefesa: 45, capitao: 2 });
});

test('cópia da escalação: mesmos atletas e capitão, marcada copiada; sem os 5, nula', () => {
  const lineup = {
    uid: 'u1',
    nome: 'Ana',
    urlImagem: '',
    atletas: { gol: 'p1', zag: 'p2', mei: 'p3', ata: 'p4', livre: 'p5' },
    idsAtletas: ['p1', 'p2', 'p3', 'p4', 'p5'],
    capitao: 'p4',
    pontos: 30,
    copiada: false,
  };
  const copy = lineupCopy(lineup);
  assert.equal(copy?.copiada, true);
  assert.equal(copy?.capitao, 'p4');
  assert.equal('pontos' in (copy ?? {}), false);
  assert.equal(lineupCopy({ ...lineup, idsAtletas: ['p1'] }), null);
  assert.equal(lineupCopy({ ...lineup, capitao: 'p9' }), null);
});

test('próxima aberta e última fechada', () => {
  const rounds = [
    { numero: 1, status: 'fechada' },
    { numero: 2, status: 'fechada' },
    { numero: 3, status: 'aberta' },
    { numero: 5, status: 'aberta' },
  ];
  assert.equal(nextOpenRound(rounds, 2), 3);
  assert.equal(nextOpenRound(rounds, 5), null);
  assert.equal(previousClosedRound(rounds, 5), 2);
  assert.equal(previousClosedRound(rounds, 1), null);
});
