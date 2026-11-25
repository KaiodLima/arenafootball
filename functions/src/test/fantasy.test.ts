import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  currentRound,
  roundInProgress,
  fantasyChampions,
  fantasyRounds,
  frozenParams,
  scoringParamsOf,
  lineupCopy,
  fantasyFormation,
  formationKeys,
  DEFAULT_FORMATION,
  matchdayOf,
  nextOpenRound,
  previousClosedRound,
  orphanRoundUpdate,
  rescoreRequested,
  lineupWithoutAthletes,
  staleAthleteDocs,
  teamsResetRequested,
  roundActionRequested,
  roundFinalized,
  resetRequested,
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
  // Fechada com jogo já começado: o prazo não muda (D1), só a lista de partidas.
  const later = new Date('2026-11-21T19:00:00Z');
  assert.deepEqual(
    roundSync({ status: 'fechada', fechaEm: new Date('2026-11-20T18:00:00Z'), idsPartidas: ['c'] }, computed, later),
    { idsPartidas: ['c', 'e'] },
  );
  assert.equal(roundSync(undefined, { ...computed, fechaEm: null }), null);
});

test('campos que mexem nas rodadas', () => {
  assert.equal(roundFieldsChanged({ rodada: 1, data: 'x' }, { rodada: 2, data: 'x' }), true);
  assert.equal(roundFieldsChanged({ rodada: 1, golTimeCasa: 0 }, { rodada: 1, golTimeCasa: 1 }), false);
  assert.equal(roundFieldsChanged({ horario: '18:00' }, { horario: '19:00' }), true);
});

test('parâmetros congelados (padrões quando faltam)', () => {
  const frozen = frozenParams({ minMinutos: 30, capitao: 2 });
  assert.deepEqual(
    { minMinutos: frozen.minMinutos, minMinutosDefesa: frozen.minMinutosDefesa, capitao: frozen.capitao },
    { minMinutos: 30, minMinutosDefesa: 45, capitao: 2 },
  );
  assert.equal(frozen.pontos.base, 10);
});

test('tabela congelada: a da rodada > a própria do campeonato > a padrão > os padrões', () => {
  const global = { base: 8, gol: 6 };
  assert.equal(frozenParams({}, global).pontos.base, 8);
  assert.equal(frozenParams({}, global).pontos.assistencia, 5, 'campo que falta = padrão');
  assert.equal(frozenParams({ pontuacao: { base: 12 } }, global).pontos.base, 12);
  assert.equal(frozenParams({ pontuacao: { base: 12 } }, global).pontos.gol, 5, 'a própria não herda da padrão');
  const round = frozenParams({ pontos: { base: 7 }, pontuacao: { base: 12 } }, global);
  assert.equal(round.pontos.base, 7);
  const params = scoringParamsOf(round);
  assert.equal(params.table?.base, 7);
  assert.equal(params.table?.conceded.gol, -3);
});

test('cópia da escalação: mesmos atletas e capitão, marcada copiada; sem atletas, nula', () => {
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
  assert.deepEqual(copy?.idsAtletas, ['p1', 'p2', 'p3', 'p4', 'p5']);
  assert.equal(lineupCopy({ ...lineup, atletas: {} }), null);
  assert.equal(lineupCopy({ ...lineup, atletas: undefined }), null);
  assert.equal(lineupCopy({ ...lineup, capitao: 'p9' })?.capitao, '', 'capitão fora da escalação fica vazio');
});

test('cópia da escalação no formato novo: vagas que existem ficam, novas vazias, capitão que saiu fica vazio', () => {
  const lineup = {
    uid: 'u1',
    atletas: { gol: 'p1', zag: 'p2', mei: 'p3', ata: 'p4', livre: 'p5' },
    idsAtletas: ['p1', 'p2', 'p3', 'p4', 'p5'],
    capitao: 'p5',
  };
  const copy = lineupCopy(lineup, { gol: 1, zag: 2, mei: 2, ata: 2, livre: 0 });
  assert.deepEqual(copy?.atletas, { gol: 'p1', zag: 'p2', zag2: '', mei: 'p3', mei2: '', ata: 'p4', ata2: '' });
  assert.deepEqual(copy?.idsAtletas, ['p1', 'p2', 'p3', 'p4']);
  assert.equal(copy?.capitao, '');
  const bigger = { uid: 'u2', atletas: { gol: 'p1', zag: 'p2', zag2: 'p6', mei: 'p3', ata: 'p4' }, capitao: 'p6' };
  const back = lineupCopy(bigger, { gol: 1, zag: 1, mei: 1, ata: 1, livre: 1 });
  assert.deepEqual(back?.atletas, { gol: 'p1', zag: 'p2', mei: 'p3', ata: 'p4', livre: '' });
  assert.equal(back?.capitao, '');
});

test('formato da escalação: faixas por posição, total de 3 a 7, inválido = uma de cada', () => {
  assert.deepEqual(fantasyFormation(undefined), { gol: 1, zag: 1, mei: 1, ata: 1, livre: 1 });
  assert.deepEqual(fantasyFormation({ gol: 1, zag: 2, mei: 2, ata: 2, livre: 0 }), { gol: 1, zag: 2, mei: 2, ata: 2, livre: 0 });
  assert.deepEqual(fantasyFormation({ gol: 1, zag: 2, mei: 2, ata: 2, livre: 1 }), DEFAULT_FORMATION, 'total 8');
  assert.deepEqual(fantasyFormation({ gol: 2, zag: 1, mei: 1, ata: 1, livre: 0 }), DEFAULT_FORMATION, 'dois goleiros');
  assert.deepEqual(fantasyFormation({ gol: 0, zag: 0, mei: 1, ata: 1, livre: 0 }), DEFAULT_FORMATION, 'total 2');
  assert.deepEqual(fantasyFormation({ gol: 1, zag: 1.5, mei: 1, ata: 1, livre: 1 }), DEFAULT_FORMATION);
  assert.deepEqual(formationKeys({ gol: 1, zag: 3, mei: 0, ata: 1, livre: 2 }), ['gol', 'zag', 'zag2', 'zag3', 'ata', 'livre', 'livre2']);
  assert.deepEqual(frozenParams({ vagas: { gol: 0, zag: 1, mei: 1, ata: 1, livre: 0 } }).vagas, { gol: 0, zag: 1, mei: 1, ata: 1, livre: 0 });
  assert.deepEqual(frozenParams({}).vagas, DEFAULT_FORMATION);
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

test('campeão do Fantasy: maior pontuação; empate = todos; sem pontos, ninguém', () => {
  const p = (id: string, pontos: number) => ({ id, data: { nome: id.toUpperCase(), pontos } });
  assert.deepEqual(fantasyChampions([p('a', 80), p('b', 95.5), p('c', 40)]).map((c) => c.uid), ['b']);
  assert.deepEqual(fantasyChampions([p('b', 90), p('a', 90), p('c', 10)]).map((c) => c.uid), ['a', 'b']);
  assert.deepEqual(fantasyChampions([p('a', 0)]), []);
  assert.deepEqual(fantasyChampions([]), []);
});

test('reapuração pedida: só quando o reapurarEm muda', () => {
  const at = (ms: number) => ({ toMillis: () => ms });
  assert.equal(rescoreRequested({}, { reapurarEm: at(1) }), true);
  assert.equal(rescoreRequested({ reapurarEm: at(1) }, { reapurarEm: at(2) }), true);
  assert.equal(rescoreRequested({ reapurarEm: at(1) }, { reapurarEm: at(1), participantes: 3 }), false);
  assert.equal(rescoreRequested({ ativo: false }, { ativo: true }), false);
  assert.equal(rescoreRequested({ reapurarEm: at(1) }, undefined), false);
});

test('mercado fechado: a rodada em andamento segura a atual até ser finalizada', () => {
  const now = new Date('2026-11-15T12:00:00Z');
  const started = { numero: 1, fechaEm: new Date('2026-11-15T11:30:00Z'), status: 'aberta', idsPartidas: ['a'] };
  const next = { numero: 2, fechaEm: new Date('2026-11-21T18:00:00Z'), status: 'aberta', idsPartidas: ['b'] };
  // Iniciada na mão (ainda aberta) ou já fechada: a atual continua sendo a 1.
  assert.equal(currentRound([started, next], now), 1);
  assert.equal(currentRound([{ ...started, status: 'fechada' }, next], now), 1);
  assert.equal(roundInProgress([{ ...started, status: 'fechada' }, next], now), 1);
  // Todas as partidas terminadas e apuradas: abre a próxima.
  assert.equal(currentRound([{ ...started, status: 'fechada', finalizada: true }, next], now), 2);
  assert.equal(roundInProgress([{ ...started, finalizada: true }, next], now), null);
  // Rodada sem partidas ou vazia não segura; nenhuma aberta = 0.
  assert.equal(currentRound([{ ...started, idsPartidas: [] }, next], now), 2);
  assert.equal(currentRound([{ ...started, status: 'vazia' }, next], now), 2);
  assert.equal(currentRound([{ ...started, status: 'fechada', finalizada: true }], now), 0);
  // Prazo ainda no futuro: não está em andamento.
  assert.equal(roundInProgress([next], now), null);
});

test('zerar pontuações: só com zerarEm novo ou trocado', () => {
  const stamp = (ms: number) => ({ toMillis: () => ms });
  assert.equal(resetRequested({}, { zerarEm: stamp(1) }), true);
  assert.equal(resetRequested({ zerarEm: stamp(1) }, { zerarEm: stamp(2) }), true);
  assert.equal(resetRequested({ zerarEm: stamp(1) }, { zerarEm: stamp(1), ativo: false }), false);
  assert.equal(resetRequested({}, { reapurarEm: stamp(1) }), false);
  assert.equal(resetRequested({ zerarEm: stamp(1) }, undefined), false);
});

test('rodada sem partidas (apagadas): aberta vira vazia; fechada fica finalizada e não trava o mercado', () => {
  assert.deepEqual(orphanRoundUpdate({ status: 'aberta', idsPartidas: ['m1'] }), { status: 'vazia', idsPartidas: [] });
  assert.deepEqual(orphanRoundUpdate({ status: 'fechada', idsPartidas: ['m1'] }), { idsPartidas: [], finalizada: true });
  assert.equal(orphanRoundUpdate({ status: 'fechada', idsPartidas: [], finalizada: true }), null);
  assert.equal(orphanRoundUpdate({ status: 'vazia', idsPartidas: [] }), null);
  // Limpa, a rodada fechada não é mais "em andamento".
  const now = new Date('2026-11-19T12:00:00Z');
  const orphan = { numero: 1, fechaEm: new Date('2026-11-18T18:00:00Z'), status: 'fechada', idsPartidas: [], finalizada: true };
  const next = { numero: 2, fechaEm: new Date('2026-11-21T18:00:00Z'), status: 'aberta', idsPartidas: ['m2'] };
  assert.equal(currentRound([orphan, next], now), 2);
});

test('rodada finalizada: só as partidas que ainda existem contam', () => {
  assert.equal(roundFinalized(2, 2), true);
  assert.equal(roundFinalized(2, 1), false);
  assert.equal(roundFinalized(0, 0), true);
});

test('fechada sem jogo começado (a partida que fechou saiu) reabre; fechada pelo admin não', () => {
  const now = new Date('2026-11-19T12:00:00Z');
  const computed = { numero: 1, idsPartidas: ['real1', 'real2'], fechaEm: new Date('2026-11-22T18:00:00Z') };
  const stuck = { status: 'fechada', fechaEm: new Date('2026-11-18T20:00:00Z'), idsPartidas: ['fake', 'real1', 'real2'] };
  assert.deepEqual(roundSync(stuck, computed, now), {
    numero: 1,
    idsPartidas: ['real1', 'real2'],
    fechaEm: computed.fechaEm,
    status: 'aberta',
  });
  assert.deepEqual(roundSync({ ...stuck, fechadaManual: true }, computed, now), { idsPartidas: ['real1', 'real2'] });
  // Aberta com o prazo do admin: o prazo fica, só as partidas mudam.
  const manual = { status: 'aberta', fechaEm: new Date('2026-11-20T12:00:00Z'), idsPartidas: ['real1'], prazoManual: true };
  assert.deepEqual(roundSync(manual, computed, now), { idsPartidas: ['real1', 'real2'] });
  assert.equal(roundSync({ ...manual, idsPartidas: ['real1', 'real2'] }, computed, now), null);
});

test('abrir/fechar rodada pelo admin: só com "em" novo e ação válida', () => {
  const stamp = (ms: number) => ({ toMillis: () => ms });
  const prazo = { toDate: () => new Date('2026-11-22T18:00:00Z') };
  const open = { acaoRodada: { numero: 1, acao: 'abrir', em: stamp(1), prazo } };
  assert.deepEqual(roundActionRequested({}, open), { numero: 1, acao: 'abrir', prazo: new Date('2026-11-22T18:00:00Z') });
  assert.equal(roundActionRequested(open, open), null);
  assert.deepEqual(roundActionRequested(open, { acaoRodada: { numero: 2, acao: 'fechar', em: stamp(2) } }), {
    numero: 2,
    acao: 'fechar',
    prazo: null,
  });
  assert.equal(roundActionRequested({}, { acaoRodada: { numero: 1, acao: 'abrir', em: stamp(3) } }), null);
  assert.equal(roundActionRequested({}, { acaoRodada: { numero: 0, acao: 'fechar', em: stamp(3) } }), null);
  assert.equal(roundActionRequested({}, { acaoRodada: { numero: 1, acao: 'apagar', em: stamp(3) } }), null);
});

test('zerar pontos de times: só com "em" novo e de 1 a 10 ids', () => {
  const stamp = (ms: number) => ({ toMillis: () => ms });
  const request = { zerarTimes: { ids: ['t1', 't2', 't1'], em: stamp(1) } };
  assert.deepEqual(teamsResetRequested({}, request), ['t1', 't2']);
  assert.equal(teamsResetRequested(request, request), null);
  assert.equal(teamsResetRequested({}, { zerarTimes: { ids: [], em: stamp(2) } }), null);
  assert.equal(
    teamsResetRequested({}, { zerarTimes: { ids: Array.from({ length: 11 }, (_, i) => `t${i}`), em: stamp(3) } }),
    null,
  );
});

test('escalação sem os atletas zerados: pontos de novo e fora de "jogaram"', () => {
  const lineup = {
    pontosAtletas: { gk: 5, fw: 22.5, mf: -3 },
    atletasJogaram: ['gk', 'fw', 'mf'],
  };
  assert.deepEqual(lineupWithoutAthletes(lineup, new Set(['fw'])), {
    pontos: 2,
    pontosAtletas: { gk: 5, fw: 0, mf: -3 },
    atletasJogaram: ['gk', 'mf'],
  });
  assert.equal(lineupWithoutAthletes(lineup, new Set(['zz'])), null);
});

test('auditoria que sobrou: gravados que não foram apurados agora', () => {
  assert.deepEqual(staleAthleteDocs(['a', 'b', 'c'], new Set(['a', 'c'])), ['b']);
  assert.deepEqual(staleAthleteDocs([], new Set(['a'])), []);
});
