import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  computeTable,
  criteriaOf,
  groupGames,
  groupHasAny,
  groupTeams,
  isFinishedMatch,
  legacyStandingFields,
} from '../standings';

const group = { descricao: 'A', fk_campeonato: 7, time1: 'Lava Jato', idTime1: 'a', time2: 'Volta', idTime2: 'b', time3: 'Vila', idTime3: 'c', time4: '', idTime4: '' };
const teams = groupTeams(group);
const match = (home: string, away: string, gc: number, gf: number, extra: Record<string, unknown> = {}) => ({
  idTimeC: home,
  idTimeF: away,
  golTimeCasa: String(gc),
  golTimeFora: String(gf),
  id_campeonato: 7,
  status: 'encerrada',
  ...extra,
});
const table = (matches: Record<string, unknown>[], criteria?: unknown) =>
  computeTable(teams, groupGames(teams, matches, 7), criteriaOf(criteria));

test('times do grupo sem as vagas vazias', () => {
  assert.deepEqual(teams.map((t) => t.id), ['a', 'b', 'c']);
});

test('critérios: sem campo ou inválidos = padrão; repetidos saem', () => {
  assert.deepEqual(criteriaOf(undefined), ['vitorias', 'saldo', 'golsPro']);
  assert.deepEqual(criteriaOf(['xx']), ['vitorias', 'saldo', 'golsPro']);
  assert.deepEqual(criteriaOf(['saldo', 'confronto', 'saldo']), ['saldo', 'confronto']);
});

test('V/E/D, gols, saldo e pontos; time sem jogo zerado', () => {
  const rows = table([match('a', 'b', 3, 1), match('b', 'a', 2, 2)]);
  const lava = rows.find((r) => r.idTime === 'a')!;
  assert.deepEqual(
    [lava.jogos, lava.vitorias, lava.empates, lava.derrotas, lava.golsPro, lava.golsContra, lava.saldo, lava.pontos],
    [2, 1, 1, 0, 5, 3, 2, 4],
  );
  const vila = rows.find((r) => r.idTime === 'c')!;
  assert.equal(vila.jogos, 0);
  assert.deepEqual(rows.map((r) => r.posicao), [1, 2, 3]);
});

test('só conta terminada, do campeonato e entre times do grupo', () => {
  const rows = table([
    match('a', 'b', 1, 0, { status: 'andamento' }),
    match('a', 'b', 1, 0, { id_campeonato: 8 }),
    match('a', 'zz', 1, 0),
    match('a', 'b', 0, 1, { status: '', resultadoNoticia: 'resultado_x' }),
  ]);
  assert.equal(rows.find((r) => r.idTime === 'a')!.jogos, 1);
  assert.equal(rows[0].idTime, 'b');
  assert.equal(isFinishedMatch({ status: 'intervalo' }), false);
});

test('doc antigo sem id: acha o time pelo nome (sem acento/caixa)', () => {
  const rows = table([{ timeC: 'lava jato', timeF: 'VOLTA', golTimeCasa: 2, golTimeFora: 0, id_campeonato: 7, status: 'encerrada' }]);
  assert.equal(rows[0].idTime, 'a');
  assert.equal(rows[0].pontos, 3);
});

test('desempate padrão: vitórias antes do saldo', () => {
  // a: 1V 1D (3 pts, saldo +4); b: 3E (3 pts, saldo 0); c: 1V 1E 1D.
  const rows = table([match('a', 'c', 5, 0), match('c', 'a', 2, 1), match('a', 'b', 0, 0), match('b', 'c', 1, 1)]);
  // a: 1V 1E 1D = 4; b: 2E = 2; c: 1V 1E 1D = 4. a e c empatam em pontos e vitórias: saldo decide.
  assert.deepEqual(rows.map((r) => r.idTime), ['a', 'c', 'b']);
});

test('critério do campeonato: saldo antes, depois gols pró e menos gols contra', () => {
  const games = [match('a', 'b', 4, 3), match('b', 'c', 1, 0), match('c', 'a', 2, 1)];
  // todos 3 pts e saldo 0; gols pró: a 5, b 4, c 2.
  assert.deepEqual(table(games, ['saldo', 'golsPro']).map((r) => r.idTime), ['a', 'b', 'c']);
  // menos gols contra: c sofreu 5? a: contra 5, b: contra 4, c: contra 2 → c, b, a.
  assert.deepEqual(table(games, ['menosGolsContra']).map((r) => r.idTime), ['c', 'b', 'a']);
});

test('confronto direto entre 2 empatados', () => {
  // a e b com 3 pts; b venceu a; a tem saldo melhor.
  const games = [match('a', 'c', 5, 0), match('b', 'a', 1, 0)];
  assert.deepEqual(table(games, ['confronto', 'saldo']).map((r) => r.idTime).slice(0, 2), ['b', 'a']);
  assert.deepEqual(table(games, ['saldo', 'confronto']).map((r) => r.idTime)[0], 'a');
});

test('confronto direto entre 3 empatados: mini-tabela entre eles', () => {
  // ciclo a>b>c>a, todos 3 pts; saldo entre eles: a +3, c 0, b -3.
  const games = [match('a', 'b', 4, 0), match('b', 'c', 1, 0), match('c', 'a', 2, 1)];
  assert.deepEqual(table(games, ['confronto']).map((r) => r.idTime), ['a', 'c', 'b']);
});

test('tudo empatado: ordem alfabética', () => {
  assert.deepEqual(table([]).map((r) => r.nome), ['Lava Jato', 'Vila', 'Volta']);
});

test('espelho na linha antiga e grupos da partida', () => {
  const row = table([match('a', 'b', 2, 1)])[0];
  assert.deepEqual(legacyStandingFields(row, 'A'), {
    vitorias: 1,
    derrotas: 0,
    empates: 0,
    gols_feitos: 2,
    gols_sofridos: 1,
    pontos: 3,
    saldo_gols: 1,
    fk_grupo: 'A',
  });
  assert.equal(groupHasAny(teams, [{ id: 'x', name: '' }, { id: 'c', name: 'Vila' }]), true);
  assert.equal(groupHasAny(teams, [{ id: 'x', name: 'Outro' }]), false);
});
