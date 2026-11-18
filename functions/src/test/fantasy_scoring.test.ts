import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  roundParticipants,
  type AthleteScore,
  lineupPoints,
  parseMatch,
  participation,
  pointsDelta,
  positionOf,
  scoreAthlete,
  scoringFieldsChanged,
} from '../fantasy_scoring';

const params = { minMinutos: 20, minMinutosDefesa: 45, capitao: 1.5 };

type Doc = Record<string, unknown>;

/** Partida de 90 min: casa (A) x fora (B); escalações com titulares. */
const match = (extra: Doc = {}): Doc => ({
  idTimeC: 'tA',
  idTimeF: 'tB',
  duracao: 90,
  status: 'encerrada',
  escalacao: {
    casa: [
      { idJogador: 'gk', titular: true },
      { idJogador: 'cb', titular: true },
      { idJogador: 'mf', titular: true },
      { idJogador: 'fw', titular: true },
      { idJogador: 'sub', titular: false },
    ],
    fora: [{ idJogador: 'x1', titular: true }],
  },
  gols: [],
  cartoes: [],
  substituicoes: [],
  ...extra,
});

const goal = (id: string, lado: string, minuto: number | null, idJogador = '', idAssistencia = '') => ({
  id,
  lado,
  idJogador,
  idAssistencia,
  ...(minuto === null ? {} : { minuto }),
});

const score = (data: Doc, id: string, posicao: string, p = params): AthleteScore =>
  scoreAthlete([{ id: 'm1', data }], { id, posicao, teamId: '' }, p);

const rule = (s: AthleteScore, regra: string) => s.itens.filter((i) => i.regra === regra).reduce((t, i) => t + i.pontos, 0);
const reasons = (s: AthleteScore) => s.motivos.map((m) => m.codigo);

test('posições do cadastro (D2)', () => {
  assert.equal(positionOf('lateral'), 'zag');
  assert.equal(positionOf('Volante'), 'mei');
  assert.equal(positionOf('goleiro'), 'gol');
  assert.equal(positionOf(''), null);
});

test('base 10 + gol + assistência + vitória; atacante sem sofrer gols ganha o bônus', () => {
  const s = score(match({ gols: [goal('g1', 'casa', 10, 'fw', 'mf')] }), 'fw', 'atacante');
  assert.equal(rule(s, 'base'), 10);
  assert.equal(rule(s, 'gol'), 5);
  assert.equal(rule(s, 'vitoria'), 3);
  assert.equal(rule(s, 'sem_sofrer_gols'), 2);
  assert.equal(s.total, 20);
  const m = score(match({ gols: [goal('g1', 'casa', 10, 'fw', 'mf')] }), 'mf', 'meia');
  assert.equal(rule(m, 'assistencia'), 5);
  assert.equal(rule(m, 'gols_equipe'), 1);
  assert.equal(m.total, 10 + 5 + 3 + 1 + 2);
});

test('derrota, empate e gols sofridos por posição', () => {
  const lost = match({ gols: [goal('g1', 'fora', 30), goal('g2', 'fora', 60)] });
  assert.equal(score(lost, 'gk', 'goleiro').total, 10 - 3 - 6);
  assert.equal(score(lost, 'cb', 'zagueiro').total, 10 - 3 - 4);
  assert.equal(score(lost, 'mf', 'meia').total, 10 - 3 - 2);
  assert.equal(score(lost, 'fw', 'atacante').total, 10 - 3 - 2);
  const draw = score(match(), 'gk', 'goleiro');
  assert.equal(rule(draw, 'empate'), 0);
  assert.equal(draw.total, 10 + 5);
});

test('cartões: amarelo −3, vermelho −5, 2º amarelo = −8 no total', () => {
  const yellow = score(match({ cartoes: [{ id: 'c1', lado: 'casa', tipo: 'amarelo', idJogador: 'cb', minuto: 10 }] }), 'cb', 'zagueiro');
  assert.equal(rule(yellow, 'amarelo'), -3);
  const second = score(
    match({
      cartoes: [
        { id: 'c1', lado: 'casa', tipo: 'amarelo', idJogador: 'cb', minuto: 10 },
        { id: 'c2', lado: 'casa', tipo: 'amarelo', idJogador: 'cb', minuto: 70 },
        { id: 'c3', lado: 'casa', tipo: 'vermelho', idJogador: 'cb', minuto: 70, segundoAmarelo: true },
      ],
    }),
    'cb',
    'zagueiro',
  );
  assert.equal(rule(second, 'amarelo') + rule(second, 'vermelho'), -8);
  // Expulso aos 70: 70 min em campo (bônus defensivo com ≥ 45).
  assert.equal(second.minutos, 70);
});

test('minutos: 0, 19, 20, 44, 45 e 90', () => {
  const subAt = (minute: number) =>
    match({ substituicoes: [{ id: 's1', lado: 'casa', idSai: 'fw', idEntra: 'sub', minuto: minute }] });
  assert.deepEqual(reasons(score(match(), 'sub', 'atacante')), ['nao_entrou']);
  assert.equal(score(subAt(19), 'fw', 'atacante').total, 0);
  assert.ok(reasons(score(subAt(19), 'fw', 'atacante')).includes('minutos_insuficientes'));
  assert.equal(score(subAt(20), 'fw', 'atacante').total, 10);
  assert.ok(reasons(score(subAt(20), 'fw', 'atacante')).includes('bonus_minutos_insuficientes'));
  assert.equal(score(subAt(44), 'fw', 'atacante').total, 10);
  assert.equal(score(subAt(45), 'fw', 'atacante').total, 12);
  assert.equal(score(match(), 'fw', 'atacante').minutos, 90);
  // O reserva que entrou aos 45 jogou 45.
  assert.equal(score(subAt(45), 'sub', 'atacante').total, 12);
});

test('abaixo do mínimo: só gols, assistências e cartões', () => {
  const data = match({
    substituicoes: [{ id: 's1', lado: 'casa', idSai: 'fw', idEntra: 'sub', minuto: 75 }],
    gols: [goal('g1', 'casa', 80, 'sub', ''), goal('g2', 'fora', 85), goal('g3', 'casa', 88, 'mf', 'sub')],
    cartoes: [{ id: 'c1', lado: 'casa', tipo: 'amarelo', idJogador: 'sub', minuto: 89 }],
  });
  const s = score(data, 'sub', 'meia');
  assert.equal(s.minutos, 15);
  assert.ok(reasons(s).includes('minutos_insuficientes'));
  assert.equal(rule(s, 'base'), 0);
  assert.equal(rule(s, 'vitoria'), 0);
  assert.equal(rule(s, 'gols_sofridos'), 0);
  assert.equal(rule(s, 'gols_equipe'), 0);
  assert.equal(s.total, 5 + 5 - 3);
});

test('substituído não sofre o gol depois da saída; reserva só conta a partir da entrada', () => {
  const data = match({
    substituicoes: [{ id: 's1', lado: 'casa', idSai: 'gk', idEntra: 'sub', minuto: 60 }],
    gols: [goal('g1', 'fora', 75)],
  });
  const out = score(data, 'gk', 'goleiro');
  assert.equal(rule(out, 'gols_sofridos'), 0);
  assert.equal(rule(out, 'sem_sofrer_gols'), 5);
  const inn = score(data, 'sub', 'goleiro');
  assert.equal(rule(inn, 'gols_sofridos'), -3);
  assert.equal(inn.minutos, 30);
});

test('entra e sai na mesma partida', () => {
  const data = match({
    substituicoes: [
      { id: 's1', lado: 'casa', idSai: 'fw', idEntra: 'sub', minuto: 30 },
      { id: 's2', lado: 'casa', idSai: 'sub', idEntra: 'fw', minuto: 70 },
    ],
  });
  const p = participation(parseMatch(data), 'sub', 'casa');
  assert.deepEqual(p.windows, [[30, 70]]);
  assert.equal(p.minutes, 40);
  assert.equal(participation(parseMatch(data), 'fw', 'casa').minutes, 50);
});

test('D4: lado sem escalação — quem tem lance conta o jogo inteiro (estimado), o resto 0', () => {
  const data = match({ escalacao: { casa: [], fora: [] }, gols: [goal('g1', 'casa', 10, 'fw')] });
  const fw = scoreAthlete([{ id: 'm1', data }], { id: 'fw', posicao: 'atacante', teamId: 'tA' }, params);
  assert.equal(fw.minutos, 90);
  assert.ok(reasons(fw).includes('minutos_estimados'));
  const gk = scoreAthlete([{ id: 'm1', data }], { id: 'gk', posicao: 'goleiro', teamId: 'tA' }, params);
  assert.equal(gk.total, 0);
  assert.deepEqual(reasons(gk), ['sem_escalacao']);
  // Troca sem minuto: os dois da troca seguem a mesma regra.
  const noMinute = match({ substituicoes: [{ id: 's1', lado: 'casa', idSai: 'fw', idEntra: 'sub' }] });
  assert.deepEqual(reasons(score(noMinute, 'fw', 'atacante')), ['substituicao_sem_minuto']);
});

test('gol sem minuto só conta para quem jogou a partida inteira', () => {
  const data = match({
    substituicoes: [{ id: 's1', lado: 'casa', idSai: 'cb', idEntra: 'sub', minuto: 50 }],
    gols: [goal('g1', 'fora', null)],
  });
  assert.equal(rule(score(data, 'gk', 'goleiro'), 'gols_sofridos'), -3);
  assert.equal(rule(score(data, 'cb', 'zagueiro'), 'gols_sofridos'), 0);
});

test('placar sem a lista de gols: vitória/derrota pelo placar', () => {
  const s = score(match({ gols: undefined, golTimeCasa: 2, golTimeFora: 1 }), 'gk', 'goleiro');
  assert.equal(rule(s, 'vitoria'), 3);
  assert.equal(rule(s, 'gols_sofridos'), -3);
});

test('duas partidas na rodada somam; sem posição não pontua', () => {
  const s = scoreAthlete(
    [
      { id: 'm1', data: match() },
      { id: 'm2', data: match() },
    ],
    { id: 'fw', posicao: 'atacante', teamId: '' },
    params,
  );
  assert.equal(s.total, 24);
  assert.equal(s.partidas.length, 2);
  assert.deepEqual(reasons(score(match(), 'fw', '')), ['sem_posicao']);
  assert.deepEqual(reasons(scoreAthlete([], { id: 'fw', posicao: 'atacante', teamId: '' }, params)), ['sem_partidas']);
});

test('parâmetros alterados: mínimo 30 e capitão 2×', () => {
  const p = { minMinutos: 30, minMinutosDefesa: 60, capitao: 2 };
  const data = match({ substituicoes: [{ id: 's1', lado: 'casa', idSai: 'fw', idEntra: 'sub', minuto: 25 }] });
  assert.equal(score(data, 'fw', 'atacante', p).total, 0);
  assert.equal(score(data, 'sub', 'atacante', p).total, 12);
  assert.equal(lineupPoints(['a'], 'a', { a: 12 }, 2).pontos, 24);
});

test('capitão 1,5× (também negativo) e a diferença aplicada no participante', () => {
  const ids = ['a', 'b', 'c', 'd', 'e'];
  const totals = { a: 20, b: 10, c: -6, d: 5, e: 0 };
  const captainA = lineupPoints(ids, 'a', totals, 1.5);
  assert.equal(captainA.pontosAtletas.a, 30);
  assert.equal(captainA.pontos, 30 + 10 - 6 + 5);
  const captainC = lineupPoints(ids, 'c', totals, 1.5);
  assert.equal(captainC.pontosAtletas.c, -9);
  assert.equal(lineupPoints(ids, 'd', totals, 1.5).pontosAtletas.d, 7.5);
  // Idempotência: aplicar de novo o mesmo total = 0; súmula corrigida = só a diferença.
  assert.equal(pointsDelta(39, undefined), 39);
  assert.equal(pointsDelta(39, 39), 0);
  assert.equal(pointsDelta(34, 39), -5);
});

test('campos da súmula que mudam a pontuação', () => {
  assert.equal(scoringFieldsChanged({ gols: [] }, { gols: [goal('g1', 'casa', 1)] }), true);
  assert.equal(scoringFieldsChanged({ votacao: 'true' }, { votacao: 'false' }), false);
});

test('craques da rodada: titulares, quem entrou e quem tem lance, sem repetir', () => {
  const ids = roundParticipants([
    {
      escalacao: {
        casa: [{ idJogador: 'a1' }, { idJogador: 'a2' }, { idJogador: 'r1', titular: false }],
        fora: [{ idJogador: 'b1' }],
      },
      substituicoes: [{ lado: 'casa', idSai: 'a2', idEntra: 'r2', minuto: 60 }],
      gols: [{ lado: 'casa', idJogador: 'a1', idAssistencia: 'r2' }],
      cartoes: [{ lado: 'fora', tipo: 'amarelo', idJogador: 'b2' }],
    },
    { gols: [{ lado: 'fora', idJogador: 'c1' }], golTimeCasa: '0' },
  ]);
  assert.deepEqual([...ids].sort(), ['a1', 'a2', 'b1', 'b2', 'c1', 'r2']);
});
