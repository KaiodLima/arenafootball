import assert from 'node:assert/strict';
import { test } from 'node:test';
import { ALL_VOTE_TEMPLATES, shouldPostVoteCard, voteCardNews, voteTexts } from '../vote_card';
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
