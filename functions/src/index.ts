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
import {
  albumOf,
  albumPackMessage,
  applyPack,
  packKind,
  dateOf,
  drawPack,
  nextPackAt,
  parsePackId,
  perPackOf,
  tradeConfig,
  tradeRefusal,
  applyTrade,
  nextTradeDay,
  rankingEntry,
  stickerOf,
  stickerPhotoUpdate,
} from './album';
import {
  addExtraPack,
  extraPacksOf,
  firstName,
  referralDecision,
  referralEnabled,
  referralJustEnabled,
  referralMessage,
  referralReady,
  referralSettled,
} from './referrals';
import {
  BATCH_SIZE,
  DONE_FLAG,
  RECOMPRESS_FOLDERS,
  nextFolder,
  outputFormat,
  profileFor,
  progressOf,
  shouldRecompress,
  shouldRunBatch,
  worthReplacing,
} from './recompress';
import { candidateOf, electBestPlayer, participantNames, rulesOf, voteOf, votingJustClosed } from './best_player';
import type { DocumentReference, FieldValue as FieldValueType, Firestore } from 'firebase-admin/firestore';
import type { Messaging } from 'firebase-admin/messaging';
import type { Storage } from 'firebase-admin/storage';
import * as functionsV1 from 'firebase-functions/v1';
import { logger, setGlobalOptions } from 'firebase-functions/v2';
import { onDocumentCreated, onDocumentDeleted, onDocumentUpdated, onDocumentWritten } from 'firebase-functions/v2/firestore';
import { onRequest } from 'firebase-functions/v2/https';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import {
  PushMessage,
  currentSeasonOf,
  dailyGameMessage,
  forTest,
  isTestDoc,
  describeTarget,
  goalMessage,
  bookingMessage,
  isEnabled,
  manualMessage,
  matchCreatedMessage,
  newsMessage,
  openData,
  playerRequestAnswerMessage,
  playerRequestMessage,
  playerRequestToOwnerMessage,
  organizerRequestAnswerMessage,
  organizerRequestMessage,
  teamRequestAnswerMessage,
  teamRequestMessage,
  partnerLinkRequestMessage,
  pendingNewsAnswerMessage,
  pendingNewsMessage,
  partnerRequestAnswerMessage,
  partnerRequestMessage,
  seasonCollection,
  todayKey,
  votingMessage,
} from './messages';
import { isLegacyVoteCollection, seasonCollections, seasonsToSweep, userPhotoPath } from './account_cleanup';
import { claimReconcilePlan, missingEnrollmentFix, needsClaimReconcile } from './claim_reconcile';
import { FanRankingTeam, fanRankingTotal, rankingTeamOf, sortFanRanking } from './fan_ranking';
import { shouldAutoFinish, shouldCloseVoting } from './voting_close';
import { championChange, championMessage, championNews, championNewsId } from './champion_card';
import {
  type FantasyCardAthlete,
  fantasyRoundMessage,
  fantasyRoundNews,
  fantasyRoundNewsId,
  fantasyTopThree,
} from './fantasy_card';
import { EVENT_VOTES, eventOptionIds, tallyDoc } from './event_poll';
import {
  ResultTeam,
  recentDays,
  resultChanged,
  resultNews,
  resultNewsId,
  shouldPostResult,
  liveCardStatusOf,
  liveCardStatusUpdate,
  liveClockChanged,
  liveClockOf,
  liveNewsId,
  LiveCardStatus,
} from './match_result';
import { shouldPostVoteCard, voteCardBestPlayerFields, voteCardNews, voteNewsId } from './vote_card';
import { rankingDelta, rankingDocId, rulesToDoc, scorePrediction } from './predictions';
import {
  GroupTeam,
  computeTable,
  criteriaOf,
  groupChampionshipId,
  groupGames,
  stageChanged,
  groupHasAny,
  groupTeams,
  isFinishedMatch,
  legacyStandingFields,
  matchTeams,
} from './standings';
import {
  achievementPackReward,
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
  invitePageData,
  newsPageData,
  parseSharePath,
  renderSharePage,
  ALBUM_PAGE,
  POOL_PAGE,
  matchPageData,
  votePageData,
  nowPageData,
  fantasyPageData,
} from './share_page';
import {
  FANTASY,
  FANTASY_LINEUPS,
  FANTASY_PARTICIPANTS,
  FANTASY_ROUNDS,
  type RoundAction,
  type RoundState,
  currentRound,
  fantasyChampions,
  fantasyRounds,
  frozenParams,
  scoringParamsOf,
  lineupCopy,
  fantasyFormation,
  matchdayOf,
  nextOpenRound,
  previousClosedRound,
  orphanRoundUpdate,
  rescoreRequested,
  lineupWithoutAthletes,
  staleAthleteDocs,
  teamsResetRequested,
  roundActionRequested,
  roundFinalized,
  resetRequested,
  roundFieldsChanged,
  roundSync,
} from './fantasy';
import {
  SCORING_VERSION,
  lineupPoints,
  playedAthletes,
  pointsDelta,
  roundParticipants,
  scoreAthlete,
  scoringFieldsChanged,
} from './fantasy_scoring';

setGlobalOptions({ region: 'us-central1', maxInstances: 5 });

/** Texto aparado ('' para nulo/indefinido). */
const text = (value: unknown): string => (value === undefined || value === null ? '' : String(value).trim());

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
      data: {
        tipo: message.tipo,
        aba: message.aba,
        ...openData(message.abrir),
        ...(message.imagem ? { imagem: message.imagem } : {}),
      },
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
  const message =
    data.tag === 'gol'
      ? goalMessage(data, await currentSeason())
      : data.tag === 'cartao'
        ? bookingMessage(data, await currentSeason())
        : newsMessage(data, event.params.newsId);
  if (message) {
    await deliver(`${message.tipo}_${event.id}`, forTest(message, isTestDoc(data)), `noticias/${event.params.newsId}`);
  }
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

/** Grupo da temporada atual (`grupos{ano}`): a tabela dele é recalculada ao mudar. */
async function isCurrentGroupCollection(collection: string): Promise<boolean> {
  if (!/^grupos(\d{4})?$/.test(collection)) return false;
  return collection === seasonCollection('grupos', await currentSeason());
}

/** Partida cadastrada na temporada atual (ou grupo criado: calcula a tabela). */
export const onMatchCreated = onDocumentCreated('{colecao}/{matchId}', async (event) => {
  if (await isCurrentGroupCollection(event.params.colecao)) {
    await onGroupChanged(event.params.matchId, undefined, event.data?.data());
    return;
  }
  if (!(await isCurrentMatchCollection(event.params.colecao))) return;
  const data = event.data?.data();
  // Arena Fantasy: partida com rodada entra nas rodadas do campeonato.
  if (data && matchdayOf(data.rodada) !== null) await syncFantasyForMatches(data);
  const message = data ? matchCreatedMessage(data, { id: event.params.matchId, season: await currentSeason() }) : null;
  if (message) {
    await deliver(`partida_${event.id}`, forTest(message, isTestDoc(data)), `${event.params.colecao}/${event.params.matchId}`);
  }
});

/** Votação de melhor jogador aberta/encerrada. */
export const onMatchUpdated = onDocumentUpdated('{colecao}/{matchId}', async (event) => {
  if (await isCurrentGroupCollection(event.params.colecao)) {
    await onGroupChanged(event.params.matchId, event.data?.before.data(), event.data?.after.data());
    return;
  }
  if (!(await isCurrentMatchCollection(event.params.colecao))) return;
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  const message =
    before && after ? votingMessage(before, after, { id: event.params.matchId, season: await currentSeason() }) : null;
  if (message) {
    await deliver(
      `${message.tipo}_${event.id}`,
      forTest(message, isTestDoc(after)),
      `${event.params.colecao}/${event.params.matchId}`,
    );
  }
  if (!before || !after) return;
  // Arena Fantasy: rodada, data, horário ou início mudou → as rodadas acompanham.
  if (roundFieldsChanged(before, after)) await syncFantasyForMatches(before, after);
  // Arena Fantasy: partida terminou, deixou de estar terminada ou a súmula
  // terminada mudou → a rodada é apurada de novo (do zero, idempotente).
  if (
    (isFinishedMatch(before) || isFinishedMatch(after)) &&
    (isFinishedMatch(before) !== isFinishedMatch(after) || scoringFieldsChanged(before, after))
  ) {
    await scoreFantasyForMatches(before, after);
  }
  const { colecao, matchId } = event.params;
  const justFinished = before.status !== 'encerrada' && after.status === 'encerrada';
  // Card "Vote no craque": encerrada na mão antes dos 15 min finais → posta agora.
  if (justFinished && shouldPostVoteCard(after, await currentSeason())) {
    await postVoteCard(colecao, await currentSeason(), matchId, after);
  }
  // Votação fechou: apura e grava o craque da partida (troféu no perfil do atleta).
  if (votingJustClosed(before, after)) await recordBestPlayer(colecao, await currentSeason(), matchId);
  // Votação abriu/fechou: o card de votação acompanha ("Votar agora" / "Ver resultado").
  if (after.votacaoNoticia && before.votacao !== after.votacao) {
    const { db } = await admin();
    await db
      .collection('noticias')
      .doc(String(after.votacaoNoticia))
      .update({ votacao: String(after.votacao) === 'true' ? 'true' : 'false' })
      .catch((error) => logger.warn('Card de votação não atualizado', { matchId, error: String(error) }));
  }
  // Card ao vivo: intervalo / 2º tempo acompanham (o fim é marcado no postResult).
  const liveStatus = before.status !== after.status ? liveCardStatusOf(after.status) : null;
  if (liveStatus && liveStatus !== 'encerrada') {
    await syncLiveCardStatus(matchId, liveStatus, after);
  } else if (liveClockChanged(before, after)) {
    // Só o relógio mudou (início manual, atrasou, duração): o minuto do card acompanha.
    const { db } = await admin();
    await db
      .collection('noticias')
      .doc(liveNewsId(matchId))
      .update({ relogio: liveClockOf(after) })
      .catch(() => undefined);
  }
  // Card de resultado: o admin encerrou agora → posta; placar corrigido → atualiza.
  if (justFinished && !after.resultadoNoticia) {
    await postResult(colecao, await currentSeason(), matchId, after);
  } else if (after.resultadoNoticia && resultChanged(before, after)) {
    await updateResult(await currentSeason(), matchId, after);
  } else if (isFinishedMatch(after) && stageChanged(before, after)) {
    // Partida terminada trocada de grupo/fase: as tabelas acompanham.
    await recomputeMatchGroups(await currentSeason(), after);
  }
});

/**
 * Craque da partida: lê os votos e as regras, acha o atleta eleito e grava
 * `craque` na partida (sem eleito, apaga). Reabrir e fechar de novo refaz.
 */
async function recordBestPlayer(collection: string, season: string, matchId: string) {
  try {
    const { db, FieldValue } = await admin();
    const matchRef = db.collection(collection).doc(matchId);
    const [votesSnap, config, matchSnap] = await Promise.all([
      matchRef.collection('votos').get(),
      db.doc('config/votacao').get(),
      matchRef.get(),
    ]);
    const votes = votesSnap.docs.map((doc) => voteOf(doc.id, doc.data()));
    // Só os atletas votados (o voto grava o nome como no cadastro): até 30 por consulta.
    const names = [...new Set(votes.map((v) => v.name).filter((n) => n.trim()))];
    const candidates = [];
    for (let i = 0; i < names.length; i += 30) {
      const players = await db
        .collection(seasonCollection('jogadores', season))
        .where('nome', 'in', names.slice(i, i + 30))
        .get();
      candidates.push(...players.docs.map((doc) => candidateOf(doc.id, doc.data())));
    }
    // Só quem participou da partida (súmula) pode ser o craque.
    const best = electBestPlayer(votes, candidates, rulesOf(config.data()), participantNames(matchSnap.data() ?? {}));
    await matchRef.update({ craque: best ?? FieldValue.delete() });
    // O card "Vote no craque" mostra o eleito (ou "sem craque eleito").
    const fields = voteCardBestPlayerFields(best, matchSnap.data() ?? {});
    const update = Object.fromEntries(
      Object.entries(fields).map(([k, v]) => [k, v === null ? FieldValue.delete() : v]),
    );
    const cardRef = db.collection('noticias').doc(voteNewsId(matchId));
    if ((await cardRef.get()).exists) await cardRef.update(update);
  } catch (error) {
    logger.error('Falha ao apurar o craque', { collection, matchId, error: String(error) });
  }
}

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
  // O card ao vivo deixa de dizer "ao vivo" (fim pelo admin, pelo horário ou automático).
  await syncLiveCardStatus(matchId, 'encerrada', match);
  await scorePredictions(collection, season, matchId, match);
  await recomputeMatchGroups(season, { ...match, resultadoNoticia: ref.id });
}

/** Marca a fase no card ao vivo da partida (sem card ao vivo, nada a fazer). */
async function syncLiveCardStatus(matchId: string, status: LiveCardStatus, match: Record<string, unknown>) {
  const { db } = await admin();
  await db
    .collection('noticias')
    .doc(liveNewsId(matchId))
    .update(liveCardStatusUpdate(status, match))
    .catch((error) => logger.info('Card ao vivo não atualizado', { matchId, status, error: String(error) }));
}

/**
 * Bolão: pontua os palpites da partida que acabou (ou cujo placar mudou) e
 * soma no ranking da região só a diferença do que já tinha sido contado;
 * também conta nas conquistas (palpites e placares exatos).
 */
async function scorePredictions(collection: string, season: string, matchId: string, match: Record<string, unknown>) {
  const { db, FieldValue } = await admin();
  const predictions = await db.collection(collection).doc(matchId).collection('palpites').get();
  if (predictions.empty) return;
  const regionId = typeof match.idRegiao === 'string' ? match.idRegiao.trim() : '';
  const ranking = db.collection(seasonCollection('palpites_ranking', season));
  // Regras atuais do bolão (o palpite já pontuado segue com as dele, `regras`).
  const currentRules = (await db.collection('config').doc('bolao').get()).data() ?? {};
  let batch = db.batch();
  let pending = 0;
  for (const doc of predictions.docs) {
    const data = doc.data();
    const score = scorePrediction(data, match, season, currentRules);
    const delta = rankingDelta(data, score);
    if (!delta) continue;
    batch.update(doc.ref, {
      pontos: score.points,
      exato: score.exact,
      valido: score.valid,
      ...(data.regras ? {} : { regras: rulesToDoc(score.rules) }),
    });
    if (delta.points || delta.exact || delta.counted) {
      if (regionId) {
        batch.set(
          ranking.doc(rankingDocId(regionId, doc.id)),
          {
            uid: doc.id,
            nome: String(data.nome ?? ''),
            idRegiao: regionId,
            pontos: FieldValue.increment(delta.points),
            exatos: FieldValue.increment(delta.exact),
            palpites: FieldValue.increment(delta.counted),
          },
          { merge: true },
        );
      }
      // Conquistas: palpites válidos e placares exatos.
      batch.set(
        await progressRef(doc.id),
        { palpites: FieldValue.increment(delta.counted), palpitesExatos: FieldValue.increment(delta.exact) },
        { merge: true },
      );
    }
    if (++pending >= 150) {
      await batch.commit();
      batch = db.batch();
      pending = 0;
    }
  }
  if (pending > 0) await batch.commit();
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
  // Placar corrigido: o bolão é repontuado (só a diferença vai ao ranking).
  await scorePredictions(seasonCollection('partidas', season), season, matchId, match);
  await recomputeMatchGroups(season, match);
}

/**
 * Classificação automática: refaz do zero a tabela dos grupos do campeonato
 * (`tabelas{ano}/{idGrupo}`) a partir das partidas terminadas entre os times
 * do grupo, com o desempate do campeonato, e espelha os números nas linhas
 * antigas de `classificacao{ano}` (app antigo). [teams] = só os grupos com
 * algum desses times; [groupId] = só esse grupo.
 */
async function recomputeGroups(
  season: string,
  championshipId: number,
  options: { teams?: GroupTeam[]; groupId?: string } = {},
): Promise<void> {
  if (!(championshipId > 0)) return;
  try {
    const { db, FieldValue } = await admin();
    const groupDocs = (
      await db.collection(seasonCollection('grupos', season)).where('fk_campeonato', '==', championshipId).get()
    ).docs.filter(
      (doc) =>
        (!options.groupId || doc.id === options.groupId) &&
        (!options.teams || groupHasAny(groupTeams(doc.data()), options.teams)),
    );
    if (!groupDocs.length) return;
    const [matches, championship] = await Promise.all([
      db.collection(seasonCollection('partidas', season)).where('id_campeonato', '==', championshipId).get(),
      db.collection('campeonatos').where('id_campeonato', '==', championshipId).limit(1).get(),
    ]);
    const criteria = criteriaOf(championship.docs[0]?.data().desempate);
    const matchData = matches.docs.map((doc) => doc.data());
    const standings = db.collection(seasonCollection('classificacao', season));
    const batch = db.batch();
    for (const doc of groupDocs) {
      const group = doc.data();
      const teams = groupTeams(group);
      const rows = computeTable(teams, groupGames(teams, matchData, championshipId, doc.id), criteria);
      const groupName = String(group.descricao ?? '').trim();
      batch.set(db.collection(seasonCollection('tabelas', season)).doc(doc.id), {
        idCampeonato: championshipId,
        grupo: groupName,
        idRegiao: String(group.idRegiao ?? ''),
        criterios: criteria,
        linhas: rows,
        atualizadoEm: FieldValue.serverTimestamp(),
      });
      // Espelho: só nas linhas que existem (o update falharia o lote todo).
      const refs = rows.filter((row) => row.idTime).map((row) => standings.doc(row.idTime));
      const existing = refs.length ? await db.getAll(...refs) : [];
      for (const snapshot of existing) {
        const row = rows.find((r) => r.idTime === snapshot.id);
        if (snapshot.exists && row) batch.update(snapshot.ref, legacyStandingFields(row, groupName));
      }
    }
    await batch.commit();
    logger.info('Tabelas recalculadas', { championshipId, groups: groupDocs.map((doc) => doc.id) });
  } catch (error) {
    logger.error('Tabelas não recalculadas', { championshipId, error: String(error) });
  }
}

/** Partida terminada (placar corrigido ou apagada): recalcula os grupos dos dois times. */
async function recomputeMatchGroups(season: string, match: Record<string, unknown>): Promise<void> {
  await recomputeGroups(season, Number(match.id_campeonato) || 0, { teams: matchTeams(match) });
}

/** Grupo editado no console: recalcula com os times novos; fora do campeonato, apaga a tabela. */
async function onGroupChanged(groupId: string, before?: Record<string, unknown>, after?: Record<string, unknown>) {
  const season = await currentSeason();
  const previous = before ? groupChampionshipId(before) : 0;
  const next = after ? groupChampionshipId(after) : 0;
  if (next > 0) {
    await recomputeGroups(season, next, { groupId });
  } else if (previous > 0) {
    const { db } = await admin();
    await db.collection(seasonCollection('tabelas', season)).doc(groupId).delete();
  }
}

/** Partida terminada apagada → recalcula; grupo apagado → apaga a tabela dele. */
export const onMatchOrGroupDeleted = onDocumentDeleted('{colecao}/{docId}', async (event) => {
  const { colecao, docId } = event.params;
  const data = event.data?.data();
  if (await isCurrentGroupCollection(colecao)) {
    await onGroupChanged(docId, data, undefined);
    return;
  }
  if (!data || !(await isCurrentMatchCollection(colecao))) return;
  if (matchdayOf(data.rodada) !== null) await syncFantasyForMatches(data);
  if (!isFinishedMatch(data)) return;
  if (matchdayOf(data.rodada) !== null) await scoreFantasyForMatches(data);
  await recomputeMatchGroups(await currentSeason(), data);
});

/** Desempate trocado ou "Recalcular tabelas" (`recalcularEm`) no campeonato. */
export const onChampionshipUpdated = onDocumentUpdated('campeonatos/{id}', async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after) return;
  await syncChampionCard(event.params.id, before, after, event.id);
  await syncFantasyChampion(event.params.id, before, after).catch((error) =>
    logger.error('Fantasy: campeão não gravado', { id: event.params.id, error: String(error) }),
  );
  const changed =
    JSON.stringify(before.desempate ?? null) !== JSON.stringify(after.desempate ?? null) ||
    String(before.recalcularEm?.toMillis?.() ?? '') !== String(after.recalcularEm?.toMillis?.() ?? '');
  if (!changed) return;
  await recomputeGroups(await currentSeason(), Number(after.id_campeonato) || 0);
});

/**
 * Competição encerrada com campeão: posta (ou regrava) o card de campeão e
 * avisa a região e a torcida; reaberta: o card fica oculto.
 */
async function syncChampionCard(docId: string, before: Record<string, unknown>, after: Record<string, unknown>, eventId: string) {
  const change = championChange(before, after);
  if (!change) return;
  const { db, FieldValue } = await admin();
  const ref = db.collection('noticias').doc(championNewsId(docId));
  if (change === 'reopened') {
    const current = await ref.get();
    if (current.exists) await ref.update({ exibir: 'false' });
    return;
  }
  const news = championNews(docId, after);
  if (!news) return;
  await ref.set({ ...news, data: FieldValue.serverTimestamp() });
  logger.info('Card de campeão postado', { campeonato: docId });
  const message = championMessage(after);
  if (message) await deliver(`campeao_${eventId}`, message, `campeonatos/${docId}`);
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

/** Pedido "Sou organizador de campeonato": avisa os admins (novo) e quem pediu (resposta). */
export const onOrganizerRequestWritten = onDocumentWritten('solicitacoes_organizador/{uid}', async (event) => {
  const uid = event.params.uid;
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  const origem = `solicitacoes_organizador/${uid}`;
  const toAdmins = organizerRequestMessage(uid, before, after);
  if (toAdmins) await deliver(`pedido_organizador_${event.id}`, toAdmins, origem);
  const toUser = organizerRequestAnswerMessage(uid, before, after);
  if (toUser) await deliver(`resposta_organizador_${event.id}`, toUser, origem);
});

/** Pedido "Sou parceiro": avisa os admins (novo) e quem pediu (resposta). */
export const onPartnerRequestWritten = onDocumentWritten('solicitacoes_parceiro/{uid}', async (event) => {
  const uid = event.params.uid;
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  const origem = `solicitacoes_parceiro/${uid}`;
  const toAdmins = partnerRequestMessage(uid, before, after);
  if (toAdmins) await deliver(`pedido_parceiro_${event.id}`, toAdmins, origem);
  const toUser = partnerRequestAnswerMessage(uid, before, after);
  if (toUser) await deliver(`resposta_parceiro_${event.id}`, toUser, origem);
  const link = partnerLinkRequestMessage(uid, before, after);
  if (link) await deliver(`vinculo_parceiro_${event.id}`, link, origem);
});

/** Notícia de parceiro além do limite do dia: avisa os admins e, respondida, o parceiro. */
export const onPendingNewsWritten = onDocumentWritten('noticias_pendentes/{id}', async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  const origem = `noticias_pendentes/${event.params.id}`;
  const toAdmins = pendingNewsMessage(before, after);
  if (toAdmins) await deliver(`noticia_pendente_${event.id}`, toAdmins, origem);
  const toAuthor = pendingNewsAnswerMessage(before, after);
  if (toAuthor) await deliver(`noticia_pendente_resposta_${event.id}`, toAuthor, origem);
});

/** Todo dia às 9h: lembra os torcedores dos times que jogam hoje (temporada atual). */
export const dailyGames = onSchedule({ schedule: '0 9 * * *', timeZone: 'America/Sao_Paulo' }, async () => {
  const today = todayKey();
  const { db } = await admin();
  const collection = seasonCollection('partidas', await currentSeason());
  const matches = await db.collection(collection).where('data', '==', today).get();
  for (const doc of matches.docs) {
    const message = dailyGameMessage(doc.data(), { id: doc.id, season: await currentSeason() });
    if (message) {
      await deliver(
        `jogo_do_dia_${today.replace('/', '-')}_${doc.id}`,
        forTest(message, isTestDoc(doc.data())),
        `${collection}/${doc.id}`,
      );
    }
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
  // Na mesma rodada: push de quem tem pacotinho liberado (24 h depois do último).
  await notifyAlbumPacks(now);
  // Na mesma rodada: rodadas do Arena Fantasy com o prazo vencido fecham.
  await closeFantasyRounds(now).catch((error) => logger.error('Fantasy: rodadas não fechadas', { error: String(error) }));
});

// ---------------------------------------------------------------------------
// Arena Fantasy (fase 2): rodadas pelas partidas, fechamento e cópia das
// escalações. A lógica fica em fantasy.ts (pura).
// ---------------------------------------------------------------------------

type FantasyDoc = Record<string, unknown>;
type DocRef = FirebaseFirestore.DocumentReference;

const dateOfValue = (value: unknown): Date | null =>
  value instanceof Date ? value : ((value as { toDate?: () => Date } | null)?.toDate?.() ?? null);

/** Rodada gravada (status, prazo e partidas). */
function storedRoundOf(data: FantasyDoc) {
  return {
    status: typeof data.status === 'string' ? data.status : undefined,
    fechaEm: dateOfValue(data.fechaEm),
    idsPartidas: Array.isArray(data.idsPartidas) ? data.idsPartidas.map(String) : [],
    finalizada: data.finalizada === true,
    prazoManual: data.prazoManual === true,
    fechadaManual: data.fechadaManual === true,
  };
}

/** Fantasy ativo do campeonato [championshipId] na temporada [season]. */
async function activeFantasyOf(championshipId: number, season: string) {
  const { db } = await admin();
  const found = await db
    .collection(FANTASY)
    .where('idCampeonato', '==', championshipId)
    .where('temporada', '==', season)
    .where('ativo', '==', true)
    .limit(1)
    .get();
  return found.docs[0];
}

/** Sincroniza as rodadas dos Fantasy ativos das competições das partidas [docs]. */
async function syncFantasyForMatches(...docs: (FantasyDoc | undefined)[]): Promise<void> {
  const season = await currentSeason();
  const ids = new Set(docs.map((d) => Number(d?.id_campeonato ?? 0)).filter((n) => Number.isInteger(n) && n > 0));
  for (const id of ids) {
    try {
      const fantasy = await activeFantasyOf(id, season);
      if (fantasy) await syncFantasyRounds(fantasy.ref, fantasy.data(), season);
    } catch (error) {
      logger.error('Fantasy: rodadas não sincronizadas', { championshipId: id, error: String(error) });
    }
  }
}

/**
 * Rodadas do Fantasy [fantasyRef] a partir das partidas da competição: cria
 * as novas (abertas, com o prazo), atualiza prazo/partidas das abertas, só as
 * partidas das fechadas; rodada aberta sem partidas fica `vazia`. Grava a
 * `rodadaAtual` e copia as escalações para a rodada nova (D3).
 */
async function syncFantasyRounds(fantasyRef: DocRef, config: FantasyDoc, season: string): Promise<void> {
  const { db, FieldValue } = await admin();
  const championshipId = Number(config.idCampeonato ?? 0);
  if (!Number.isInteger(championshipId) || championshipId <= 0) return;
  const matches = await db
    .collection(seasonCollection('partidas', season))
    .where('id_campeonato', '==', championshipId)
    .get();
  const computed = fantasyRounds(matches.docs.map((d) => ({ id: d.id, data: d.data() })), season);
  const roundsRef = fantasyRef.collection(FANTASY_ROUNDS);
  const existing = await roundsRef.get();
  const stored = new Map(existing.docs.map((d) => [d.id, storedRoundOf(d.data())]));
  const batch = db.batch();
  let writes = 0;
  const created: number[] = [];
  const after = new Map<number, RoundState>();
  for (const [id, round] of stored) after.set(Number(id), { numero: Number(id), ...round });
  for (const round of computed) {
    const key = String(round.numero);
    const change = roundSync(stored.get(key), round);
    if (!change) continue;
    // Fechada que reabriu sozinha: sai dos parâmetros congelados.
    const reopened = stored.get(key)?.status === 'fechada' && change.status === 'aberta';
    batch.set(
      roundsRef.doc(key),
      reopened ? { ...change, parametros: FieldValue.delete(), fechadaEm: FieldValue.delete() } : change,
      { merge: true },
    );
    writes++;
    if (!stored.has(key) || stored.get(key)?.status === 'vazia') created.push(round.numero);
    const previous = after.get(round.numero);
    after.set(round.numero, {
      ...previous,
      numero: round.numero,
      status: typeof change.status === 'string' ? change.status : previous?.status,
      fechaEm: change.fechaEm instanceof Date ? change.fechaEm : (previous?.fechaEm ?? null),
      idsPartidas: round.idsPartidas,
    });
  }
  const computedIds = new Set(computed.map((r) => r.numero));
  // Rodada que ficou sem partidas (apagadas): aberta vira vazia; fechada fica
  // finalizada e sem partidas (não segura o mercado como "em andamento").
  for (const [id, round] of stored) {
    if (computedIds.has(Number(id))) continue;
    const change = orphanRoundUpdate(round);
    if (!change) continue;
    batch.update(roundsRef.doc(id), change);
    after.set(Number(id), { numero: Number(id), ...round, ...(change as Partial<RoundState>), fechaEm: round.fechaEm });
    writes++;
  }
  const now = new Date();
  const current = currentRound([...after.values()], now);
  if (current !== Number(config.rodadaAtual ?? 0)) {
    batch.update(fantasyRef, { rodadaAtual: current });
    writes++;
  }
  if (writes) await batch.commit();
  const list = [...after.values()];
  for (const numero of created) {
    const from = previousClosedRound(list, numero);
    if (from !== null) await copyFantasyLineups(fantasyRef, from, numero);
  }
  // Partida iniciada na mão: o prazo venceu agora; fecha na hora (sem esperar o agendamento).
  for (const round of list) {
    if (round.status === 'aberta' && round.fechaEm !== null && round.fechaEm <= now) {
      await closeFantasyRound(fantasyRef, roundsRef.doc(String(round.numero)), now);
    }
  }
}

/** Recalcula a `rodadaAtual` pelas rodadas gravadas (rodada finalizada reabre o mercado). */
async function refreshCurrentRound(fantasyRef: DocRef, now = new Date()): Promise<void> {
  const [config, all] = await Promise.all([fantasyRef.get(), fantasyRef.collection(FANTASY_ROUNDS).get()]);
  const list = all.docs.map((d) => ({ numero: Number(d.id), ...storedRoundOf(d.data()) }));
  const current = currentRound(list, now);
  if (current !== Number(config.data()?.rodadaAtual ?? 0)) await fantasyRef.update({ rodadaAtual: current });
}

/**
 * Copia as escalações da rodada [from] para a [to] de quem ainda não tem
 * escalação nela (D3), no formato atual do campeonato (`vagas`: a [to] está
 * abrindo e usa o formato vigente).
 */
async function copyFantasyLineups(fantasyRef: DocRef, from: number, to: number): Promise<number> {
  const { db, FieldValue } = await admin();
  const rounds = fantasyRef.collection(FANTASY_ROUNDS);
  const [source, target, config] = await Promise.all([
    rounds.doc(String(from)).collection(FANTASY_LINEUPS).get(),
    rounds.doc(String(to)).collection(FANTASY_LINEUPS).get(),
    fantasyRef.get(),
  ]);
  const formation = fantasyFormation(config.data()?.vagas);
  const taken = new Set(target.docs.map((d) => d.id));
  let batch = db.batch();
  let pending = 0;
  let copied = 0;
  for (const doc of source.docs) {
    if (taken.has(doc.id)) continue;
    const copy = lineupCopy(doc.data(), formation);
    if (!copy) continue;
    batch.set(rounds.doc(String(to)).collection(FANTASY_LINEUPS).doc(doc.id), {
      ...copy,
      atualizadoEm: FieldValue.serverTimestamp(),
    });
    pending++;
    copied++;
    if (pending === 400) {
      await batch.commit();
      batch = db.batch();
      pending = 0;
    }
  }
  if (pending) await batch.commit();
  if (copied) logger.info('Fantasy: escalações copiadas', { fantasy: fantasyRef.id, from, to, copied });
  return copied;
}

/**
 * Rodadas abertas com o prazo vencido: fecham com os parâmetros congelados,
 * a `rodadaAtual` avança e as escalações vão para a próxima rodada aberta.
 */
async function closeFantasyRounds(now: Date): Promise<void> {
  const { db } = await admin();
  const due = await db
    .collectionGroup(FANTASY_ROUNDS)
    .where('status', '==', 'aberta')
    .where('fechaEm', '<=', now)
    .limit(50)
    .get();
  for (const round of due.docs) {
    const fantasyRef = round.ref.parent.parent;
    if (!fantasyRef || fantasyRef.parent.id !== FANTASY) continue;
    await closeFantasyRound(fantasyRef, round.ref, now);
  }
}

/** Tabela de pontos padrão do Fantasy (`config/pontuacao_fantasy.tabela`); sem o doc, vazia (= padrões). */
async function fantasyGlobalTable(): Promise<FantasyDoc> {
  const { db } = await admin();
  const table = (await db.collection('config').doc('pontuacao_fantasy').get()).data()?.tabela;
  return table && typeof table === 'object' ? (table as FantasyDoc) : {};
}

/**
 * Fecha a rodada [roundRef] (se ainda aberta): parâmetros congelados, a
 * `rodadaAtual` recalculada (fica nela enquanto estiver em andamento) e as
 * escalações copiadas para a próxima rodada aberta.
 */
async function closeFantasyRound(fantasyRef: DocRef, roundRef: DocRef, now: Date): Promise<void> {
  const { db, FieldValue } = await admin();
  const config = (await fantasyRef.get()).data() ?? {};
  const globalTable = await fantasyGlobalTable();
  const closed = await db.runTransaction(async (tx) => {
    const snap = await tx.get(roundRef);
    if (snap.data()?.status !== 'aberta') return false;
    tx.update(roundRef, {
      status: 'fechada',
      parametros: frozenParams(config, globalTable),
      fechadaEm: FieldValue.serverTimestamp(),
    });
    return true;
  });
  if (!closed) return;
  const all = await fantasyRef.collection(FANTASY_ROUNDS).get();
  const list = all.docs.map((d) => ({
    numero: Number(d.id),
    ...storedRoundOf(d.id === roundRef.id ? { ...d.data(), status: 'fechada' } : d.data()),
  }));
  await fantasyRef.update({ rodadaAtual: currentRound(list, now) });
  const next = nextOpenRound(list, Number(roundRef.id));
  if (next !== null) await copyFantasyLineups(fantasyRef, Number(roundRef.id), next);
  logger.info('Fantasy: rodada fechada', { fantasy: fantasyRef.id, round: roundRef.id });
}

/** Fantasy do campeonato [championshipId] na temporada (ligado ou não: a apuração segue). */
async function fantasyOf(championshipId: number, season: string) {
  const { db } = await admin();
  const found = await db
    .collection(FANTASY)
    .where('idCampeonato', '==', championshipId)
    .where('temporada', '==', season)
    .limit(1)
    .get();
  return found.docs[0];
}

/** Apura as rodadas do Fantasy das partidas [docs] (antes e depois da mudança). */
async function scoreFantasyForMatches(...docs: (FantasyDoc | undefined)[]): Promise<void> {
  const season = await currentSeason();
  const rounds = new Map<number, Set<number>>();
  for (const doc of docs) {
    const championshipId = Number(doc?.id_campeonato ?? 0);
    const round = matchdayOf(doc?.rodada);
    if (!Number.isInteger(championshipId) || championshipId <= 0 || round === null) continue;
    rounds.set(championshipId, (rounds.get(championshipId) ?? new Set()).add(round));
  }
  for (const [championshipId, numbers] of rounds) {
    try {
      const fantasy = await fantasyOf(championshipId, season);
      if (!fantasy) continue;
      for (const round of numbers) await scoreFantasyRound(fantasy.ref, fantasy.data(), round, season);
    } catch (error) {
      logger.error('Fantasy: rodada não apurada', { championshipId, error: String(error) });
    }
  }
}

/**
 * Apuração da rodada [round], sempre do zero: pontos de cada atleta escalado
 * (doc de auditoria em `rodadas/{n}/atletas`), das escalações e, por
 * transação, a diferença no total do participante (`aplicado`): reprocessar
 * não soma duas vezes e a súmula corrigida muda só a diferença.
 */
async function scoreFantasyRound(fantasyRef: DocRef, config: FantasyDoc, round: number, season: string): Promise<void> {
  const { db, FieldValue } = await admin();
  const roundRef = fantasyRef.collection(FANTASY_ROUNDS).doc(String(round));
  const roundSnap = await roundRef.get();
  if (!roundSnap.exists) return;
  const roundData = roundSnap.data() ?? {};
  // Rodada fechada: os parâmetros e a tabela congelados nela; senão, os atuais.
  const frozen = roundData.parametros as FantasyDoc | undefined;
  const params = scoringParamsOf(frozen ? frozenParams(frozen) : frozenParams(config, await fantasyGlobalTable()));
  const matchIds = Array.isArray(roundData.idsPartidas) ? roundData.idsPartidas.map(String) : [];
  const matchesCol = db.collection(seasonCollection('partidas', season));
  const matchDocs = matchIds.length ? await db.getAll(...matchIds.map((id) => matchesCol.doc(id))) : [];
  const finished = matchDocs
    .filter((d) => d.exists && isFinishedMatch(d.data() ?? {}))
    .map((d) => ({ id: d.id, data: d.data() ?? {} }));

  const lineups = await roundRef.collection(FANTASY_LINEUPS).get();
  const drafted = new Set(
    lineups.docs.flatMap((d) => (Array.isArray(d.data().idsAtletas) ? d.data().idsAtletas.map(String) : [])),
  );
  // Também quem jogou e ninguém escalou ("Craques da rodada" no app).
  const athleteIds = [...new Set([...drafted, ...roundParticipants(finished.map((m) => m.data))])].filter(Boolean);
  const playersCol = db.collection(seasonCollection('jogadores', season));
  const players = athleteIds.length ? await db.getAll(...athleteIds.map((id) => playersCol.doc(id))) : [];
  const enrollmentKey = `c${Number(config.idCampeonato ?? 0)}`;
  const totals: Record<string, number> = {};
  const scored = new Set<string>();
  const played = new Set<string>();
  const cardAthletes: FantasyCardAthlete[] = [];
  let batch = db.batch();
  let pending = 0;
  for (const player of players) {
    if (!player.exists && !drafted.has(player.id)) continue;
    const data = player.data() ?? {};
    const enrollment = ((data.inscricoes ?? {}) as Record<string, FantasyDoc>)[enrollmentKey];
    // Não escalado: só quem está inscrito na competição com time (regra do Fantasy).
    if (!drafted.has(player.id) && !text(enrollment?.idTime)) continue;
    const result = scoreAthlete(finished, {
      id: player.id,
      posicao: data.posicao,
      teamId: String(enrollment?.idTime ?? data.idTime ?? ''),
    }, params);
    totals[player.id] = result.total;
    if (result.partidas.length > 0) played.add(player.id);
    cardAthletes.push({
      idJogador: player.id,
      nome: String(data.nome ?? ''),
      time: String(enrollment?.time ?? data.time ?? ''),
      idTime: String(enrollment?.idTime ?? data.idTime ?? ''),
      urlImagem: String(data.urlImagem ?? ''),
      posicao: String(result.posicao ?? ''),
      pontos: result.total,
    });
    scored.add(player.id);
    batch.set(roundRef.collection('atletas').doc(player.id), {
      ...result,
      nome: String(data.nome ?? ''),
      urlImagem: String(data.urlImagem ?? ''),
      idTime: String(enrollment?.idTime ?? data.idTime ?? ''),
      time: String(enrollment?.time ?? data.time ?? ''),
      parametros: params,
      versaoCalculo: SCORING_VERSION,
      processadoEm: FieldValue.serverTimestamp(),
    });
    if (++pending === 400) {
      await batch.commit();
      batch = db.batch();
      pending = 0;
    }
  }
  if (pending) await batch.commit();
  // Auditoria que sobrou (atleta que só estava numa partida apagada/trocada): sai do ranking e dos craques.
  const audit = await roundRef.collection('atletas').get();
  const stale = staleAthleteDocs(audit.docs.map((d) => d.id), scored);
  for (let n = 0; n < stale.length; n += 400) {
    const cleanup = db.batch();
    for (const id of stale.slice(n, n + 400)) cleanup.delete(roundRef.collection('atletas').doc(id));
    await cleanup.commit();
  }

  for (const lineup of lineups.docs) {
    const participantRef = fantasyRef.collection(FANTASY_PARTICIPANTS).doc(lineup.id);
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(lineup.ref);
      const data = snap.data() ?? {};
      const ids = Array.isArray(data.idsAtletas) ? data.idsAtletas.map(String) : [];
      const { pontos, pontosAtletas } = lineupPoints(ids, String(data.capitao ?? ''), totals, params.capitao);
      const delta = pointsDelta(pontos, data.aplicado);
      tx.update(lineup.ref, {
        pontos,
        pontosAtletas,
        atletasJogaram: playedAthletes(ids, played),
        aplicado: pontos,
        processadoEm: FieldValue.serverTimestamp(),
      });
      if (delta !== 0) tx.set(participantRef, { pontos: FieldValue.increment(delta) }, { merge: true });
    });
  }

  await roundRef.update({
    apuracao: {
      partidas: matchIds.length,
      encerradas: finished.length,
      escalacoes: lineups.size,
      versao: SCORING_VERSION,
      processadoEm: FieldValue.serverTimestamp(),
    },
    // Só as partidas que ainda existem (apagada não segura a rodada).
    finalizada: roundFinalized(matchDocs.filter((d) => d.exists).length, finished.length),
  });
  logger.info('Fantasy: rodada apurada', { fantasy: fantasyRef.id, round, finished: finished.length });
  // Rodada finalizada reabre o mercado (a próxima); reaberta, fecha de novo.
  await refreshCurrentRound(fantasyRef).catch((error) =>
    logger.error('Fantasy: rodada atual não recalculada', { fantasy: fantasyRef.id, error: String(error) }),
  );
  const finalized = finished.length > 0 && roundFinalized(matchDocs.filter((d) => d.exists).length, finished.length);
  const hasTest = finished.some((m) => isTestDoc(m.data));
  await syncFantasyRoundCard(fantasyRef.id, config, round, finalized ? fantasyTopThree(cardAthletes) : [], hasTest).catch(
    (error) => logger.error('Fantasy: card da rodada não gravado', { fantasy: fantasyRef.id, round, error: String(error) }),
  );
}

/**
 * Card "Craques da rodada" no feed: rodada finalizada com [top] cria o card
 * (hora do servidor + push) ou regrava os campos mantendo a `data` (súmula
 * corrigida não sobe no feed nem manda push de novo); sem top (não
 * finalizada / ninguém pontuou), o card que existir fica oculto.
 */
async function syncFantasyRoundCard(
  fantasyId: string,
  config: FantasyDoc,
  round: number,
  top: ReturnType<typeof fantasyTopThree>,
  test = false,
) {
  const { db, FieldValue } = await admin();
  const ref = db.collection('noticias').doc(fantasyRoundNewsId(fantasyId, round));
  const current = await ref.get();
  const built = fantasyRoundNews(fantasyId, config, round, top);
  // Rodada com partida de teste: o card é de teste (só o admin vê; push só para os admins).
  const news = built && test ? { ...built, teste: true } : built;
  if (!news) {
    if (current.exists && current.data()?.exibir !== 'false') await ref.update({ exibir: 'false' });
    return;
  }
  if (current.exists) {
    await ref.set(news, { merge: true });
    return;
  }
  await ref.set({ ...news, data: FieldValue.serverTimestamp() });
  logger.info('Card do Fantasy postado', { fantasy: fantasyId, round });
  const message = fantasyRoundMessage(news);
  if (message) await deliver(`fantasy_${fantasyId}_r${round}`, forTest(message, test), `fantasy/${fantasyId}/rodadas/${round}`);
}

/**
 * Competição encerrada: o Fantasy dela (mesmo id do doc) ganha o campeão
 * (maior pontuação; empate = todos). Reaberta: o campeão sai.
 */
async function syncFantasyChampion(championshipDocId: string, before: FantasyDoc, after: FantasyDoc): Promise<void> {
  const closedBefore = before.encerrado === true;
  const closedAfter = after.encerrado === true;
  if (closedBefore === closedAfter) return;
  const { db, FieldValue } = await admin();
  const ref = db.collection(FANTASY).doc(championshipDocId);
  if (!(await ref.get()).exists) return;
  if (!closedAfter) {
    await ref.update({ campeao: FieldValue.delete(), campeaoEm: FieldValue.delete() });
    return;
  }
  const top = await ref.collection(FANTASY_PARTICIPANTS).orderBy('pontos', 'desc').limit(10).get();
  const champions = fantasyChampions(top.docs.map((d) => ({ id: d.id, data: d.data() })));
  await ref.update({ campeao: champions, campeaoEm: FieldValue.serverTimestamp() });
  logger.info('Fantasy: campeão gravado', { fantasy: championshipDocId, champions: champions.length });
}

/**
 * "Fechar agora": fecha a rodada (parâmetros congelados, prazo = agora,
 * escalações copiadas) e marca `fechadaManual` (a sincronia não reabre).
 * "Reabrir": aberta até o prazo do admin (`prazoManual`: a sincronia não
 * troca). Depois, a `rodadaAtual` é recalculada.
 */
async function applyRoundAction(fantasyRef: DocRef, action: RoundAction): Promise<void> {
  const { FieldValue } = await admin();
  const roundRef = fantasyRef.collection(FANTASY_ROUNDS).doc(String(action.numero));
  const snap = await roundRef.get();
  if (!snap.exists) return;
  const now = new Date();
  if (action.acao === 'fechar') {
    if (snap.data()?.status === 'aberta') {
      await roundRef.update({ fechaEm: now, prazoManual: FieldValue.delete() });
      await closeFantasyRound(fantasyRef, roundRef, now);
    }
    await roundRef.update({ fechadaManual: true });
  } else {
    if (!action.prazo || action.prazo <= now) return;
    await roundRef.update({
      status: 'aberta',
      fechaEm: action.prazo,
      prazoManual: true,
      fechadaManual: FieldValue.delete(),
      parametros: FieldValue.delete(),
      fechadaEm: FieldValue.delete(),
      finalizada: FieldValue.delete(),
    });
  }
  await refreshCurrentRound(fantasyRef, now);
  logger.info('Fantasy: rodada mudada pelo admin', { fantasy: fantasyRef.id, round: action.numero, action: action.acao });
}

/**
 * "Zerar pontos de times": em cada rodada, apaga a auditoria dos atletas dos
 * times [teamIds], tira os pontos deles das escalações (a diferença vai para o
 * participante pelo `aplicado`, idempotente) e refaz o card "Craques da
 * rodada" com quem sobrou (vazio = oculto). Sem push.
 */
async function resetFantasyTeams(fantasyRef: DocRef, config: FantasyDoc, teamIds: string[]): Promise<void> {
  const { db, FieldValue } = await admin();
  const teams = new Set(teamIds);
  const rounds = await fantasyRef.collection(FANTASY_ROUNDS).get();
  let athletesRemoved = 0;
  for (const round of rounds.docs) {
    const audit = await round.ref.collection('atletas').get();
    const removed = new Set(audit.docs.filter((d) => teams.has(text(d.data().idTime))).map((d) => d.id));
    if (!removed.size) continue;
    athletesRemoved += removed.size;
    const ids = [...removed];
    for (let n = 0; n < ids.length; n += 400) {
      const batch = db.batch();
      for (const id of ids.slice(n, n + 400)) batch.delete(round.ref.collection('atletas').doc(id));
      await batch.commit();
    }
    const lineups = await round.ref.collection(FANTASY_LINEUPS).get();
    for (const lineup of lineups.docs) {
      if (!lineupWithoutAthletes(lineup.data(), removed)) continue;
      const participantRef = fantasyRef.collection(FANTASY_PARTICIPANTS).doc(lineup.id);
      await db.runTransaction(async (tx) => {
        const snap = await tx.get(lineup.ref);
        const change = lineupWithoutAthletes(snap.data() ?? {}, removed);
        if (!change) return;
        const delta = pointsDelta(change.pontos, snap.data()?.aplicado);
        tx.update(lineup.ref, { ...change, aplicado: change.pontos, processadoEm: FieldValue.serverTimestamp() });
        if (delta !== 0) tx.set(participantRef, { pontos: FieldValue.increment(delta) }, { merge: true });
      });
    }
    // Card "Craques da rodada": o top 3 com quem sobrou (só se o card existe).
    const cardRef = db.collection('noticias').doc(fantasyRoundNewsId(fantasyRef.id, Number(round.id)));
    const card = await cardRef.get();
    if (!card.exists) continue;
    const left: FantasyCardAthlete[] = audit.docs
      .filter((d) => !removed.has(d.id))
      .map((d) => {
        const data = d.data();
        return {
          idJogador: d.id,
          nome: text(data.nome),
          time: text(data.time),
          idTime: text(data.idTime),
          urlImagem: text(data.urlImagem),
          posicao: text(data.posicao),
          pontos: Number(data.total) || 0,
        };
      });
    const news = fantasyRoundNews(fantasyRef.id, config, Number(round.id), fantasyTopThree(left));
    if (news) await cardRef.set(news, { merge: true });
    else await cardRef.update({ exibir: 'false' });
  }
  logger.info('Fantasy: pontos de times zerados', { fantasy: fantasyRef.id, teams: teamIds, athletesRemoved });
}

/**
 * "Zerar pontuações (testes)": participantes com 0, escalações sem os pontos,
 * rodadas sem a auditoria dos atletas e sem a `apuracao` (status, prazo,
 * partidas e `finalizada` ficam: o mercado não muda), sem campeão e sem os
 * cards "Craques da rodada" no feed. Grava `zeradoEm` ao terminar.
 */
async function resetFantasyScores(fantasyRef: DocRef): Promise<void> {
  const { db, FieldValue } = await admin();
  let batch = db.batch();
  let pending = 0;
  const flush = async (force = false) => {
    if (pending && (force || pending >= 400)) {
      await batch.commit();
      batch = db.batch();
      pending = 0;
    }
  };
  const participants = await fantasyRef.collection(FANTASY_PARTICIPANTS).get();
  for (const p of participants.docs) {
    batch.update(p.ref, { pontos: 0 });
    pending++;
    await flush();
  }
  const rounds = await fantasyRef.collection(FANTASY_ROUNDS).get();
  for (const round of rounds.docs) {
    const [lineups, athletes] = await Promise.all([
      round.ref.collection(FANTASY_LINEUPS).get(),
      round.ref.collection('atletas').get(),
    ]);
    for (const lineup of lineups.docs) {
      batch.update(lineup.ref, {
        pontos: FieldValue.delete(),
        pontosAtletas: FieldValue.delete(),
        atletasJogaram: FieldValue.delete(),
        aplicado: FieldValue.delete(),
        processadoEm: FieldValue.delete(),
      });
      pending++;
      await flush();
    }
    for (const athlete of athletes.docs) {
      batch.delete(athlete.ref);
      pending++;
      await flush();
    }
    batch.update(round.ref, { apuracao: FieldValue.delete() });
    batch.delete(db.collection('noticias').doc(fantasyRoundNewsId(fantasyRef.id, Number(round.id))));
    pending += 2;
    await flush();
  }
  batch.update(fantasyRef, {
    campeao: FieldValue.delete(),
    campeaoEm: FieldValue.delete(),
    zeradoEm: FieldValue.serverTimestamp(),
  });
  pending++;
  await flush(true);
  logger.info('Fantasy: pontuações zeradas', {
    fantasy: fantasyRef.id,
    participants: participants.size,
    rounds: rounds.size,
  });
}

/** Admin ligou o Fantasy: monta as rodadas pelas partidas que já têm rodada. */
export const onFantasyWritten = onDocumentWritten(`${FANTASY}/{fantasyId}`, async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  const ref = event.data?.after.ref;
  if (!after || !ref) return;
  const season = typeof after.temporada === 'string' && after.temporada ? after.temporada : await currentSeason();
  // "Abrir/Fechar rodada" do admin.
  const roundAction = roundActionRequested(before, after);
  if (roundAction) {
    await applyRoundAction(ref, roundAction);
    return;
  }
  // "Zerar pontos de times" do admin (atletas que só jogaram partidas de teste).
  const teamIds = teamsResetRequested(before, after);
  if (teamIds) {
    await resetFantasyTeams(ref, after, teamIds);
    return;
  }
  // "Zerar pontuações (testes)" do admin: antes do reapurar (os dois no mesmo
  // pedido = zera e não reapura).
  if (resetRequested(before, after)) {
    await resetFantasyScores(ref);
    return;
  }
  // "Reapurar rodadas" do admin: rodadas pelas partidas e todas as fechadas
  // apuradas de novo (seguro: a escalação só recebe a diferença).
  if (rescoreRequested(before, after)) {
    await syncFantasyRounds(ref, after, season);
    const rounds = await ref.collection(FANTASY_ROUNDS).where('status', '==', 'fechada').get();
    for (const round of rounds.docs) {
      await scoreFantasyRound(ref, after, Number(round.id), season).catch((error) =>
        logger.error('Fantasy: reapuração falhou', { fantasy: ref.id, round: round.id, error: String(error) }),
      );
    }
    logger.info('Fantasy: reapuração feita', { fantasy: ref.id, rounds: rounds.size });
    return;
  }
  if (after.ativo !== true || before?.ativo === true) return;
  await syncFantasyRounds(ref, after, season);
});

/** Participante novo: a contagem do Fantasy sobe. */
export const onFantasyParticipantCreated = onDocumentCreated(
  `${FANTASY}/{fantasyId}/${FANTASY_PARTICIPANTS}/{uid}`,
  async (event) => {
    const { db, FieldValue } = await admin();
    await db
      .collection(FANTASY)
      .doc(event.params.fantasyId)
      .update({ participantes: FieldValue.increment(1) });
    // Entra no ranking geral com 0 (o `increment(0)` não apaga pontos já somados).
    await event.data?.ref.set({ pontos: FieldValue.increment(0) }, { merge: true });
  },
);

/**
 * Pacotinhos liberados: os álbuns com `avisoEm` vencido recebem o push
 * "Seu pacotinho chegou!" (se o evento ainda está ligado) e perdem o
 * `avisoEm` (um aviso por pacote). Lê só os vencidos.
 */
async function notifyAlbumPacks(now: Date): Promise<void> {
  const { db, FieldValue } = await admin();
  const due = await db.collectionGroup('album').where('avisoEm', '<=', now).limit(200).get();
  const events = new Map<string, Record<string, unknown> | undefined>();
  for (const doc of due.docs) {
    const uid = doc.ref.parent.parent?.id;
    if (!uid) continue;
    if (!events.has(doc.id)) events.set(doc.id, (await db.collection('album_eventos').doc(doc.id).get()).data());
    const albumEvent = events.get(doc.id);
    if (albumEvent?.ativo === true) {
      await deliver(
        `album_pacote_${uid}_${doc.id}_${doc.data().pacotes ?? 0}`,
        albumPackMessage(uid, String(albumEvent.titulo ?? ''), perPackOf(albumEvent)),
        `usuarios/${uid}/album/${doc.id}`,
      );
    }
    await doc.ref.update({ avisoEm: FieldValue.delete() });
  }
}

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
    if (share.kind === 'bolao') {
      data = POOL_PAGE;
    } else if (share.kind === 'album') {
      data = ALBUM_PAGE;
    } else if (share.kind === 'agora') {
      // QR fixo da região: o nome atual pelo id (região apagada = 404).
      const { db } = await admin();
      const region = (await db.collection('competicao').doc(share.regionId).get()).data();
      data = region ? nowPageData(text(region.nome)) : null;
    } else if (share.kind === 'fantasy') {
      // Arena Fantasy do campeonato (sem o doc = 404).
      const { db } = await admin();
      const fantasy = (await db.collection('fantasy').doc(share.id).get()).data();
      data = fantasy ? fantasyPageData(fantasy) : null;
    } else if (share.kind === 'votacao' || share.kind === 'partida') {
      // A partida da temporada do link (coleção conferida pelo padrão da temporada).
      const { db } = await admin();
      const match = (await db.collection(seasonCollection('partidas', share.season)).doc(share.id).get()).data();
      data = !match ? null : share.kind === 'votacao' ? votePageData(match) : matchPageData(match);
    } else if (share.kind === 'convite') {
      // Convite: o primeiro nome de quem convidou (código inexistente = sem nome).
      const { db } = await admin();
      const owner = text((await db.collection('codigos_indicacao').doc(share.code).get()).data()?.uid);
      const profile = owner ? (await db.collection('usuarios').doc(owner).get()).data() : undefined;
      data = invitePageData(firstName(profile?.nome), share.code);
    } else if (share.kind !== 'app') {
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
      db.collection('solicitacoes_parceiro').doc(uid),
      // Notícias do parceiro esperando aprovação.
      ...(await db.collection('noticias_pendentes').where('idAutor', '==', uid).get()).docs.map((doc) => doc.ref),
    ]);

    // Conquistas: contadores e desbloqueios da conta.
    await db.recursiveDelete(db.collection('usuarios').doc(uid).collection('progresso'));
    await db.recursiveDelete(db.collection('usuarios').doc(uid).collection('conquistas'));
    // Álbum de figurinhas: a coleção da conta e os pacotes pedidos.
    await db.recursiveDelete(db.collection('usuarios').doc(uid).collection('album'));
    // Indique amigos: saldo, lista de indicados e o código da conta.
    await db.recursiveDelete(db.collection('indicacoes').doc(uid));
    await deleteExisting(
      db,
      (await db.collection('codigos_indicacao').where('uid', '==', uid).get()).docs.map((d) => d.ref),
    );
    // E as linhas dele nos rankings dos álbuns (poucos eventos).
    const albumEvents = await db.collection('album_eventos').get();
    await deleteExisting(db, albumEvents.docs.map((e) => e.ref.collection('ranking').doc(uid)));
    await deleteExisting(db, (await db.collection('album_pacotes').where('uid', '==', uid).get()).docs.map((d) => d.ref));

    // Votos nos eventos de votação do admin (noticias/{id}/votos_evento/{uid}).
    await deleteExisting(
      db,
      (await db.collectionGroup(EVENT_VOTES).where('uid', '==', uid).get()).docs.map((d) => d.ref),
    );

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

/**
 * Evento de votação: a cada voto novo, reconta os votos de cada opção com
 * `count()` (até 8 agregações) e grava `noticias/{id}/apuracao/total`. O app
 * lê esse doc conforme o `mostrarParcial` do evento (regras).
 */
export const onEventVoteCreated = onDocumentCreated(`noticias/{newsId}/${EVENT_VOTES}/{uid}`, async (event) => {
  const { db, FieldValue } = await admin();
  const newsRef = db.collection('noticias').doc(event.params.newsId);
  const ids = eventOptionIds((await newsRef.get()).data());
  if (!ids.length) return;
  const votes = newsRef.collection(EVENT_VOTES);
  const counts: Record<string, number> = {};
  for (const id of ids) {
    counts[id] = (await votes.where('opcao', '==', id).count().get()).data().count;
  }
  await newsRef
    .collection('apuracao')
    .doc('total')
    .set({ ...tallyDoc(counts), atualizadoEm: FieldValue.serverTimestamp() });
});

/** Perfil: escolheu o time do coração / pôs foto (grava só quando muda). */
export const onUserProfileWritten = onDocumentWritten('usuarios/{uid}', async (event) => {
  const after = event.data?.after.data();
  if (!after) return;
  const ref = await progressRef(event.params.uid);
  const changes = changedFields((await ref.get()).data(), profileCounters(after));
  if (Object.keys(changes).length) await ref.set(changes, { merge: true });
  // Indique amigos: o perfil acabou de ter o código de quem indicou + o time.
  if (referralReady(event.data?.before.data(), after)) await settleReferral(event.params.uid, after);
});

/**
 * Indicações religadas pelo admin: resolve as que chegaram com elas
 * desligadas (`indicacoes/{uid}.pendente`), com o perfil atual de cada uma.
 */
export const onReferralConfigWritten = onDocumentWritten('config/indicacao', async (event) => {
  if (!referralJustEnabled(event.data?.before.data(), event.data?.after.data())) return;
  const { db } = await admin();
  const pending = await db.collection('indicacoes').where('pendente', '==', true).limit(500).get();
  for (const doc of pending.docs) {
    const profile = (await db.collection('usuarios').doc(doc.id).get()).data();
    if (profile) await settleReferral(doc.id, profile);
  }
});

/**
 * Confere a indicação de [uid] (lógica em referrals.ts) e, se vale, dá 1
 * pacotinho extra para os dois, a métrica `indicacoes` de quem indicou e o
 * push; senão grava o motivo. Uma vez só por conta (`validadaEm`/`recusa`).
 */
async function settleReferral(uid: string, profile: Record<string, unknown>): Promise<void> {
  const { db, FieldValue } = await admin();
  const mineRef = db.collection('indicacoes').doc(uid);
  if (referralSettled((await mineRef.get()).data())) return;
  // Desligadas pelo admin: fica pendente e é resolvida quando religar.
  if (!referralEnabled((await db.doc('config/indicacao').get()).data())) {
    await mineRef.set({ pendente: true }, { merge: true });
    return;
  }
  const code = text(profile.indicadoPor).toUpperCase();
  const referrerUid = text((await db.collection('codigos_indicacao').doc(code).get()).data()?.uid);
  const { getAuth } = await import('firebase-admin/auth');
  const created = (await getAuth().getUser(uid).catch(() => null))?.metadata.creationTime;
  const decision = referralDecision({
    inviteeUid: uid,
    referrerUid,
    createdAt: created ? new Date(created) : null,
    now: new Date(),
  });
  const valid = await db.runTransaction(async (tx) => {
    const mine = await tx.get(mineRef);
    if (referralSettled(mine.data())) return false;
    if (!decision.ok) {
      tx.set(
        mineRef,
        { recusa: decision.motivo, recusadaEm: FieldValue.serverTimestamp(), pendente: FieldValue.delete() },
        { merge: true },
      );
      return false;
    }
    const theirsRef = db.collection('indicacoes').doc(referrerUid);
    const theirs = await tx.get(theirsRef);
    const now = FieldValue.serverTimestamp();
    const mineExtras = addExtraPack(mine.data());
    const theirExtras = addExtraPack(theirs.data());
    tx.set(
      mineRef,
      {
        indicadoPorUid: referrerUid,
        validadaEm: now,
        pendente: FieldValue.delete(),
        pacotesExtras: mineExtras,
        pacotesExtrasGanhos: FieldValue.increment(mineExtras - extraPacksOf(mine.data())),
      },
      { merge: true },
    );
    tx.set(
      theirsRef,
      {
        indicados: FieldValue.increment(1),
        pacotesExtras: theirExtras,
        pacotesExtrasGanhos: FieldValue.increment(theirExtras - extraPacksOf(theirs.data())),
      },
      { merge: true },
    );
    tx.set(theirsRef.collection('indicados').doc(uid), { nome: firstName(profile.nome), em: now });
    tx.set(
      db.collection('usuarios').doc(referrerUid).collection('progresso').doc('contadores'),
      { indicacoes: FieldValue.increment(1) },
      { merge: true },
    );
    return true;
  });
  if (valid) {
    await deliver(`indicacao_${uid}`, referralMessage(referrerUid, text(profile.nome)), `usuarios/${uid}`);
  } else if (!decision.ok) {
    logger.info('Indicação recusada', { uid, code, motivo: decision.motivo });
  }
}

/** Atleta ligado à conta (jogadores da temporada atual): atleta, gols e assistências do Geral. */
export const onPlayerWritten = onDocumentWritten('{colecao}/{playerId}', async (event) => {
  const collection = event.params.colecao;
  if (!/^jogadores(\d{4})?$/.test(collection)) return;
  if (collection !== seasonCollection('jogadores', await currentSeason())) return;
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  // Foto nova: as figurinhas do atleta que ainda têm a antiga acompanham.
  const oldPhoto = typeof before?.urlImagem === 'string' ? before.urlImagem.trim() : '';
  const newPhoto = typeof after?.urlImagem === 'string' ? after.urlImagem.trim() : '';
  if (after && newPhoto && newPhoto !== oldPhoto) {
    await syncStickerPhotos(event.params.playerId, oldPhoto, newPhoto);
  }
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

/**
 * Copia a foto nova do atleta para as figurinhas dele em todos os eventos do
 * álbum, só nas que ainda têm a foto antiga (ou nenhuma): a foto que o admin
 * enviou para a figurinha fica (`stickerPhotoUpdate`).
 */
async function syncStickerPhotos(playerId: string, oldUrl: string, newUrl: string): Promise<void> {
  try {
    const { db } = await admin();
    const events = await db.collection('album_eventos').get();
    const batch = db.batch();
    let updates = 0;
    for (const eventDoc of events.docs) {
      const stickers = await eventDoc.ref.collection('figurinhas').where('idJogador', '==', playerId).get();
      for (const sticker of stickers.docs) {
        const url = stickerPhotoUpdate(sticker.data(), oldUrl, newUrl);
        if (url === null) continue;
        batch.update(sticker.ref, { urlImagem: url });
        updates++;
      }
    }
    if (updates > 0) await batch.commit();
    logger.info('syncStickerPhotos', { playerId, updates });
  } catch (error) {
    logger.error('syncStickerPhotos', { playerId, error });
  }
}

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
  // Transação: relê as desbloqueadas (dois gatilhos juntos não pagam o prêmio duas vezes).
  const granted = await db.runTransaction(async (tx) => {
    const current = (await tx.get(ref)).data();
    const done = new Set(Array.isArray(current?.[UNLOCKED_FIELD]) ? current[UNLOCKED_FIELD].map(String) : []);
    const fresh = unlocks.filter((a) => !done.has(a.id));
    if (!fresh.length) return [] as typeof unlocks;
    for (const achievement of fresh) {
      tx.set(db.collection('usuarios').doc(uid).collection('conquistas').doc(achievement.id), {
        em: FieldValue.serverTimestamp(),
        vista: first,
      });
    }
    tx.set(ref, { [UNLOCKED_FIELD]: FieldValue.arrayUnion(...fresh.map((a) => a.id)) }, { merge: true });
    // Prêmio em pacotinhos (saldo extra do álbum); a 1ª avaliação (retroativa) não paga.
    const packs = first ? 0 : achievementPackReward(fresh);
    if (packs > 0) {
      tx.set(
        db.collection('indicacoes').doc(uid),
        {
          pacotesExtras: FieldValue.increment(packs),
          pacotesExtrasGanhos: FieldValue.increment(packs),
          pacotesConquistas: FieldValue.increment(packs),
        },
        { merge: true },
      );
    }
    return fresh;
  });
  if (first) return;
  for (const achievement of granted) {
    await deliver(
      `conquista_${uid}_${achievement.id}`,
      achievementMessage(uid, achievement),
      `usuarios/${uid}/conquistas/${achievement.id}`,
    );
  }
});

/**
 * Manutenção do admin: recomprime as imagens antigas do Storage em lotes.
 * O app grava `manutencao/recomprimir` com `status: "pedido"`; cada lote
 * grava o progresso com um `lote` novo, e essa escrita dispara o próximo,
 * até passar por todas as pastas (`status: "concluido"`).
 */
export const onRecompressRequested = onDocumentWritten(
  { document: 'manutencao/recomprimir', memory: '1GiB', timeoutSeconds: 300, maxInstances: 1 },
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!shouldRunBatch(before, after)) return;
    const { db, storage, FieldValue } = await admin();
    const ref = db.doc('manutencao/recomprimir');
    const start = after?.status === 'pedido';
    const progress = start
      ? { ...progressOf(undefined), pasta: RECOMPRESS_FOLDERS[0] }
      : progressOf(after);
    try {
      const sharp = (await import('sharp')).default;
      const bucket = storage.bucket();
      const [files, next] = await bucket.getFiles({
        prefix: `${progress.pasta}/`,
        maxResults: BATCH_SIZE,
        autoPaginate: false,
        ...(progress.pageToken ? { pageToken: progress.pageToken } : {}),
      });
      for (const file of files) {
        progress.vistos += 1;
        const meta = file.metadata;
        const info = {
          name: file.name,
          contentType: String(meta.contentType ?? ''),
          size: Number(meta.size ?? 0),
          metadata: (meta.metadata ?? {}) as Record<string, unknown>,
        };
        if (!shouldRecompress(info)) continue;
        try {
          const [original] = await file.download();
          const profile = profileFor(progress.pasta);
          const resized = sharp(original, { failOn: 'none' })
            .rotate()
            .resize({ width: profile.size, height: profile.size, fit: 'inside', withoutEnlargement: true });
          const format = outputFormat(info.contentType);
          const output = await (format === 'png'
            ? resized.png({ compressionLevel: 9, palette: true })
            : format === 'webp'
              ? resized.webp({ quality: profile.quality })
              : resized.jpeg({ quality: profile.quality, mozjpeg: true })
          ).toBuffer();
          const custom = { ...info.metadata, [DONE_FLAG]: 'true' };
          if (!worthReplacing(original.length, output.length)) {
            // Não compensa: só marca para não tentar de novo.
            await file.setMetadata({ metadata: custom });
            continue;
          }
          // Mesmo caminho, tipo e token de download: as URLs gravadas continuam valendo.
          await file.save(output, {
            resumable: false,
            contentType: info.contentType,
            metadata: { cacheControl: meta.cacheControl, metadata: custom },
          });
          progress.regravados += 1;
          progress.bytesAntes += original.length;
          progress.bytesDepois += output.length;
        } catch (error) {
          logger.warn('Imagem não recomprimida', { file: file.name, error: String(error) });
        }
      }
      const nextToken = (next as { pageToken?: string } | null)?.pageToken ?? '';
      const folder = nextToken ? progress.pasta : nextFolder(progress.pasta);
      await ref.set(
        {
          ...progress,
          pasta: folder,
          pageToken: nextToken,
          status: folder ? 'rodando' : 'concluido',
          lote: FieldValue.increment(1),
          atualizadoEm: FieldValue.serverTimestamp(),
          erro: '',
        },
        { merge: true },
      );
    } catch (error) {
      logger.error('Recompressão parou', { error: String(error) });
      await ref.set({ status: 'erro', erro: String(error), atualizadoEm: FieldValue.serverTimestamp() }, { merge: true });
    }
  },
);

/**
 * Pacotinho do álbum de figurinhas: o app cria `album_pacotes/{id}`
 * (`<evento>_<uid>_<n>`, n = pacotes + 1; as regras exigem 24 h desde o
 * último) e aqui sorteia as figurinhas, cola no álbum da conta, marca quando
 * libera o próximo (`avisoEm`, o push do `closeVotings`) e soma nas métricas
 * das conquistas.
 */
export const onAlbumPackRequested = onDocumentCreated('album_pacotes/{packId}', async (event) => {
  const parsed = parsePackId(event.params.packId);
  if (!parsed || event.data?.data()?.status !== 'pedido') return;
  const { db, FieldValue } = await admin();
  const packRef = db.collection('album_pacotes').doc(event.params.packId);
  try {
    const eventRef = db.collection('album_eventos').doc(parsed.eventId);
    const albumRef = db.collection('usuarios').doc(parsed.uid).collection('album').doc(parsed.eventId);
    const rankingRef = eventRef.collection('ranking').doc(parsed.uid);
    const referralRef = db.collection('indicacoes').doc(parsed.uid);
    const [eventSnap, catalog, albumSnap, rankingSnap, profileSnap, referralSnap] = await Promise.all([
      eventRef.get(),
      eventRef.collection('figurinhas').get(),
      albumRef.get(),
      rankingRef.get(),
      db.collection('usuarios').doc(parsed.uid).get(),
      referralRef.get(),
    ]);
    const requestedAt = dateOf(event.data?.data()?.pedidoEm) ?? new Date();
    // Confere de novo a sequência e as 24 h, ou o saldo de pacotinhos extras
    // da indicação (as regras já barram). O extra não mexe no relógio do diário.
    const tradeIds = event.data?.data()?.troca;
    const trading = tradeIds !== undefined;
    const kind = packKind(albumSnap.data(), parsed.n, requestedAt, {
      requested: event.data?.data()?.extra === true,
      extraPacks: extraPacksOf(referralSnap.data()),
      trade: trading,
    });
    // Troca de repetidas: as quantidades e o limite do dia (as regras só conferem o tamanho).
    const refusal =
      kind === 'troca'
        ? tradeRefusal(
            albumSnap.data(),
            tradeIds,
            tradeConfig(eventSnap.data()),
            requestedAt,
            new Set(catalog.docs.map((doc) => doc.id)),
          )
        : null;
    if (eventSnap.data()?.ativo !== true || catalog.empty || kind === null || refusal !== null) {
      await packRef.update({
        status: 'recusado',
        abertoEm: FieldValue.serverTimestamp(),
        ...(refusal ? { motivo: refusal } : {}),
      });
      return;
    }
    const stickers = catalog.docs.map((doc) => stickerOf(doc.id, doc.data()));
    const drawn = drawPack(stickers, perPackOf(eventSnap.data()));
    const before = kind === 'troca' ? applyTrade(albumOf(albumSnap.data()), tradeIds as string[]) : albumOf(albumSnap.data());
    const { album, novas, newPages, justCompleted } = applyPack(before, drawn, stickers);
    const batch = db.batch();
    batch.update(packRef, { status: 'aberto', figurinhas: drawn, novas, abertoEm: FieldValue.serverTimestamp() });
    batch.set(
      albumRef,
      kind === 'extra'
        ? { ...album, pacotes: parsed.n }
        : kind === 'troca'
          ? { ...album, pacotes: parsed.n, trocasDia: nextTradeDay(albumSnap.data(), requestedAt) }
          : { ...album, pacotes: parsed.n, ultimoPacote: requestedAt, avisoEm: nextPackAt(requestedAt) },
      { merge: true },
    );
    if (kind === 'extra') batch.update(referralRef, { pacotesExtras: FieldValue.increment(-1) });
    // Ranking de colecionadores do álbum (leitura pública).
    const profile = profileSnap.data() ?? {};
    batch.set(
      rankingRef,
      rankingEntry(
        parsed.uid,
        rankingSnap.data(),
        album,
        stickers,
        { nome: String(profile.nome ?? ''), urlImagem: String(profile.urlImagem ?? '') },
        new Date(),
      ),
    );
    batch.set(
      await progressRef(parsed.uid),
      {
        albumFigurinhas: FieldValue.increment(novas.length),
        albumPaginas: FieldValue.increment(newPages.length),
        ...(justCompleted ? { albumCompleto: 1 } : {}),
      },
      { merge: true },
    );
    await batch.commit();
  } catch (error) {
    logger.error('Falha ao abrir o pacote', { pack: event.params.packId, error: String(error) });
    await packRef.update({ status: 'erro' }).catch(() => undefined);
  }
});
