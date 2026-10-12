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
import type { FieldValue as FieldValueType, Firestore } from 'firebase-admin/firestore';
import type { Messaging } from 'firebase-admin/messaging';
import { logger, setGlobalOptions } from 'firebase-functions/v2';
import { onDocumentCreated, onDocumentUpdated, onDocumentWritten } from 'firebase-functions/v2/firestore';
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

setGlobalOptions({ region: 'us-central1', maxInstances: 5 });

interface AdminServices {
  db: Firestore;
  messaging: Messaging;
  FieldValue: typeof FieldValueType;
}

let services: Promise<AdminServices> | undefined;

async function loadAdmin(): Promise<AdminServices> {
  const { initializeApp } = await import('firebase-admin/app');
  const { getFirestore, FieldValue } = await import('firebase-admin/firestore');
  const { getMessaging } = await import('firebase-admin/messaging');
  initializeApp();
  return { db: getFirestore(), messaging: getMessaging(), FieldValue };
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
      notification: { title: message.titulo, body: message.corpo },
      data: { tipo: message.tipo, aba: message.aba },
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
});

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
  const toAdmins = playerRequestMessage(uid, before, after);
  if (toAdmins) await deliver(`solicitacao_${event.id}`, toAdmins, origem);
  const toUser = playerRequestAnswerMessage(uid, before, after);
  if (toUser) await deliver(`resposta_${event.id}`, toUser, origem);

  // Dono do time do pedido (se o time tiver dono aprovado).
  const team = typeof after?.time === 'string' ? after.time : '';
  if (toAdmins && team) {
    const { db } = await admin();
    const owners = await db
      .collection('solicitacoes_time')
      .where('nome', '==', team)
      .where('status', '==', 'aprovada')
      .limit(1)
      .get();
    const owner = owners.docs[0]?.id;
    const toOwner = owner ? playerRequestToOwnerMessage(owner, before, after) : null;
    if (toOwner) await deliver(`dono_${event.id}`, toOwner, origem);
  }
});

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
