import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  dailyGameMessage,
  goalMessage,
  isEnabled,
  manualMessage,
  matchCreatedMessage,
  currentSeasonOf,
  newsMessage,
  openData,
  playerRequestAnswerMessage,
  playerRequestMessage,
  playerRequestToOwnerMessage,
  seasonCollection,
  teamRequestAnswerMessage,
  teamRequestMessage,
  partnerLinkRequestMessage,
  pendingNewsAnswerMessage,
  pendingNewsMessage,
  partnerRequestAnswerMessage,
  partnerRequestMessage,
  targetFor,
  teamIdTopic,
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
  assert.equal(message?.imagem, undefined);
});

test('gol: escudo do time que marcou vira a imagem do push (só URL https)', () => {
  const base = { time_casa: 'Lava Jato', time_fora: 'Volta', fk_competicao: 'Floresta' };
  const crest = 'https://firebasestorage.googleapis.com/v0/b/x/o/times%2Flava.png?alt=media';
  assert.equal(goalMessage({ ...base, escudo_marcador: crest })?.imagem, crest);
  assert.equal(goalMessage({ ...base, escudo_marcador: 'http://inseguro/x.png' })?.imagem, undefined);
  assert.equal(goalMessage({ ...base, escudo_marcador: '' })?.imagem, undefined);
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

test('com os ids dos times: tópico do id (app novo) e do nome (app antigo)', () => {
  assert.equal(teamIdTopic('aB3/dE9'), 'timeid_aB3_dE9');
  const match = {
    timeC: 'A',
    timeF: 'B',
    idTimeC: 'id1',
    idTimeF: 'id2',
    data: '11/10',
    fk_competicao: 'Floresta',
    votacao: 'false',
  };
  // Região + 2 tópicos por time = 5, o limite da condition do FCM.
  assert.deepEqual(matchCreatedMessage(match)?.alvo, {
    condition:
      "'regiao_floresta' in topics || 'timeid_id1' in topics || 'time_a' in topics || 'timeid_id2' in topics || 'time_b' in topics",
  });
  assert.deepEqual(dailyGameMessage(match)?.alvo, {
    condition: "'timeid_id1' in topics || 'time_a' in topics || 'timeid_id2' in topics || 'time_b' in topics",
  });
  const goal = goalMessage({ time_casa: 'A', time_fora: 'B', id_time_casa: 'id1', fk_competicao: 'Floresta' });
  assert.deepEqual(goal?.alvo, {
    condition: "'regiao_floresta' in topics || 'timeid_id1' in topics || 'time_a' in topics || 'time_b' in topics",
  });
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

test('pedido de jogador: novo ou reenviado avisa os admins; correção não', () => {
  const pending = { nome: 'Kaio', time: 'Lava Jato', regiao: 'Floresta', status: 'pendente' };
  const created = playerRequestMessage('AbC1', undefined, pending);
  assert.equal(created?.corpo, 'Kaio quer jogar no Lava Jato');
  assert.deepEqual(created?.alvo, { topic: 'admins' });
  assert.equal(created?.aba, 'solicitacoes');
  assert.ok(playerRequestMessage('AbC1', { ...pending, status: 'rejeitada' }, pending));
  assert.equal(playerRequestMessage('AbC1', pending, { ...pending, nome: 'Kaio L.' }), null);
  assert.equal(playerRequestMessage('AbC1', pending, undefined), null);
});

test('pedido de jogador com competição: cita a competição', () => {
  const pending = { nome: 'Kaio', time: 'Lava Jato', campeonato: 'Copa Floresta', status: 'pendente' };
  assert.equal(playerRequestMessage('AbC1', undefined, pending)?.corpo, 'Kaio quer jogar no Lava Jato na Copa Floresta');
});

test('pedido de vínculo: diz quem é a conta e o atleta reivindicado', () => {
  const claim = { nome: 'Dudu', nome_usuario: 'Eduardo Lima', time: 'Lava Jato', status: 'pendente', idJogadorVinculo: 'p1' };
  assert.equal(playerRequestMessage('AbC1', undefined, claim)?.corpo, 'Eduardo Lima diz ser o atleta Dudu do Lava Jato');
  assert.equal(
    playerRequestToOwnerMessage('Dono1', undefined, claim)?.corpo,
    'Eduardo Lima diz ser o atleta Dudu do Lava Jato',
  );
});

test('resposta do pedido: só para quem pediu, com motivo na rejeição', () => {
  const pending = { nome: 'Kaio', time: 'Lava Jato', regiao: 'Floresta', status: 'pendente' };
  const approved = playerRequestAnswerMessage('AbC1', pending, { ...pending, status: 'aprovada' });
  assert.deepEqual(approved?.alvo, { topic: 'usuario_AbC1' });
  assert.equal(approved?.aba, 'sou_jogador');
  const rejected = playerRequestAnswerMessage('AbC1', pending, { ...pending, status: 'rejeitada', motivo: 'Elenco cheio' });
  assert.equal(rejected?.corpo, 'Sua solicitação para jogar no Lava Jato não foi aprovada. Motivo: Elenco cheio');
  assert.equal(playerRequestAnswerMessage('AbC1', undefined, pending), null);
  assert.equal(playerRequestAnswerMessage('AbC1', { ...pending, status: 'aprovada' }, { ...pending, status: 'aprovada' }), null);
});

test('tirado do elenco: avisa o usuário que as estatísticas ficam', () => {
  const approved = { nome: 'Kaio', time: 'Lava Jato', regiao: 'Floresta', status: 'aprovada' };
  const removed = playerRequestAnswerMessage('AbC1', approved, { ...approved, status: 'removido' });
  assert.equal(removed?.corpo, 'Você não faz mais parte do Lava Jato. Suas estatísticas continuam salvas.');
  assert.deepEqual(removed?.alvo, { topic: 'usuario_AbC1' });
  assert.equal(playerRequestAnswerMessage('AbC1', { ...approved, status: 'removido' }, { ...approved, status: 'removido' }), null);
});

test('coleção por temporada: 2023 sem sufixo, as outras com o ano', () => {
  assert.equal(seasonCollection('partidas', '2023'), 'partidas');
  assert.equal(seasonCollection('partidas', '2024'), 'partidas2024');
  assert.equal(seasonCollection('partidas', '2022'), 'partidas2022');
  assert.equal(currentSeasonOf(undefined), '2023');
  assert.equal(currentSeasonOf({ atual: '2024' }), '2024');
});

test('pedido de time: novo avisa admins; resposta avisa quem pediu', () => {
  const pending = { nome: 'Riacho', nome_usuario: 'Kaio', regiao: 'Floresta', status: 'pendente' };
  const created = teamRequestMessage('AbC1', undefined, pending);
  assert.equal(created?.corpo, 'Kaio quer cadastrar o time Riacho');
  assert.deepEqual(created?.alvo, { topic: 'admins' });
  assert.equal(created?.aba, 'solicitacoes_time');
  assert.equal(teamRequestMessage('AbC1', pending, { ...pending, descricao: 'x' }), null);

  const approved = teamRequestAnswerMessage('AbC1', pending, { ...pending, status: 'aprovada' });
  assert.deepEqual(approved?.alvo, { topic: 'usuario_AbC1' });
  assert.equal(approved?.aba, 'meu_time');
  const rejected = teamRequestAnswerMessage('AbC1', pending, { ...pending, status: 'rejeitada', motivo: 'Nome repetido' });
  assert.equal(rejected?.corpo, 'O pedido do time Riacho não foi aprovado. Motivo: Nome repetido');
});

test('pedido de parceiro: novo avisa admins; resposta e remoção avisam quem pediu', () => {
  const pending = { nome: 'Rádio Floresta', nome_usuario: 'Kaio', regiao: 'Floresta', status: 'pendente' };
  const created = partnerRequestMessage('P1', undefined, pending);
  assert.equal(created?.corpo, 'Kaio quer ser parceiro: Rádio Floresta (Floresta)');
  assert.deepEqual(created?.alvo, { topic: 'admins' });
  assert.equal(created?.aba, 'solicitacoes_parceiro');
  assert.equal(partnerRequestMessage('P1', pending, { ...pending, mensagem: 'x' }), null);

  const approved = { ...pending, status: 'aprovada' };
  const ok = partnerRequestAnswerMessage('P1', pending, approved);
  assert.deepEqual(ok?.alvo, { topic: 'usuario_P1' });
  assert.equal(ok?.aba, 'parceiro');
  assert.equal(ok?.corpo, 'Já pode publicar no app em Floresta. Toque para ver o que está liberado.');
  // Ajuste de permissões do parceiro aprovado não avisa.
  assert.equal(partnerRequestAnswerMessage('P1', approved, { ...approved, limiteDestaques: 3 }), null);
  const revoked = partnerRequestAnswerMessage('P1', approved, { ...approved, status: 'removido', motivo: 'Spam' });
  assert.equal(revoked?.corpo, 'A sua parceria foi encerrada. Motivo: Spam');
  const rejected = partnerRequestAnswerMessage('P1', pending, { ...pending, status: 'rejeitada' });
  assert.equal(rejected?.corpo, 'O pedido de parceria não foi aprovado.');
});

test('parceiro pede vínculo de destaque: avisa admins só com id novo', () => {
  const approved = { nome: 'Rádio', regiao: 'Floresta', status: 'aprovada', idsDestaquesVinculo: ['a'] };
  const message = partnerLinkRequestMessage('P1', approved, { ...approved, idsDestaquesVinculo: ['a', 'b'] });
  assert.equal(message?.corpo, 'Rádio diz que um destaque é dele');
  assert.deepEqual(message?.alvo, { topic: 'admins' });
  assert.equal(partnerLinkRequestMessage('P1', approved, { ...approved, idsDestaquesVinculo: [] }), null);
  // Pedido ainda pendente: o aviso é o do pedido.
  const pending = { ...approved, status: 'pendente' };
  assert.equal(partnerLinkRequestMessage('P1', pending, { ...pending, idsDestaquesVinculo: ['a', 'b'] }), null);
});

test('notícia pendente: chegada avisa admins; resposta avisa o parceiro', () => {
  const pending = { titulo: 'Final', fk_competicao: 'Floresta', idAutor: 'P1', status: 'pendente' };
  const created = pendingNewsMessage(undefined, pending);
  assert.deepEqual(created?.alvo, { topic: 'admins' });
  assert.equal(created?.aba, 'noticias_pendentes');
  assert.equal(pendingNewsMessage(pending, { ...pending, titulo: 'x' }), null);
  const approved = pendingNewsAnswerMessage(pending, { ...pending, status: 'aprovada' });
  assert.deepEqual(approved?.alvo, { topic: 'usuario_P1' });
  assert.equal(approved?.corpo, '"Final" já está no feed.');
  const rejected = pendingNewsAnswerMessage(pending, { ...pending, status: 'rejeitada', motivo: 'Repetida' });
  assert.equal(rejected?.corpo, '"Final" não foi aprovada. Motivo: Repetida');
  assert.equal(pendingNewsAnswerMessage(pending, undefined), null);
});

test('toque abre a tela certa: partida, votação ou notícia', () => {
  const match = { timeC: 'A', timeF: 'B', fk_competicao: 'Floresta', votacao: 'false' };
  const ref = { id: 'm1', season: '2026' };
  assert.deepEqual(matchCreatedMessage(match, ref)?.abrir, { tela: 'partida', id: 'm1', temporada: '2026' });
  assert.deepEqual(votingMessage(match, { ...match, votacao: 'true' }, ref)?.abrir, { tela: 'votacao', id: 'm1', temporada: '2026' });
  assert.equal(matchCreatedMessage(match)?.abrir, undefined);
  assert.deepEqual(dailyGameMessage(match, ref)?.abrir?.tela, 'partida');
  const goal = { tag: 'gol', time_casa: 'A', time_fora: 'B', fk_competicao: 'Floresta', id_partida: 'm1' };
  assert.deepEqual(goalMessage(goal, '2026')?.abrir, { tela: 'partida', id: 'm1', temporada: '2026' });
  assert.equal(goalMessage({ ...goal, id_partida: '' }, '2026')?.abrir, undefined);
  const news = { titulo: 'Final', fk_competicao: 'Floresta', exibir: 'true' };
  assert.deepEqual(newsMessage(news, 'n1')?.abrir, { tela: 'noticia', id: 'n1' });
  assert.deepEqual(openData({ tela: 'votacao', id: 'm1', temporada: '2026' }), { tela: 'votacao', id: 'm1', temporada: '2026' });
  assert.deepEqual(openData(undefined), {});
});

test('pedido "Sou jogador" também avisa o dono do time', () => {
  const pending = { nome: 'Kaio', time: 'Riacho', regiao: 'Floresta', status: 'pendente' };
  const toOwner = playerRequestToOwnerMessage('Dono1', undefined, pending);
  assert.deepEqual(toOwner?.alvo, { topic: 'usuario_Dono1' });
  assert.equal(toOwner?.aba, 'meu_time');
  assert.equal(toOwner?.corpo, 'Kaio quer jogar no Riacho');
  assert.equal(playerRequestToOwnerMessage('Dono1', pending, pending), null);
});

test('região pelo id quando o doc tem idRegiao; senão pelo nome', () => {
  const match = { timeC: 'A', timeF: 'B', data: '11/10', fk_competicao: 'Floresta', idRegiao: 'kv7h', votacao: 'false' };
  assert.deepEqual(matchCreatedMessage(match)?.alvo, {
    condition: "'regiaoid_kv7h' in topics || 'time_a' in topics || 'time_b' in topics",
  });
  assert.deepEqual(manualMessage({ titulo: 'Oi', corpo: 'x', regiao: 'Floresta', idRegiao: 'kv7h' })?.alvo, {
    topic: 'regiaoid_kv7h',
  });
  assert.deepEqual(manualMessage({ titulo: 'Oi', corpo: 'x', regiao: 'Floresta' })?.alvo, { topic: 'regiao_floresta' });
});
