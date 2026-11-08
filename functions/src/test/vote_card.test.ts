import assert from 'node:assert/strict';
import { test } from 'node:test';
import { ALL_VOTE_TEMPLATES, shouldPostVoteCard, voteCardBestPlayerFields, voteCardNews, voteTexts } from '../vote_card';
import { fillTemplate } from '../match_result';

const match = {
  timeC: 'Lava Jato',
  timeF: 'Volta',
  data: '22/10',
  horario: '15:00',
  duracao: 90,
  votacao: 'false',
  id_campeonato: 7,
};

test('15 min antes do fim: posta; antes disso, não', () => {
  // Fim: 15:00 Brasília + 90 min = 19:30 UTC; card a partir de 19:15 UTC.
  assert.equal(shouldPostVoteCard(match, '2026', new Date('2026-10-22T19:14:00Z')), false);
  assert.equal(shouldPostVoteCard(match, '2026', new Date('2026-10-22T19:15:00Z')), true);
  // Pausada até começar: não posta.
  assert.equal(shouldPostVoteCard({ ...match, status: 'aguardando' }, '2026', new Date('2026-10-22T19:20:00Z')), false);
});

test('encerrada na mão: posta; já postado ou jogo antigo: não', () => {
  assert.equal(shouldPostVoteCard({ ...match, status: 'encerrada' }, '2026', new Date('2026-10-22T18:30:00Z')), true);
  assert.equal(
    shouldPostVoteCard({ ...match, votacaoNoticia: 'votacao_m1' }, '2026', new Date('2026-10-22T19:20:00Z')),
    false,
  );
  // 3h depois do fim: não posta mais (ex.: jogo de ontem no primeiro deploy).
  assert.equal(shouldPostVoteCard(match, '2026', new Date('2026-10-22T22:31:00Z')), false);
  assert.equal(shouldPostVoteCard({ timeC: 'A', timeF: 'B', data: '' }, '2026', new Date()), false);
});

test('frases preenchidas e estáveis; campos do card', () => {
  for (const list of [ALL_VOTE_TEMPLATES.titles, ALL_VOTE_TEMPLATES.descriptions]) {
    for (const template of list) assert.doesNotMatch(fillTemplate(template, { casa: 'A', fora: 'B' }), /\{\w+\}/);
  }
  assert.deepEqual(voteTexts(match, 'm1'), voteTexts(match, 'm1'));
  const news = voteCardNews(match, 'm1', '2026', { home: { crest: 'lj.png', color: '#1B8E2D' } });
  assert.equal(news.id, 'votacao_m1');
  assert.equal(news.tag, 'votacao');
  assert.equal(news.votacao, 'true');
  assert.equal(news.escudo_casa, 'lj.png');
});

test('card "Vote no craque" leva as regiões da partida', () => {
  const news = voteCardNews({ timeC: 'Alfa', timeF: 'Beta', idRegiao: 'r1', idsRegioes: ['r1', 'r2'] }, 'm1', '2026');
  assert.deepEqual(news.idsRegioes, ['r1', 'r2']);
});

test('apuração no card: eleito com o time pelo id; sem eleito apaga os campos', () => {
  const m = { timeC: 'Lava Jato', timeF: 'Volta', idTimeC: 't1', idTimeF: 't2' };
  assert.deepEqual(voteCardBestPlayerFields({ nome: ' Dudu ', idTime: 't2', votos: 12, percentual: 48.4 }, m), {
    craque_apurado: true,
    craque_nome: 'Dudu',
    craque_time: 'Volta',
    craque_votos: 12,
    craque_percentual: 48,
  });
  assert.equal(voteCardBestPlayerFields({ nome: 'Ana', idTime: 'x', votos: 3, percentual: 60 }, m).craque_time, null);
  assert.deepEqual(voteCardBestPlayerFields(undefined, m), {
    craque_apurado: true,
    craque_nome: null,
    craque_time: null,
    craque_votos: null,
    craque_percentual: null,
  });
});
