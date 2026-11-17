import assert from 'node:assert/strict';
import { test } from 'node:test';
import { championChange, championMessage, championNews, championNewsId } from '../champion_card';
import { newsMessage } from '../messages';

const champ = {
  titulo: 'Copa X',
  id_campeonato: 7,
  ano: '2026',
  fk_competicao: 'Floresta',
  idRegiao: 'r1',
  idsRegioes: ['r1', 'r2'],
  urlImagem: 'https://img/copa.png',
  encerrado: true,
  campeao: { idTime: 't1', nome: 'Lava Jato', urlImagem: 'https://img/lj.png', corPrimaria: '#112233' },
  vice: { idTime: 't2', nome: 'Volta', urlImagem: '' },
};

test('championChange: encerrou com campeão, reabriu ou nada', () => {
  assert.equal(championChange({}, champ), 'closed');
  assert.equal(championChange({}, { ...champ, campeao: undefined }), null);
  assert.equal(championChange(champ, { ...champ, encerrado: false }), 'reopened');
  assert.equal(championChange(champ, champ), null);
  assert.equal(championChange({}, { titulo: 'x' }), null);
});

test('championNews: campeão em casa, vice fora, competição e regiões', () => {
  const news = championNews('doc1', champ)!;
  assert.equal(news.id, championNewsId('doc1'));
  assert.equal(news.tag, 'campeao');
  assert.equal(news.exibir, 'true');
  assert.equal(news.time_casa, 'Lava Jato');
  assert.equal(news.id_time_casa, 't1');
  assert.equal(news.cor_casa, '#112233');
  assert.equal(news.time_fora, 'Volta');
  assert.equal(news.id_campeonato, 7);
  assert.equal(news.id_campeonato_doc, 'doc1');
  assert.equal(news.temporada, '2026');
  assert.deepEqual(news.idsRegioes, ['r1', 'r2']);
  assert.match(String(news.titulo), /Lava Jato/);
  assert.equal(championNews('doc1', { ...champ, campeao: undefined }), null);
});

test('championMessage: região, torcida do campeão e as outras regiões', () => {
  const message = championMessage(champ)!;
  assert.equal(message.tipo, 'campeao');
  assert.equal(message.imagem, 'https://img/lj.png');
  const alvo = 'condition' in message.alvo ? message.alvo.condition : message.alvo.topic;
  assert.match(alvo, /regiaoid_r1/);
  assert.match(alvo, /timeid_t1/);
  assert.match(alvo, /regiaoid_r2/);
});

test('o card de campeão não manda o push de notícia', () => {
  assert.equal(newsMessage(championNews('doc1', champ)!), null);
});
