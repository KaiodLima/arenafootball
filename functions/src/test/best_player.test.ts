import assert from 'node:assert/strict';
import { test } from 'node:test';
import { candidateOf, electBestPlayer, rulesOf, voteOf, votingJustClosed } from '../best_player';

const rules = { minVotes: 3, minPercent: 35 };
const candidates = [
  candidateOf('p1', { nome: 'Kaio', idTime: 't1', idUsuario: 'u1' }),
  candidateOf('p2', { nome: 'Dudu', idTime: 't2' }),
  candidateOf('p3', { nome: 'Kaio', idTime: 't9' }),
];
const votes = (list: [string, string, string][]) => list.map(([voter, nome, idTime]) => voteOf(voter, { nome, idTime }));

test('elege o mais votado e acha o atleta pelo nome e time', () => {
  const best = electBestPlayer(
    votes([['a', 'Kaio', 't1'], ['b', 'Kaio', 't1'], ['c', 'Dudu', 't2']]),
    candidates,
    rules,
  );
  assert.deepEqual(best, { nome: 'Kaio', idJogador: 'p1', idTime: 't1', votos: 2, percentual: 67 });
});

test('sem o mínimo de votos, empate ou sem a % mínima: sem eleito', () => {
  assert.equal(electBestPlayer(votes([['a', 'Kaio', 't1'], ['b', 'Kaio', 't1']]), candidates, rules), null);
  assert.equal(
    electBestPlayer(votes([['a', 'Kaio', 't1'], ['b', 'Dudu', 't2'], ['c', 'Kaio', 't1'], ['d', 'Dudu', 't2']]), candidates, rules),
    null,
  );
  const spread = votes([['a', 'Kaio', 't1'], ['b', 'Dudu', 't2'], ['c', 'X', 't3'], ['d', 'Y', 't4'], ['e', 'Z', 't5'], ['f', 'Kaio', 't1']]);
  assert.equal(electBestPlayer(spread, candidates, rules), null);
});

test('voto no próprio atleta não conta', () => {
  const best = electBestPlayer(
    votes([['u1', 'Kaio', 't1'], ['a', 'Dudu', 't2'], ['b', 'Dudu', 't2'], ['c', 'Kaio', 't1']]),
    candidates,
    rules,
  );
  assert.equal(best?.nome, 'Dudu');
});

test('regras do config e padrões; fechamento da votação', () => {
  assert.deepEqual(rulesOf(undefined), { minVotes: 20, minPercent: 35 });
  assert.deepEqual(rulesOf({ minVotos: 5, percentualMinimo: 50 }), { minVotes: 5, minPercent: 50 });
  assert.equal(votingJustClosed({ votacao: 'true' }, { votacao: 'false' }), true);
  assert.equal(votingJustClosed({ votacao: 'false' }, { votacao: 'false' }), false);
});
