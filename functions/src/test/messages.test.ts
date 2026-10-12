import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  dailyGameMessage,
  goalMessage,
  isEnabled,
  manualMessage,
  matchCreatedMessage,
  newsMessage,
  targetFor,
  todayKey,
  topicSlug,
  votingMessage,
} from '../messages';

test('slug igual ao do app: sem acento, minúsculo, _ no lugar do resto', () => {
  assert.equal(topicSlug('Santo inácio'), 'santo_inacio');
  assert.equal(topicSlug('X-9 Caiçara'), 'x_9_caicara');
  assert.equal(topicSlug('  Só Mulekes! '), 'so_mulekes');
});

test('vários tópicos viram condition com OR; um vira topic', () => {
  assert.deepEqual(targetFor(['regiao_floresta']), { topic: 'regiao_floresta' });
  assert.deepEqual(targetFor(['regiao_floresta', 'time_volta', 'time_volta']), {
    condition: "'regiao_floresta' in topics || 'time_volta' in topics",
  });
  assert.equal(targetFor([]), null);
});

test('gol: placar no título, autor e assistência no corpo, região + times', () => {
  const message = goalMessage({
    time_casa: 'Lava Jato',
    time_fora: 'Volta',
    gol_time_casa: '2',
    gol_time_fora: '1',
    fk_competicao: 'Floresta',
    autor_gol: 'Dudu',
    assistencia: 'Cassin',
    time_marcador: 'Lava Jato',
  });
  assert.equal(message?.titulo, '⚽ GOL! Lava Jato 2 × 1 Volta');
  assert.equal(message?.corpo, 'Dudu (assist. Cassin) · Lava Jato');
  assert.deepEqual(message?.alvo, {
    condition: "'regiao_floresta' in topics || 'time_lava_jato' in topics || 'time_volta' in topics",
  });
});

test('notícia: só visível e sem gol/publicidade', () => {
  const base = { titulo: 'Final no sábado', descricao: 'Texto', fk_competicao: 'Floresta', exibir: 'true' };
  assert.equal(newsMessage(base)?.alvo && 'topic' in newsMessage(base)!.alvo, true);
  assert.equal(newsMessage({ ...base, exibir: 'false' }), null);
  assert.equal(newsMessage({ ...base, tag: 'publicidade' }), null);
  assert.equal(newsMessage({ ...base, tag: 'Seleção' })?.tipo, 'noticia');
});

test('partida, votação e jogo do dia', () => {
  const match = { timeC: 'A', timeF: 'B', data: '11/10', horario: '16:45', fk_competicao: 'Floresta', votacao: 'false' };
  assert.equal(matchCreatedMessage(match)?.corpo, '11/10 às 16:45');
  assert.equal(votingMessage(match, { ...match, votacao: 'true' })?.tipo, 'votacao_aberta');
  assert.equal(votingMessage({ ...match, votacao: 'true' }, match)?.tipo, 'votacao_encerrada');
  assert.equal(votingMessage(match, { ...match, golTimeCasa: 1 }), null);
  assert.deepEqual(dailyGameMessage(match)?.alvo, { condition: "'time_a' in topics || 'time_b' in topics" });
});

test('aviso manual: região ou todos', () => {
  assert.deepEqual(manualMessage({ titulo: 'Oi', corpo: 'Tudo', regiao: '' })?.alvo, { topic: 'todos' });
  assert.deepEqual(manualMessage({ titulo: 'Oi', corpo: 'Tudo', regiao: 'Santo inacio' })?.alvo, {
    topic: 'regiao_santo_inacio',
  });
  assert.equal(manualMessage({ titulo: '', corpo: 'x' }), null);
});

test('config: valor gravado vence o padrão (notícia desligada por padrão)', () => {
  assert.equal(isEnabled(undefined, 'gol'), true);
  assert.equal(isEnabled(undefined, 'noticia'), false);
  assert.equal(isEnabled({ gol: false }, 'gol'), false);
});

test('hoje no fuso de Brasília', () => {
  // 02:00 UTC de 12/10 ainda é 11/10 em Brasília.
  assert.equal(todayKey(new Date(Date.UTC(2026, 9, 12, 2, 0))), '11/10');
});
