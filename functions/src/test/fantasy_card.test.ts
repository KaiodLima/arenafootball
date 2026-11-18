import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  type FantasyCardAthlete,
  fantasyPointsText,
  fantasyRoundMessage,
  fantasyRoundNews,
  fantasyRoundNewsId,
  fantasyTopThree,
} from '../fantasy_card';
import { newsMessage } from '../messages';

const athlete = (id: string, nome: string, pontos: number): FantasyCardAthlete => ({
  idJogador: id,
  nome,
  time: 'Tigres',
  idTime: 't1',
  urlImagem: id === 'a' ? 'https://img/a.png' : '',
  posicao: 'ata',
  pontos,
});

const config = {
  titulo: 'Copa Verde',
  urlImagem: 'https://img/copa.png',
  fk_competicao: 'Floresta',
  idRegiao: 'r1',
  idsRegioes: ['r1', 'r2'],
  idCampeonato: 8,
  temporada: '2026',
};

test('top 3: maior total, empate pelo nome e mesma colocação; sem pontos fica de fora', () => {
  const top = fantasyTopThree([
    athlete('z', 'Zeca', 0),
    athlete('b', 'Bruno', 18),
    athlete('a', 'Ana', 22),
    athlete('c', 'Caio', 18),
    athlete('d', 'Davi', 9),
    athlete('n', 'Neg', -3),
  ]);
  assert.deepEqual(
    top.map((a) => [a.idJogador, a.colocacao]),
    [
      ['a', 1],
      ['b', 2],
      ['c', 2],
    ],
  );
  assert.deepEqual(fantasyTopThree([athlete('z', 'Zeca', 0), athlete('n', 'Neg', -2)]), []);
  assert.equal(fantasyTopThree([athlete('a', 'Ana', 5)]).length, 1);
});

test('pontos: inteiro sem casa, decimal com vírgula', () => {
  assert.equal(fantasyPointsText(22), '22');
  assert.equal(fantasyPointsText(7.5), '7,5');
});

test('card: id, tag, título, regiões, rodada e os craques', () => {
  const top = fantasyTopThree([athlete('a', 'Ana', 22), athlete('b', 'Bruno', 7.5)]);
  const news = fantasyRoundNews('doc1', config, 3, top)!;
  assert.equal(news.id, fantasyRoundNewsId('doc1', 3));
  assert.equal(news.id, 'fantasy_doc1_r3');
  assert.equal(news.tag, 'fantasy');
  assert.equal(news.exibir, 'true');
  assert.equal(news.titulo, '⭐ Craques da rodada 3 · Copa Verde');
  assert.equal(news.descricao, 'Arena Fantasy · Copa Verde: 1º Ana (22 pts) · 2º Bruno (7,5 pts).');
  assert.equal(news.idRegiao, 'r1');
  assert.deepEqual(news.idsRegioes, ['r1', 'r2']);
  assert.equal(news.id_campeonato, 8);
  assert.equal(news.id_campeonato_doc, 'doc1');
  assert.equal(news.rodada, 3);
  assert.equal((news.craques_fantasy as unknown[]).length, 2);
  assert.equal(fantasyRoundNews('doc1', config, 3, []), null);
});

test('push: região-sede + as outras, os 3 no corpo e a foto do 1º; newsMessage ignora a tag', () => {
  const news = fantasyRoundNews('doc1', config, 3, fantasyTopThree([athlete('a', 'Ana', 22), athlete('b', 'Bruno', 9)]))!;
  const message = fantasyRoundMessage(news)!;
  assert.equal(message.tipo, 'fantasy_rodada');
  assert.equal(message.titulo, '⭐ Craques da rodada 3!');
  assert.equal(message.corpo, 'Copa Verde: 1º Ana (22 pts), 2º Bruno (9 pts). Veja no Arena Fantasy!');
  assert.deepEqual(message.alvo, { condition: "'regiaoid_r1' in topics || 'regiaoid_r2' in topics" });
  assert.equal(message.imagem, 'https://img/a.png');
  assert.equal(newsMessage(news, news.id as string), null);
});
