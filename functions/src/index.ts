/**
 * Notificações push do Arena Football.
 *
 * Gatilhos no Firestore (temporada corrente = coleções sem sufixo) e um
 * agendamento diário. Cada envio respeita `config/notificacoes` (painel do
 * admin) e fica registrado em `notificacoes_envios` (id do evento: não
 * duplica em retry).
 *
 * Região us-central1: o banco está em nam5 e os gatilhos do Firestore
 * precisam rodar na região do banco.
 *
 * O Firebase Admin é carregado só na primeira execução ([admin]): no topo,
 * o carregamento pesado (gRPC do Firestore) estoura o limite de 10s da
 * análise do deploy.
 */
import type { DocumentReference, FieldValue as FieldValueType, Firestore } from 'firebase-admin/firestore';
import type { Messaging } from 'firebase-admin/messaging';
import type { Storage } from 'firebase-admin/storage';
import * as functionsV1 from 'firebase-functions/v1';
import { logger, setGlobalOptions } from 'firebase-functions/v2';
import { onDocumentCreated, onDocumentUpdated, onDocumentWritten } from 'firebase-functions/v2/firestore';
import { onRequest } from 'firebase-functions/v2/https';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import {
  PushMessage,
  currentSeasonOf,
  dailyGameMessage,
  describeTarget,
  goalMessage,
  isEnabled,
  manualMessage,
  matchCreatedMessage,
  newsMessage,
  playerRequestAnswerMessage,
  playerRequestMessage,
  playerRequestToOwnerMessage,
  teamRequestAnswerMessage,
  teamRequestMessage,
  seasonCollection,
  todayKey,
  votingMessage,
} from './messages';
import { isLegacyVoteCollection, seasonCollections, seasonsToSweep, userPhotoPath } from './account_cleanup';
import { claimReconcilePlan, missingEnrollmentFix, needsClaimReconcile } from './claim_reconcile';
import { FanRankingTeam, fanRankingTotal, rankingTeamOf, sortFanRanking } from './fan_ranking';
import { shouldAutoFinish, shouldCloseVoting } from './voting_close';
import {
  ResultTeam,
  recentDays,
  resultChanged,
  resultNews,
  resultNewsId,
  shouldPostResult,
} from './match_result';
import { shouldPostVoteCard, voteCardNews, voteNewsId } from './vote_card';
import {
  Achievement,
  achievementFromDoc,
  achievementMessage,
  athleteCounters,
  changedFields,
  countersChanged,
  isFirstEvaluation,
  missingServerFields,
  newUnlocks,
  profileCounters,
  UNLOCKED_FIELD,
} from './achievements';
import {
  APP_PAGE,
  NOT_FOUND_PAGE,
  PageData,
  athletePageData,
  highlightPageData,
  newsPageData,
  parseSharePath,
  renderSharePage,
} from './share_page';

setGlobalOptions({ region: 'us-central1', maxInstances: 5 });

interface AdminServices {
  db: Firestore;
  messaging: Messaging;
  storage: Storage;
  FieldValue: typeof FieldValueType;
}

let services: Promise<AdminServices> | undefined;

async function loadAdmin(): Promise<AdminServices> {
  const { initializeApp } = await import('firebase-admin/app');
  const { getFirestore, FieldValue } = await import('firebase-admin/firestore');
  const { getMessaging } = await import('firebase-admin/messaging');
  const { getStorage } = await import('firebase-admin/storage');
  initializeApp();
  return { db: getFirestore(), messaging: getMessaging(), storage: getStorage(), FieldValue };
}

/** Firebase Admin inicializado uma vez, na primeira execução. */
function admin(): Promise<AdminServices> {
  services ??= loadAdmin();
  return services;
}

const ANDROID_CHANNEL = 'arena_default';

async function deliver(logId: string, message: PushMessage, origem: string): Promise<void> {
  const { db, messaging, FieldValue } = await admin();
  const logRef = db.collection('notificacoes_envios').doc(logId);
  if ((await logRef.get()).exists) return;

  const config = (await db.doc('config/notificacoes').get()).data();
  const base = {
    tipo: message.tipo,
    titulo: message.titulo,
    corpo: message.corpo,
    alvo: describeTarget(message.alvo),
    regiao: message.regiao,
    origem,
    data: FieldValue.serverTimestamp(),
  };
  if (!isEnabled(config, message.tipo)) {
    await logRef.set({ ...base, status: 'desligado' });
    return;
  }
  try {
    const messageId = await messaging.send({
      ...message.alvo,
      notification: {
        title: message.titulo,
        body: message.corpo,
        ...(message.imagem ? { imageUrl: message.imagem } : {}),
      },
      data: { tipo: message.tipo, aba: message.aba, ...(message.imagem ? { imagem: message.imagem } : {}) },
      android: {
        priority: 'high',
        notification: { channelId: ANDROID_CHANNEL, icon: 'ic_stat_arena', color: '#4CAF50' },
      },
    });
    await logRef.set({ ...base, status: 'enviado', messageId });
  } catch (error) {
    logger.error('Falha ao enviar push', { logId, error });
    await logRef.set({ ...base, status: 'erro', erro: String(error) });
  }
}

/** Card de gol ou notícia publicada. */
export const onNewsCreated = onDocumentCreated('noticias/{newsId}', async (event) => {
  const data = event.data?.data();
  if (!data) return;
  const message = data.tag === 'gol' ? goalMessage(data) : newsMessage(data);
  if (message) await deliver(`${message.tipo}_${event.id}`, message, `noticias/${event.params.newsId}`);
});

let seasonCache: { value: string; at: number } | undefined;

/** Temporada atual (`config/temporadas`), com cache de 5 min por instância. */
async function currentSeason(): Promise<string> {
  if (seasonCache && Date.now() - seasonCache.at < 5 * 60 * 1000) return seasonCache.value;
  const { db } = await admin();
  const value = currentSeasonOf((await db.doc('config/temporadas').get()).data());
  seasonCache = { value, at: Date.now() };
  return value;
}

/**
 * A coleção de partidas muda a cada temporada (`partidas`, `partidas2024`...),
 * então o gatilho escuta qualquer coleção e só segue na da temporada atual.
 * Os nomes de coleção são checados antes de qualquer leitura.
 */
async function isCurrentMatchCollection(collection: string): Promise<boolean> {
  if (!/^partidas(\d{4})?$/.test(collection)) return false;
  return collection === seasonCollection('partidas', await currentSeason());
}

/** Partida cadastrada na temporada atual. */
export const onMatchCreated = onDocumentCreated('{colecao}/{matchId}', async (event) => {
  if (!(await isCurrentMatchCollection(event.params.colecao))) return;
  const data = event.data?.data();
  const message = data ? matchCreatedMessage(data) : null;
  if (message) await deliver(`partida_${event.id}`, message, `${event.params.colecao}/${event.params.matchId}`);
});

/** Votação de melhor jogador aberta/encerrada. */
export const onMatchUpdated = onDocumentUpdated('{colecao}/{matchId}', async (event) => {
  if (!(await isCurrentMatchCollection(event.params.colecao))) return;
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  const message = before && after ? votingMessage(before, after) : null;
  if (message) {
    await deliver(`${message.tipo}_${event.id}`, message, `${event.params.colecao}/${event.params.matchId}`);
  }
  if (!before || !after) return;
  const { colecao, matchId } = event.params;
  const justFinished = before.status !== 'encerrada' && after.status === 'encerrada';
  // Card "Vote no craque": encerrada na mão antes dos 15 min finais → posta agora.
  if (justFinished && shouldPostVoteCard(after, await currentSeason())) {
    await postVoteCard(colecao, await currentSeason(), matchId, after);
  }
  // Votação abriu/fechou: o card de votação acompanha ("Votar agora" / "Ver resultado").
  if (after.votacaoNoticia && before.votacao !== after.votacao) {
    const { db } = await admin();
    await db
      .collection('noticias')
      .doc(String(after.votacaoNoticia))
      .update({ votacao: String(after.votacao) === 'true' ? 'true' : 'false' })
      .catch((error) => logger.warn('Card de votação não atualizado', { matchId, error: String(error) }));
  }
  // Card de resultado: o admin encerrou agora → posta; placar corrigido → atualiza.
  if (justFinished && !after.resultadoNoticia) {
    await postResult(colecao, await currentSeason(), matchId, after);
  } else if (after.resultadoNoticia && resultChanged(before, after)) {
    await updateResult(await currentSeason(), matchId, after);
  }
});

/**
 * Posta o card "Vote no craque" (uma vez por partida), marca a partida e abre
 * a votação se estiver fechada (o gatilho de partidas manda o push de votação aberta).
 */
async function postVoteCard(collection: string, season: string, matchId: string, match: Record<string, unknown>) {
  const { db, FieldValue } = await admin();
  const [home, away, title] = await Promise.all([
    resultTeam(season, match.idTimeC),
    resultTeam(season, match.idTimeF),
    championshipTitle(match.id_campeonato),
  ]);
  const ref = db.collection('noticias').doc(voteNewsId(matchId));
  try {
    await ref.create({
      ...voteCardNews(match, matchId, season, { home, away, championshipTitle: title }),
      data: FieldValue.serverTimestamp(),
    });
    logger.info('Card de votação postado', { match: `${collection}/${matchId}` });
  } catch (error) {
    logger.info('Card de votação já existia', { match: `${collection}/${matchId}`, error: String(error) });
  }
  await db
    .collection(collection)
    .doc(matchId)
    .update({ votacaoNoticia: ref.id, ...(String(match.votacao) === 'true' ? {} : { votacao: 'true' }) });
}

/** Escudo e cor do time (`times{ano}`), para o card de resultado. */
async function resultTeam(season: string, teamId: unknown): Promise<ResultTeam | undefined> {
  const id = typeof teamId === 'string' ? teamId.trim() : '';
  if (!id) return undefined;
  const { db } = await admin();
  const data = (await db.collection(seasonCollection('times', season)).doc(id).get()).data();
  return data ? { crest: String(data.urlImagem ?? ''), color: String(data.corPrimaria ?? '') } : undefined;
}

/** Título do campeonato da partida (vazio em amistoso ou sem cadastro). */
async function championshipTitle(championshipId: unknown): Promise<string> {
  const id = Number(championshipId);
  if (!(id > 0)) return '';
  const { db } = await admin();
  const found = await db.collection('campeonatos').where('id_campeonato', '==', id).limit(1).get();
  return String(found.docs[0]?.data().titulo ?? '').trim();
}

/** Posta o card de resultado (uma vez por partida) e marca a partida. */
async function postResult(collection: string, season: string, matchId: string, match: Record<string, unknown>) {
  const { db, FieldValue } = await admin();
  const [home, away, title] = await Promise.all([
    resultTeam(season, match.idTimeC),
    resultTeam(season, match.idTimeF),
    championshipTitle(match.id_campeonato),
  ]);
  const news = resultNews(match, matchId, season, { home, away, championshipTitle: title });
  const ref = db.collection('noticias').doc(resultNewsId(matchId));
  try {
    await ref.create({ ...news, data: FieldValue.serverTimestamp() });
    logger.info('Card de resultado postado', { match: `${collection}/${matchId}` });
  } catch (error) {
    // Já existe (rodada anterior ou o gatilho do admin): só marca a partida.
    logger.info('Card de resultado já existia', { match: `${collection}/${matchId}`, error: String(error) });
  }
  await db.collection(collection).doc(matchId).update({ resultadoNoticia: ref.id });
}

/** Placar/gols corrigidos depois: refaz título, texto e placar do mesmo card. */
async function updateResult(season: string, matchId: string, match: Record<string, unknown>) {
  const { db } = await admin();
  const ref = db.collection('noticias').doc(resultNewsId(matchId));
  const current = (await ref.get()).data();
  if (!current) return;
  const news = resultNews(match, matchId, season, {
    home: { crest: String(current.escudo_casa ?? ''), color: String(current.cor_casa ?? '') },
    away: { crest: String(current.escudo_fora ?? ''), color: String(current.cor_fora ?? '') },
    championshipTitle: String(current.campeonato ?? ''),
  });
  await ref.update({
    titulo: news.titulo,
    descricao: news.descricao,
    gol_time_casa: news.gol_time_casa,
    gol_time_fora: news.gol_time_fora,
  });
}

/** Aviso manual enviado pelo painel. */
export const onNoticeCreated = onDocumentCreated('push_avisos/{noticeId}', async (event) => {
  const data = event.data?.data();
  const message = data ? manualMessage(data) : null;
  if (message) await deliver(`aviso_${event.params.noticeId}`, message, `push_avisos/${event.params.noticeId}`);
});

/** Pedido "Sou jogador": novo/reenviado avisa os admins; resposta avisa quem pediu. */
export const onPlayerRequestWritten = onDocumentWritten('solicitacoes_jogador/{uid}', async (event) => {
  const uid = event.params.uid;
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  const origem = `solicitacoes_jogador/${uid}`;
  if (after && needsClaimReconcile(after)) await reconcileClaim(uid, after);
  if (after?.status === 'aprovada' && typeof after.idCampeonato === 'number') await ensureEnrollment(after);
  const toAdmins = playerRequestMessage(uid, before, after);
  if (toAdmins) await deliver(`solicitacao_${event.id}`, toAdmins, origem);
  const toUser = playerRequestAnswerMessage(uid, before, after);
  if (toUser) await deliver(`resposta_${event.id}`, toUser, origem);

  // Dono do time do pedido (se o time tiver dono aprovado): pelo id do time;
  // pedido antigo (sem `idTime`), pelo nome.
  const team = typeof after?.time === 'string' ? after.time : '';
  const teamId = typeof after?.idTime === 'string' ? after.idTime : '';
  if (toAdmins && (team || teamId)) {
    const { db } = await admin();
    const owners = await db
      .collection('solicitacoes_time')
      .where(teamId ? 'idTime' : 'nome', '==', teamId || team)
      .where('status', '==', 'aprovada')
      .limit(1)
      .get();
    const owner = owners.docs[0]?.id;
    const toOwner = owner ? playerRequestToOwnerMessage(owner, before, after) : null;
    if (toOwner) await deliver(`dono_${event.id}`, toOwner, origem);
  }
});

/**
 * Vínculo aprovado por app antigo (criou um atleta novo em vez de ligar a
 * conta ao reivindicado): liga a conta ao reivindicado, soma os números do
 * criado, apaga o criado e aponta o pedido e os cards de gol para o
 * reivindicado. Idempotente: depois disso o pedido já não precisa.
 */
async function reconcileClaim(uid: string, request: Record<string, unknown>): Promise<void> {
  const { db } = await admin();
  const season = typeof request.temporada === 'string' ? request.temporada : '';
  const players = db.collection(seasonCollection('jogadores', season));
  const claimedRef = players.doc(String(request.idJogadorVinculo));
  const createdId = String(request.idJogador);
  const createdRef = players.doc(createdId);
  const requestRef = db.collection('solicitacoes_jogador').doc(uid);

  const plan = await db.runTransaction(async (tx) => {
    const [claimed, created, current] = await Promise.all([tx.get(claimedRef), tx.get(createdRef), tx.get(requestRef)]);
    // Outra execução já resolveu (ou o pedido mudou): nada a fazer.
    const fresh = current.data();
    if (!fresh || !needsClaimReconcile(fresh)) return null;
    const result = claimReconcilePlan(uid, fresh, claimed.data(), created.data());
    if (!result) return null;
    tx.update(claimedRef, result.claimedUpdate);
    if (result.deleteCreated) tx.delete(createdRef);
    tx.update(requestRef, { idJogador: result.requestPlayerId });
    return result;
  });
  if (!plan) {
    logger.warn('vínculo não reconciliado', { uid, claimed: request.idJogadorVinculo, created: createdId });
    return;
  }

  // Cards de gol lançados para o atleta criado passam para o reivindicado.
  const news = db.collection('noticias');
  for (const field of ['autor_gol_id', 'assistencia_id']) {
    const cards = await news.where(field, '==', createdId).get();
    await Promise.all(cards.docs.map((doc) => doc.ref.update({ [field]: plan.requestPlayerId })));
  }
  logger.info('vínculo reconciliado', { uid, player: plan.requestPlayerId, removed: createdId });
}

/** Aprovado por app antigo sem a inscrição da competição: completa no atleta. */
async function ensureEnrollment(request: Record<string, unknown>): Promise<void> {
  const playerId = typeof request.idJogador === 'string' ? request.idJogador : '';
  if (!playerId) return;
  const { db } = await admin();
  const season = typeof request.temporada === 'string' ? request.temporada : '';
  const ref = db.collection(seasonCollection('jogadores', season)).doc(playerId);
  const fix = await db.runTransaction(async (tx) => {
    const player = await tx.get(ref);
    const changes = missingEnrollmentFix(request, player.data());
    if (changes) tx.update(ref, changes);
    return changes;
  });
  if (fix) logger.info('inscrição completada', { player: playerId, championship: request.idCampeonato });
}

/** Pedido "Sou dono de time": novo/reenviado avisa os admins; resposta avisa quem pediu. */
export const onTeamRequestWritten = onDocumentWritten('solicitacoes_time/{uid}', async (event) => {
  const uid = event.params.uid;
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  const origem = `solicitacoes_time/${uid}`;
  const toAdmins = teamRequestMessage(uid, before, after);
  if (toAdmins) await deliver(`pedido_time_${event.id}`, toAdmins, origem);
  const toUser = teamRequestAnswerMessage(uid, before, after);
  if (toUser) await deliver(`resposta_time_${event.id}`, toUser, origem);
  // Conquista "dono de time": pedido aprovado agora.
  if (after?.status === 'aprovada' && before?.status !== 'aprovada') {
    await progressRef(uid).then((ref) => ref.set({ donoTime: 1 }, { merge: true }));
  }
});

/** Todo dia às 9h: lembra os torcedores dos times que jogam hoje (temporada atual). */
export const dailyGames = onSchedule({ schedule: '0 9 * * *', timeZone: 'America/Sao_Paulo' }, async () => {
  const today = todayKey();
  const { db } = await admin();
  const collection = seasonCollection('partidas', await currentSeason());
  const matches = await db.collection(collection).where('data', '==', today).get();
  for (const doc of matches.docs) {
    const message = dailyGameMessage(doc.data());
    if (message) await deliver(`jogo_do_dia_${today.replace('/', '-')}_${doc.id}`, message, `${collection}/${doc.id}`);
  }
});

/**
 * A cada 15 min: fecha as votações de melhor jogador abertas há 24h do fim da
 * partida (data + horário + duração). Fechar grava `votacao: "false"`, e o
 * gatilho de partidas manda o push de votação encerrada. Na mesma rodada,
 * posta o card "Vote no craque" ~15 min antes do fim (`vote_card.ts`) e o
 * card de resultado das partidas que acabaram (`match_result.ts`).
 */
export const closeVotings = onSchedule({ schedule: 'every 15 minutes', timeZone: 'America/Sao_Paulo' }, async () => {
  const { db, FieldValue } = await admin();
  const season = await currentSeason();
  const collection = seasonCollection('partidas', season);
  const open = await db.collection(collection).where('votacao', '==', 'true').get();
  const now = new Date();
  for (const doc of open.docs) {
    if (!shouldCloseVoting(doc.data(), season, now)) continue;
    await doc.ref.update({ votacao: 'false' });
    logger.info('Votação encerrada automaticamente', { match: `${collection}/${doc.id}` });
  }
  // Na mesma rodada (sem agendamento novo): card de resultado das partidas de
  // hoje e de ontem que já acabaram pelo horário.
  const recent = await db.collection(collection).where('data', 'in', recentDays(now)).get();
  for (const doc of recent.docs) {
    // Iniciada na mão e esquecida em andamento: encerra (o gatilho de partidas
    // posta os cards de votação e de resultado).
    if (shouldAutoFinish(doc.data(), season, now)) {
      await doc.ref.update({ status: 'encerrada', statusEm: FieldValue.serverTimestamp() });
      logger.info('Partida encerrada automaticamente', { match: `${collection}/${doc.id}` });
      continue;
    }
    // ~15 min antes do fim: card "Vote no craque" (abre a votação).
    if (shouldPostVoteCard(doc.data(), season, now)) await postVoteCard(collection, season, doc.id, doc.data());
    if (shouldPostResult(doc.data(), season, now)) await postResult(collection, season, doc.id, doc.data());
  }
});

/**
 * A cada hora: ranking de torcidas da temporada atual. Conta os torcedores de
 * cada time com `count()` em `usuarios` (pelo `idTime`, e as contas antigas
 * sem id pelo nome), sem ler os perfis, e grava um doc público que o app lê
 * de uma vez: `ranking_torcidas/{temporada}`.
 */
export const fanRanking = onSchedule({ schedule: '0 * * * *', timeZone: 'America/Sao_Paulo' }, async () => {
  const { db, FieldValue } = await admin();
  const season = await currentSeason();
  const teams = await db.collection(seasonCollection('times', season)).get();
  const users = db.collection('usuarios');
  const entries: FanRankingTeam[] = [];
  for (const team of teams.docs) {
    const data = team.data();
    const name = typeof data.nome === 'string' ? data.nome : '';
    const [byId, legacy] = await Promise.all([
      users.where('idTime', '==', team.id).count().get(),
      name ? users.where('idTime', '==', '').where('time', '==', name).count().get() : null,
    ]);
    entries.push(rankingTeamOf(team.id, data, byId.data().count + (legacy?.data().count ?? 0)));
  }
  const ranking = sortFanRanking(entries);
  await db.collection('ranking_torcidas').doc(season).set({
    temporada: season,
    atualizado_em: FieldValue.serverTimestamp(),
    total: fanRankingTotal(ranking),
    times: ranking,
  });
  logger.info('ranking de torcidas', { season, times: ranking.length, total: fanRankingTotal(ranking) });
});

/**
 * Página pública dos links compartilhados (Hosting reescreve `/noticia/**`,
 * `/atleta/**`, `/destaque/**` e `/app` para cá). Cache no CDN do Hosting:
 * a mesma página aberta várias vezes não chama a function de novo.
 */
export const sharePage = onRequest({ maxInstances: 3 }, async (req, res) => {
  const path = req.path || '/';
  const share = parseSharePath(path);
  res.set('Cache-Control', 'public, max-age=300, s-maxage=600');
  if (!share) {
    res.status(404).send(renderSharePage(NOT_FOUND_PAGE, { kind: 'app' }, '/app'));
    return;
  }
  try {
    let data: PageData | null = APP_PAGE;
    if (share.kind !== 'app') {
      const { db } = await admin();
      const ref =
        share.kind === 'noticia'
          ? db.collection('noticias').doc(share.id)
          : share.kind === 'destaque'
            ? db.collection('destaques').doc(share.id)
            : db.collection(seasonCollection('jogadores', share.season)).doc(share.id);
      const doc = (await ref.get()).data();
      data = !doc
        ? null
        : share.kind === 'noticia'
          ? newsPageData(doc)
          : share.kind === 'destaque'
            ? highlightPageData(doc)
            : athletePageData(doc, share.season);
    }
    if (!data) {
      res.status(404).send(renderSharePage(NOT_FOUND_PAGE, share, path));
      return;
    }
    res.status(200).send(renderSharePage(data, share, path));
  } catch (error) {
    logger.error('sharePage', { path, error });
    res.set('Cache-Control', 'no-store');
    res.status(500).send(renderSharePage(NOT_FOUND_PAGE, share, path));
  }
});

/** Lote de escrita do Firestore: no máximo 500 operações. */
const BATCH_LIMIT = 400;

/** Apaga os docs que existirem entre as referências (lidas em blocos). */
async function deleteExisting(db: Firestore, refs: DocumentReference[]): Promise<number> {
  let deleted = 0;
  for (let i = 0; i < refs.length; i += BATCH_LIMIT) {
    const chunk = refs.slice(i, i + BATCH_LIMIT);
    const snaps = await db.getAll(...chunk);
    const batch = db.batch();
    let pending = 0;
    for (const snap of snaps) {
      if (!snap.exists) continue;
      batch.delete(snap.ref);
      pending++;
    }
    if (pending > 0) await batch.commit();
    deleted += pending;
  }
  return deleted;
}

/**
 * Conta excluída no app (Firebase Auth): apaga o perfil, a foto, os pedidos e
 * os votos; o atleta vinculado fica no elenco sem a conta, e o time do dono
 * fica sem dono. Contagens de votações já encerradas (`quantidadeVotos`) ficam,
 * como diz a política de privacidade. Gatilho do Auth só existe na v1.
 */
export const onUserDeleted = functionsV1
  .region('us-central1')
  .auth.user()
  .onDelete(async (user) => {
    const uid = user.uid;
    const { db, storage, FieldValue } = await admin();

    // Perfil: doc pelo uid e contas antigas com id de doc diferente (idUsuario).
    const profiles = await db.collection('usuarios').where('idUsuario', '==', uid).get();
    const profileRefs = [db.collection('usuarios').doc(uid), ...profiles.docs.map((doc) => doc.ref)];
    const profileSnaps = await db.getAll(...profileRefs);
    const bucket = storage.bucket();
    for (const snap of profileSnaps) {
      const path = userPhotoPath(snap.get('urlImagem'), bucket.name);
      if (!path) continue;
      try {
        await bucket.file(path).delete({ ignoreNotFound: true });
      } catch (error) {
        logger.error('Falha ao apagar a foto da conta', { uid, path, error });
      }
    }
    const profilesDeleted = await deleteExisting(db, profileRefs);

    const requestsDeleted = await deleteExisting(db, [
      db.collection('solicitacoes_jogador').doc(uid),
      db.collection('solicitacoes_time').doc(uid),
    ]);

    // Conquistas: contadores e desbloqueios da conta.
    await db.recursiveDelete(db.collection('usuarios').doc(uid).collection('progresso'));
    await db.recursiveDelete(db.collection('usuarios').doc(uid).collection('conquistas'));

    // Votos de cada temporada (partidas{ano}/{id}/votos/{uid}) e vínculos de atleta e dono.
    const seasons = seasonsToSweep((await db.doc('config/temporadas').get()).data());
    let votesDeleted = 0;
    let playersUnlinked = 0;
    let teamsUnlinked = 0;
    for (const season of seasons) {
      const { matches, players, teams } = seasonCollections(season);
      const matchRefs = await db.collection(matches).listDocuments();
      votesDeleted += await deleteExisting(db, matchRefs.map((ref) => ref.collection('votos').doc(uid)));

      const linkedPlayers = await db.collection(players).where('idUsuario', '==', uid).get();
      for (const doc of linkedPlayers.docs) await doc.ref.update({ idUsuario: FieldValue.delete() });
      playersUnlinked += linkedPlayers.size;

      for (const collection of teams) {
        const ownedTeams = await db.collection(collection).where('idDono', '==', uid).get();
        for (const doc of ownedTeams.docs) await doc.ref.update({ idDono: FieldValue.delete() });
        teamsUnlinked += ownedTeams.size;
      }
    }

    // Votos antigos, sem temporada.
    const legacy = (await db.listCollections()).filter((col) => isLegacyVoteCollection(col.id));
    votesDeleted += await deleteExisting(db, legacy.map((col) => col.doc(uid)));

    logger.info('Conta excluída: dados apagados', {
      uid,
      seasons,
      profilesDeleted,
      requestsDeleted,
      votesDeleted,
      playersUnlinked,
      teamsUnlinked,
    });
  });

// ---------------------------------------------------------------------------
// Conquistas: contadores do servidor e desbloqueio (lógica em achievements.ts)
// ---------------------------------------------------------------------------

/** Doc de contadores do usuário (`usuarios/{uid}/progresso/contadores`). */
async function progressRef(uid: string): Promise<DocumentReference> {
  const { db } = await admin();
  return db.collection('usuarios').doc(uid).collection('progresso').doc('contadores');
}

/** Voto novo de melhor jogador (trocar o voto não conta de novo). */
export const onVoteCreated = onDocumentCreated('{colecao}/{matchId}/votos/{uid}', async (event) => {
  if (!/^partidas(\d{4})?$/.test(event.params.colecao)) return;
  const { FieldValue } = await admin();
  await (await progressRef(event.params.uid)).set({ votos: FieldValue.increment(1) }, { merge: true });
});

/** Perfil: escolheu o time do coração / pôs foto (grava só quando muda). */
export const onUserProfileWritten = onDocumentWritten('usuarios/{uid}', async (event) => {
  const after = event.data?.after.data();
  if (!after) return;
  const ref = await progressRef(event.params.uid);
  const changes = changedFields((await ref.get()).data(), profileCounters(after));
  if (Object.keys(changes).length) await ref.set(changes, { merge: true });
});

/** Atleta ligado à conta (jogadores da temporada atual): atleta, gols e assistências do Geral. */
export const onPlayerWritten = onDocumentWritten('{colecao}/{playerId}', async (event) => {
  const collection = event.params.colecao;
  if (!/^jogadores(\d{4})?$/.test(collection)) return;
  if (collection !== seasonCollection('jogadores', await currentSeason())) return;
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  const beforeUid = typeof before?.idUsuario === 'string' ? before.idUsuario : '';
  const afterUid = typeof after?.idUsuario === 'string' ? after.idUsuario : '';
  const relevant =
    beforeUid !== afterUid || before?.nGols !== after?.nGols || before?.nAssistencias !== after?.nAssistencias;
  if (!relevant) return;
  if (afterUid) await (await progressRef(afterUid)).set(athleteCounters(after), { merge: true });
  // A conta deixou de ser este atleta: volta a zero (as medalhas ganhas ficam).
  if (beforeUid && beforeUid !== afterUid) {
    await (await progressRef(beforeUid)).set(athleteCounters(undefined), { merge: true });
  }
});

let achievementCatalogCache: { list: Achievement[]; at: number } | undefined;

/** Catálogo de conquistas em cache na memória da instância (10 min). */
async function achievementCatalog(): Promise<Achievement[]> {
  if (achievementCatalogCache && Date.now() - achievementCatalogCache.at < 10 * 60_000) {
    return achievementCatalogCache.list;
  }
  const { db } = await admin();
  const snapshot = await db.collection('conquistas').get();
  const list = snapshot.docs.map((doc) => achievementFromDoc(doc.id, doc.data()));
  achievementCatalogCache = { list, at: Date.now() };
  return list;
}

/**
 * Contadores mudaram: desbloqueia o que foi atingido (com data e push). Conta
 * antiga sem os campos do servidor: preenche antes (uma leitura de cada) e o
 * novo gatilho avalia. Primeira avaliação: entra como vista e sem push.
 */
export const onProgressWritten = onDocumentWritten('usuarios/{uid}/progresso/contadores', async (event) => {
  const after = event.data?.after.data();
  if (!after) return;
  const before = event.data?.before.data();
  const uid = event.params.uid;
  const { db, FieldValue } = await admin();
  const ref = await progressRef(uid);

  const missing = missingServerFields(after);
  const fill: Record<string, number> = {};
  if (missing.profile) Object.assign(fill, profileCounters((await db.collection('usuarios').doc(uid).get()).data()));
  if (missing.athlete) {
    const players = db.collection(seasonCollection('jogadores', await currentSeason()));
    const found = await players.where('idUsuario', '==', uid).limit(1).get();
    Object.assign(fill, athleteCounters(found.docs[0]?.data()));
  }
  if (missing.owner) {
    const request = (await db.collection('solicitacoes_time').doc(uid).get()).data();
    fill.donoTime = request?.status === 'aprovada' ? 1 : 0;
  }
  if (Object.keys(fill).length) {
    await ref.set(fill, { merge: true });
    return;
  }

  const first = isFirstEvaluation(after);
  if (!first && !countersChanged(before, after)) return;
  const unlocks = newUnlocks(await achievementCatalog(), after);
  if (!unlocks.length) {
    if (first) await ref.set({ [UNLOCKED_FIELD]: [] }, { merge: true });
    return;
  }
  const batch = db.batch();
  for (const achievement of unlocks) {
    batch.set(db.collection('usuarios').doc(uid).collection('conquistas').doc(achievement.id), {
      em: FieldValue.serverTimestamp(),
      vista: first,
    });
  }
  batch.set(ref, { [UNLOCKED_FIELD]: FieldValue.arrayUnion(...unlocks.map((a) => a.id)) }, { merge: true });
  await batch.commit();
  if (first) return;
  for (const achievement of unlocks) {
    await deliver(
      `conquista_${uid}_${achievement.id}`,
      achievementMessage(uid, achievement),
      `usuarios/${uid}/conquistas/${achievement.id}`,
    );
  }
});
