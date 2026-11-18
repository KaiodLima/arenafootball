/**
 * Arena Fantasy: pontuação dos atletas a partir da súmula oficial
 * (`partidas{ano}`). Funções puras (testes em test/fantasy_scoring.test.ts);
 * quem lê e grava é o index.ts. Mudou uma regra: suba SCORING_VERSION.
 */

type Doc = Record<string, unknown>;
export type Side = 'casa' | 'fora';
export type FantasyPosition = 'gol' | 'zag' | 'mei' | 'ata';

export const SCORING_VERSION = 1;

/** Parâmetros congelados na rodada. */
export interface ScoringParams {
  minMinutos: number;
  minMinutosDefesa: number;
  capitao: number;
}

export const POINTS = {
  base: 10,
  goal: 5,
  assist: 5,
  win: 3,
  loss: -3,
  yellow: -3,
  red: -5,
  conceded: { gol: -3, zag: -2, mei: -1, ata: -1 } as Record<FantasyPosition, number>,
  cleanSheet: { gol: 5, zag: 3, mei: 2, ata: 2 } as Record<FantasyPosition, number>,
  teamGoalMidfielder: 1,
} as const;

const text = (value: unknown): string => (value === undefined || value === null ? '' : String(value).trim());
const minuteOf = (value: unknown): number | null => {
  const n = typeof value === 'number' ? value : Number.parseInt(text(value), 10);
  return Number.isFinite(n) && n >= 0 ? Math.trunc(n) : null;
};
const sideOfText = (value: unknown): Side | null => (value === 'casa' ? 'casa' : value === 'fora' ? 'fora' : null);
const other = (side: Side): Side => (side === 'casa' ? 'fora' : 'casa');
export const round2 = (value: number): number => Math.round(value * 100) / 100;

/** Posição do Fantasy pela do cadastro (D2: lateral → ZAG, volante → MEI). */
export function positionOf(posicao: unknown): FantasyPosition | null {
  switch (text(posicao).toLowerCase()) {
    case 'goleiro':
      return 'gol';
    case 'zagueiro':
    case 'lateral':
      return 'zag';
    case 'volante':
    case 'meia':
      return 'mei';
    case 'atacante':
      return 'ata';
    default:
      return null;
  }
}

interface Goal {
  id: string;
  side: Side;
  scorerId: string;
  assistId: string;
  minute: number | null;
}

interface Booking {
  id: string;
  side: Side;
  red: boolean;
  playerId: string;
  minute: number | null;
  secondYellow: boolean;
}

interface Sub {
  id: string;
  side: Side;
  outId: string;
  inId: string;
  minute: number | null;
}

/** A súmula lida para a pontuação. */
export interface ParsedMatch {
  goals: Goal[];
  bookings: Booking[];
  subs: Sub[];
  lineup: Record<Side, { id: string; starter: boolean }[]>;
  end: number;
  score: Record<Side, number>;
  teamIds: Record<Side, string>;
}

const list = (value: unknown): Doc[] =>
  Array.isArray(value) ? value.filter((v): v is Doc => !!v && typeof v === 'object') : [];

export function parseMatch(data: Doc): ParsedMatch {
  const goals: Goal[] = [];
  list(data.gols).forEach((g, i) => {
    const side = sideOfText(g.lado);
    if (!side) return;
    goals.push({
      id: text(g.id) || `g${i}`,
      side,
      scorerId: text(g.idJogador),
      assistId: text(g.idAssistencia),
      minute: minuteOf(g.minuto),
    });
  });
  // Sem a lista de gols (placar lançado na mão): gols sem autor nem minuto.
  if (goals.length === 0) {
    for (const side of ['casa', 'fora'] as Side[]) {
      const n = Number.parseInt(text(side === 'casa' ? data.golTimeCasa : data.golTimeFora), 10) || 0;
      for (let i = 0; i < n; i++) goals.push({ id: `${side}${i}`, side, scorerId: '', assistId: '', minute: null });
    }
  }
  const bookings: Booking[] = [];
  list(data.cartoes).forEach((b, i) => {
    const side = sideOfText(b.lado);
    if (!side) return;
    bookings.push({
      id: text(b.id) || `c${i}`,
      side,
      red: text(b.tipo) === 'vermelho',
      playerId: text(b.idJogador),
      minute: minuteOf(b.minuto),
      secondYellow: b.segundoAmarelo === true,
    });
  });
  const subs: Sub[] = [];
  list(data.substituicoes).forEach((s, i) => {
    const side = sideOfText(s.lado);
    if (!side) return;
    subs.push({ id: text(s.id) || `s${i}`, side, outId: text(s.idSai), inId: text(s.idEntra), minute: minuteOf(s.minuto) });
  });
  const lineupDoc = (data.escalacao && typeof data.escalacao === 'object' ? data.escalacao : {}) as Doc;
  const lineup = {
    casa: list(lineupDoc.casa).map((e) => ({ id: text(e.idJogador), starter: e.titular !== false })),
    fora: list(lineupDoc.fora).map((e) => ({ id: text(e.idJogador), starter: e.titular !== false })),
  };
  const duration = Number.parseInt(text(data.duracao), 10) || 90;
  const minutes = [...goals, ...bookings, ...subs].map((e) => e.minute ?? 0);
  return {
    goals,
    bookings,
    subs,
    lineup,
    end: Math.max(duration, ...minutes),
    score: {
      casa: goals.filter((g) => g.side === 'casa').length,
      fora: goals.filter((g) => g.side === 'fora').length,
    },
    teamIds: { casa: text(data.idTimeC), fora: text(data.idTimeF) },
  };
}

/** Lado do atleta na partida: escalação, lances ou o time dele na competição. */
export function sideOf(match: ParsedMatch, playerId: string, teamId = ''): Side | null {
  for (const side of ['casa', 'fora'] as Side[]) {
    if (match.lineup[side].some((e) => e.id === playerId)) return side;
  }
  const event =
    match.goals.find((g) => g.scorerId === playerId || g.assistId === playerId) ??
    match.bookings.find((b) => b.playerId === playerId) ??
    match.subs.find((s) => s.inId === playerId || s.outId === playerId);
  if (event) return event.side;
  if (teamId && teamId === match.teamIds.casa) return 'casa';
  if (teamId && teamId === match.teamIds.fora) return 'fora';
  return null;
}

/** Tempo em campo do atleta na partida. */
export interface Participation {
  minutes: number;
  windows: [number, number][];
  estimated: boolean;
  fullMatch: boolean;
  reason?: string;
}

function hasEvent(match: ParsedMatch, playerId: string, side: Side): boolean {
  return (
    match.goals.some((g) => g.side === side && (g.scorerId === playerId || g.assistId === playerId)) ||
    match.bookings.some((b) => b.side === side && b.playerId === playerId)
  );
}

/**
 * Janelas em campo: titular entra no 0, reserva no minuto da substituição;
 * sai substituído, no vermelho ou no fim. Sem escalação do lado (ou numa
 * troca sem minuto): quem tem lance conta o jogo inteiro (estimado), o resto 0.
 */
export function participation(match: ParsedMatch, playerId: string, side: Side): Participation {
  const lineup = match.lineup[side];
  const mySubs = match.subs.filter((s) => s.side === side && (s.inId === playerId || s.outId === playerId));
  const full = (): Participation => ({ minutes: match.end, windows: [[0, match.end]], estimated: true, fullMatch: true });
  if (lineup.length === 0 || mySubs.some((s) => s.minute === null)) {
    if (hasEvent(match, playerId, side)) return full();
    return {
      minutes: 0,
      windows: [],
      estimated: false,
      fullMatch: false,
      reason: lineup.length === 0 ? 'sem_escalacao' : 'substituicao_sem_minuto',
    };
  }
  const entry = lineup.find((e) => e.id === playerId);
  if (!entry && !mySubs.some((s) => s.inId === playerId)) {
    // Fora da escalação, mas com lance (súmula incompleta): jogo inteiro estimado.
    if (hasEvent(match, playerId, side)) return full();
    return { minutes: 0, windows: [], estimated: false, fullMatch: false, reason: 'nao_entrou' };
  }
  const red = match.bookings
    .filter((b) => b.side === side && b.playerId === playerId && b.red)
    .map((b) => b.minute ?? match.end)
    .sort((a, b) => a - b)[0];
  const moves = [
    ...mySubs.map((s) => ({ minute: s.minute as number, enter: s.inId === playerId })),
    ...(red === undefined ? [] : [{ minute: red, enter: false }]),
  ].sort((a, b) => a.minute - b.minute || (a.enter ? -1 : 1));
  const windows: [number, number][] = [];
  let onField: number | null = entry?.starter ? 0 : null;
  for (const move of moves) {
    if (move.enter && onField === null) onField = move.minute;
    else if (!move.enter && onField !== null) {
      windows.push([onField, move.minute]);
      onField = null;
    }
  }
  if (onField !== null) windows.push([onField, match.end]);
  const minutes = windows.reduce((sum, [a, b]) => sum + Math.max(0, b - a), 0);
  return {
    minutes,
    windows,
    estimated: false,
    fullMatch: windows.length === 1 && windows[0][0] === 0 && windows[0][1] === match.end,
    reason: minutes === 0 ? 'nao_entrou' : undefined,
  };
}

/** Gol no tempo em campo (entrada < minuto ≤ saída); sem minuto, só quem jogou tudo. */
function inField(goal: Goal, p: Participation): boolean {
  if (goal.minute === null) return p.fullMatch;
  return p.windows.some(([a, b]) => goal.minute! > a && goal.minute! <= b);
}

export interface ScoreItem {
  regra: string;
  qtd: number;
  pontos: number;
  idPartida: string;
  ids?: string[];
}

export interface Reason {
  codigo: string;
  idPartida?: string;
}

export interface MatchScore {
  idPartida: string;
  lado: Side;
  minutos: number;
  janelas: { de: number; ate: number }[];
  minutosEstimados: boolean;
  pontos: number;
}

/** Pontos do atleta [playerId] ([position]) na partida [match]. */
export function scoreInMatch(
  match: ParsedMatch,
  matchId: string,
  playerId: string,
  side: Side,
  position: FantasyPosition,
  params: ScoringParams,
): { score: MatchScore; itens: ScoreItem[]; motivos: Reason[] } {
  const p = participation(match, playerId, side);
  const score: MatchScore = {
    idPartida: matchId,
    lado: side,
    minutos: p.minutes,
    janelas: p.windows.map(([de, ate]) => ({ de, ate })),
    minutosEstimados: p.estimated,
    pontos: 0,
  };
  if (p.minutes === 0) return { score, itens: [], motivos: [{ codigo: p.reason ?? 'nao_entrou', idPartida: matchId }] };
  // Abaixo do mínimo: só os lances individuais (gols, assistências e
  // cartões); sem base, resultado, gols sofridos/da equipe nem bônus.
  const short = p.minutes < params.minMinutos;
  const itens: ScoreItem[] = [];
  const motivos: Reason[] = short ? [{ codigo: 'minutos_insuficientes', idPartida: matchId }] : [];
  const add = (regra: string, qtd: number, each: number, ids?: string[]) => {
    itens.push({ regra, qtd, pontos: round2(qtd * each), idPartida: matchId, ...(ids && ids.length ? { ids } : {}) });
  };
  if (!short) add('base', 1, POINTS.base);
  const goals = match.goals.filter((g) => g.side === side && g.scorerId === playerId);
  if (goals.length) add('gol', goals.length, POINTS.goal, goals.map((g) => g.id));
  const assists = match.goals.filter((g) => g.side === side && g.assistId === playerId);
  if (assists.length) add('assistencia', assists.length, POINTS.assist, assists.map((g) => g.id));
  // Cartões: o 2º amarelo vira o vermelho (−5) e não soma o amarelo de novo.
  const cards = match.bookings.filter((b) => b.side === side && b.playerId === playerId);
  const reds = cards.filter((b) => b.red);
  const secondYellow = reds.some((b) => b.secondYellow);
  const yellows = cards.filter((b) => !b.red);
  const countedYellows = yellows.slice(0, Math.max(0, yellows.length - (secondYellow ? 1 : 0)));
  if (countedYellows.length) add('amarelo', countedYellows.length, POINTS.yellow, countedYellows.map((b) => b.id));
  if (reds.length) add('vermelho', reds.length, POINTS.red, reds.map((b) => b.id));
  if (short) {
    if (p.estimated) motivos.push({ codigo: 'minutos_estimados', idPartida: matchId });
    score.pontos = round2(itens.reduce((sum, i) => sum + i.pontos, 0));
    return { score, itens, motivos };
  }
  const mine = match.score[side];
  const theirs = match.score[other(side)];
  if (mine > theirs) add('vitoria', 1, POINTS.win);
  else if (mine < theirs) add('derrota', 1, POINTS.loss);
  else add('empate', 1, 0);
  // Gols sofridos e da equipe no tempo em campo.
  const conceded = match.goals.filter((g) => g.side === other(side) && inField(g, p));
  if (conceded.length) add('gols_sofridos', conceded.length, POINTS.conceded[position], conceded.map((g) => g.id));
  if (position === 'mei') {
    const teamGoals = match.goals.filter((g) => g.side === side && inField(g, p));
    if (teamGoals.length) add('gols_equipe', teamGoals.length, POINTS.teamGoalMidfielder, teamGoals.map((g) => g.id));
  }
  if (conceded.length === 0) {
    if (p.minutes >= params.minMinutosDefesa) add('sem_sofrer_gols', 1, POINTS.cleanSheet[position]);
    else motivos.push({ codigo: 'bonus_minutos_insuficientes', idPartida: matchId });
  }
  if (p.estimated) motivos.push({ codigo: 'minutos_estimados', idPartida: matchId });
  score.pontos = round2(itens.reduce((sum, i) => sum + i.pontos, 0));
  return { score, itens, motivos };
}

/** Atleta para a pontuação (do `jogadores{ano}`). */
export interface ScoringPlayer {
  id: string;
  posicao: unknown;
  /** Time dele na competição (inscrição; para achar o lado sem escalação). */
  teamId: string;
}

export interface AthleteScore {
  total: number;
  minutos: number;
  posicao: FantasyPosition | null;
  partidas: MatchScore[];
  itens: ScoreItem[];
  motivos: Reason[];
}

/** Pontos do atleta na rodada: a soma das [matches] terminadas em que ele está. */
export function scoreAthlete(matches: { id: string; data: Doc }[], player: ScoringPlayer, params: ScoringParams): AthleteScore {
  const position = positionOf(player.posicao);
  const result: AthleteScore = { total: 0, minutos: 0, posicao: position, partidas: [], itens: [], motivos: [] };
  if (!position) {
    result.motivos.push({ codigo: 'sem_posicao' });
    return result;
  }
  for (const { id, data } of matches) {
    const match = parseMatch(data);
    const side = sideOf(match, player.id, player.teamId);
    if (!side) continue;
    const { score, itens, motivos } = scoreInMatch(match, id, player.id, side, position, params);
    result.partidas.push(score);
    result.itens.push(...itens);
    result.motivos.push(...motivos);
    result.minutos += score.minutos;
    result.total = round2(result.total + score.pontos);
  }
  if (result.partidas.length === 0) result.motivos.push({ codigo: matches.length ? 'nao_jogou' : 'sem_partidas' });
  return result;
}

/** Pontos da escalação: soma dos atletas, o capitão × [captainMultiplier]. */
export function lineupPoints(
  athleteIds: string[],
  captainId: string,
  totals: Record<string, number>,
  captainMultiplier: number,
): { pontos: number; pontosAtletas: Record<string, number> } {
  const pontosAtletas: Record<string, number> = {};
  for (const id of athleteIds) {
    const total = totals[id] ?? 0;
    pontosAtletas[id] = round2(id === captainId ? total * captainMultiplier : total);
  }
  const pontos = round2(Object.values(pontosAtletas).reduce((sum, v) => sum + v, 0));
  return { pontos, pontosAtletas };
}

/** Diferença a somar no participante (o que mudou desde o último [applied]). */
export const pointsDelta = (points: number, applied: unknown): number =>
  round2(points - (typeof applied === 'number' && Number.isFinite(applied) ? applied : 0));

/** Campos da súmula que mudam a pontuação. */
const SCORING_FIELDS = [
  'gols',
  'golTimeCasa',
  'golTimeFora',
  'cartoes',
  'substituicoes',
  'escalacao',
  'duracao',
  'status',
  'resultadoNoticia',
  'rodada',
] as const;

export function scoringFieldsChanged(before: Doc, after: Doc): boolean {
  return SCORING_FIELDS.some((field) => JSON.stringify(before[field] ?? null) !== JSON.stringify(after[field] ?? null));
}
