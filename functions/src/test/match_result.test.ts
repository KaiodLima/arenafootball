import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  ALL_TEMPLATES,
  fillTemplate,
  isMatchOver,
  recentDays,
  resultChanged,
  resultGroup,
  resultNews,
  resultTexts,
  shouldPostResult,
} from '../match_result';

const match = {
  timeC: 'Lava Jato',
  timeF: 'Volta',
  idTimeC: '1',
  idTimeF: '2',
  golTimeCasa: 3,
  golTimeFora: 1,
  data: '22/10',
  horario: '15:00',
  duracao: 90,
  id_campeonato: 7,
  local: 'Campo do Gralle',
  fk_competicao: 'Floresta',
  idRegiao: 'r1',
  gols: [
    { lado: 'casa', idJogador: 'dudu', jogador: 'Dudu' },
    { lado: 'casa', idJogador: 'dudu', jogador: 'Dudu' },
    { lado: 'casa', idJogador: '', jogador: '' },
    { lado: 'fora', idJogador: 'ana', jogador: 'Ana' },
  ],
};

test('pelo menos 50 títulos e 50 textos', () => {
  const count = (group: Record<string, string[]>) => Object.values(group).reduce((n, list) => n + list.length, 0);
  assert.ok(count(ALL_TEMPLATES.titles) >= 50);
  assert.ok(count(ALL_TEMPLATES.descriptions) >= 50);
});

test('grupo do resultado: vitória, goleada, empate e 0 × 0', () => {
  assert.equal(resultGroup(2, 1), 'vitoria');
  assert.equal(resultGroup(0, 2), 'vitoria');
  assert.equal(resultGroup(4, 1), 'goleada');
  assert.equal(resultGroup(2, 2), 'empate');
  assert.equal(resultGroup(0, 0), 'zero');
});

test('toda frase fica preenchida (nenhuma chave sobra)', () => {
  const vars = { vencedor: 'A', perdedor: 'B', gv: 2, gp: 1, casa: 'A', fora: 'B', gc: 1, gf: 1, total: 2 };
  for (const group of [ALL_TEMPLATES.titles, ALL_TEMPLATES.descriptions]) {
    for (const list of Object.values(group)) {
      for (const template of list) assert.doesNotMatch(fillTemplate(template, vars), /\{\w+\}/, template);
    }
  }
});

test('texto: frase estável pelo id + gols, competição e local', () => {
  const first = resultTexts(match, 'm1', 'Copa Verde');
  assert.deepEqual(resultTexts(match, 'm1', 'Copa Verde'), first);
  assert.match(first.descricao, /Gols: Dudu \(2\) · Ana/);
  assert.match(first.descricao, /Competição: Copa Verde/);
  assert.match(first.descricao, /Local: Campo do Gralle/);
  // Goleada (3 × 0 seria goleada; 3 × 1 é vitória): vencedor no texto.
  assert.match(first.titulo + first.descricao, /Lava Jato/);
  const friendly = resultTexts({ ...match, id_campeonato: 0 }, 'm1');
  assert.match(friendly.descricao, /Amistoso/);
});

test('campos do card', () => {
  const news = resultNews(match, 'm1', '2026', { home: { crest: 'lj.png', color: '#00AA00' } });
  assert.equal(news.id, 'resultado_m1');
  assert.equal(news.tag, 'resultado');
  assert.equal(news.exibir, 'true');
  assert.equal(news.gol_time_casa, '3');
  assert.equal(news.escudo_casa, 'lj.png');
  assert.equal(news.escudo_fora, '');
  assert.equal(news.idRegiao, 'r1');
  assert.equal(news.id_partida, 'm1');
});

test('quando postar: depois do fim, encerrada na mão, nunca duas vezes', () => {
  // 15:00 Brasília + 90 min = 19:30 UTC.
  assert.equal(isMatchOver(match, '2026', new Date('2026-10-22T19:29:00Z')), false);
  assert.equal(isMatchOver(match, '2026', new Date('2026-10-22T19:30:00Z')), true);
  assert.equal(isMatchOver({ ...match, status: 'encerrada' }, '2026', new Date('2026-10-22T18:00:00Z')), true);
  assert.equal(isMatchOver({ ...match, status: 'andamento' }, '2026', new Date('2026-10-22T23:00:00Z')), false);
  assert.equal(isMatchOver({ ...match, status: 'intervalo' }, '2026', new Date('2026-10-22T23:00:00Z')), false);
  assert.equal(shouldPostResult({ ...match, resultadoNoticia: 'resultado_m1' }, '2026', new Date('2026-10-23T00:00:00Z')), false);
});

test('placar ou gols mudaram', () => {
  assert.equal(resultChanged(match, { ...match }), false);
  assert.equal(resultChanged(match, { ...match, golTimeFora: 2 }), true);
  assert.equal(resultChanged(match, { ...match, gols: [] }), true);
});

test('dias recentes em Brasília', () => {
  // 02h UTC do dia 23 ainda é dia 22 em Brasília.
  assert.deepEqual(recentDays(new Date('2026-10-23T02:00:00Z')), ['22/10', '21/10']);
});
