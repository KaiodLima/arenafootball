import assert from 'node:assert/strict';
import { test } from 'node:test';
import { fanRankingTotal, rankingTeamOf, sortFanRanking } from '../fan_ranking';

test('ranking de torcidas: dados do time e contagem saneada', () => {
  const team = rankingTeamOf('1', { nome: ' Lava Jato ', fk_competicao: 'Floresta', idRegiao: 'fl', corPrimaria: '#112233' }, 4);
  assert.deepEqual(team, {
    id: '1',
    nome: 'Lava Jato',
    idRegiao: 'fl',
    regiao: 'Floresta',
    urlImagem: '',
    corPrimaria: '#112233',
    corSecundaria: '',
    torcedores: 4,
  });
  assert.equal(rankingTeamOf('2', { nome: 'X' }, -3).torcedores, 0);
  assert.equal(rankingTeamOf('3', { nome: 'Y' }, Number.NaN).torcedores, 0);
});

test('ranking de torcidas: mais torcedores primeiro, empate e zerados por nome', () => {
  const teams = [
    rankingTeamOf('a', { nome: 'Volta' }, 2),
    rankingTeamOf('b', { nome: 'Açaí no Gralle' }, 5),
    rankingTeamOf('c', { nome: 'Lava Jato' }, 2),
    rankingTeamOf('d', { nome: 'Riacho' }, 0),
    rankingTeamOf('e', { nome: 'Bairro' }, 0),
    rankingTeamOf('f', { nome: '' }, 9),
  ];
  assert.deepEqual(
    sortFanRanking(teams).map((t) => t.id),
    ['b', 'c', 'a', 'e', 'd'],
  );
  assert.equal(fanRankingTotal(sortFanRanking(teams)), 9);
});
