/**
 * Arena Fantasy: rodadas a partir do campo `rodada` das partidas, rodada atual
 * e a cópia da escalação para a rodada seguinte. Funções puras (testes em
 * test/fantasy.test.ts); quem lê e grava é o index.ts.
 */
import { predictionDeadline } from './predictions';

type Doc = Record<string, unknown>;

export const FANTASY = 'fantasy';
export const FANTASY_ROUNDS = 'rodadas';
export const FANTASY_LINEUPS = 'escalacoes';
export const FANTASY_PARTICIPANTS = 'participantes';

/** Campos da partida que mudam as rodadas do Fantasy. */
export const ROUND_FIELDS = ['rodada', 'data', 'horario', 'id_campeonato', 'inicioEm'] as const;

/** Rodada gravada: inteiro de 1 a 99; o resto não tem rodada. */
export function matchdayOf(value: unknown): number | null {
  const n = typeof value === 'number' ? Math.trunc(value) : Number.parseInt(String(value ?? ''), 10);
  return Number.isFinite(n) && n >= 1 && n <= 99 ? n : null;
}

/** Rodada calculada das partidas: o prazo é o início do 1º jogo dela. */
export interface ComputedRound {
  numero: number;
  idsPartidas: string[];
  fechaEm: Date | null;
}

/** Agrupa por `rodada` as partidas [matches] (id + dados) da temporada [season]. */
export function fantasyRounds(matches: { id: string; data: Doc }[], season: string): ComputedRound[] {
  const rounds = new Map<number, ComputedRound>();
  for (const match of matches) {
    const n = matchdayOf(match.data.rodada);
    if (n === null) continue;
    const round = rounds.get(n) ?? { numero: n, idsPartidas: [], fechaEm: null };
    round.idsPartidas.push(match.id);
    const start = predictionDeadline(match.data, season);
    if (start && (!round.fechaEm || start < round.fechaEm)) round.fechaEm = start;
    rounds.set(n, round);
  }
  return [...rounds.values()]
    .map((r) => ({ ...r, idsPartidas: [...r.idsPartidas].sort() }))
    .sort((a, b) => a.numero - b.numero);
}

/** Rodada atual: a menor ainda aberta (prazo no futuro); 0 = nenhuma. */
export function currentRound(rounds: { numero: number; fechaEm: Date | null; status?: string }[], now: Date): number {
  const open = rounds
    .filter((r) => r.status !== 'fechada' && r.fechaEm !== null && r.fechaEm > now)
    .map((r) => r.numero)
    .sort((a, b) => a - b);
  return open[0] ?? 0;
}

/** Rodada gravada: o que importa para a sincronia. */
export interface StoredRound {
  status?: string;
  fechaEm: Date | null;
  idsPartidas?: string[];
}

/**
 * O que gravar na rodada [computed] diante da [existing]: nova = aberta com o
 * prazo; aberta = prazo e partidas atualizados; fechada = só as partidas (o
 * prazo não muda). Nulo = nada mudou. Rodada sem prazo (partida sem data)
 * não abre.
 */
export function roundSync(existing: StoredRound | undefined, computed: ComputedRound): Doc | null {
  const sameIds = (a: string[] = [], b: string[] = []) => a.length === b.length && a.every((id, i) => id === b[i]);
  if (existing?.status === 'fechada') {
    return sameIds(existing.idsPartidas, computed.idsPartidas) ? null : { idsPartidas: computed.idsPartidas };
  }
  if (!computed.fechaEm) return null;
  const sameDeadline = existing?.fechaEm?.getTime() === computed.fechaEm.getTime();
  if (existing && sameDeadline && sameIds(existing.idsPartidas, computed.idsPartidas)) return null;
  return {
    numero: computed.numero,
    idsPartidas: computed.idsPartidas,
    fechaEm: computed.fechaEm,
    status: 'aberta',
  };
}

/** Parâmetros congelados na rodada ao fechar (os da configuração naquele momento). */
export function frozenParams(config: Doc): { minMinutos: number; minMinutosDefesa: number; capitao: number } {
  const num = (value: unknown, fallback: number) => (typeof value === 'number' && Number.isFinite(value) ? value : fallback);
  return {
    minMinutos: num(config.minMinutos, 20),
    minMinutosDefesa: num(config.minMinutosDefesa, 45),
    capitao: num(config.capitao, 1.5),
  };
}

/**
 * Cópia da escalação [lineup] para a rodada seguinte (decisão D3): os mesmos
 * atletas e capitão, marcada `copiada` (o dono troca até o prazo). Sem as 5
 * vagas ou sem capitão, nula.
 */
export function lineupCopy(lineup: Doc): Doc | null {
  const athletes = lineup.atletas as Record<string, unknown> | undefined;
  const ids = Array.isArray(lineup.idsAtletas) ? lineup.idsAtletas.map(String) : [];
  const captain = String(lineup.capitao ?? '');
  if (!athletes || ids.length !== 5 || !ids.includes(captain)) return null;
  return {
    uid: String(lineup.uid ?? ''),
    nome: String(lineup.nome ?? ''),
    urlImagem: String(lineup.urlImagem ?? ''),
    atletas: { ...athletes },
    idsAtletas: ids,
    capitao: captain,
    copiada: true,
  };
}

/** Partida mudou algo que mexe nas rodadas do Fantasy (rodada, data, horário, competição, início). */
export function roundFieldsChanged(before: Doc, after: Doc): boolean {
  const key = (value: unknown) => (value && typeof value === 'object' && 'toMillis' in value
    ? String((value as { toMillis: () => number }).toMillis())
    : String(value ?? ''));
  return ROUND_FIELDS.some((field) => key(before[field]) !== key(after[field]));
}

/** Próxima rodada aberta depois da [numero] (cópia das escalações); nula = nenhuma. */
export function nextOpenRound(rounds: { numero: number; status?: string }[], numero: number): number | null {
  const next = rounds
    .filter((r) => r.numero > numero && r.status === 'aberta')
    .map((r) => r.numero)
    .sort((a, b) => a - b);
  return next[0] ?? null;
}

/** Última rodada fechada antes da [numero] (de onde copiar para a rodada nova); nula = nenhuma. */
export function previousClosedRound(rounds: { numero: number; status?: string }[], numero: number): number | null {
  const previous = rounds
    .filter((r) => r.numero < numero && r.status === 'fechada')
    .map((r) => r.numero)
    .sort((a, b) => b - a);
  return previous[0] ?? null;
}

/** Campeão do Fantasy (na lista do participante). */
export interface FantasyChampion {
  uid: string;
  nome: string;
  urlImagem: string;
  pontos: number;
}

/**
 * Campeão(ões) do Fantasy: os participantes com mais pontos (empate = todos).
 * Sem participante com pontos acima de zero, ninguém.
 */
export function fantasyChampions(participants: { id: string; data: Doc }[]): FantasyChampion[] {
  const list = participants.map((p) => ({
    uid: p.id,
    nome: String(p.data.nome ?? ''),
    urlImagem: String(p.data.urlImagem ?? ''),
    pontos: typeof p.data.pontos === 'number' && Number.isFinite(p.data.pontos) ? p.data.pontos : 0,
  }));
  const best = Math.max(0, ...list.map((p) => p.pontos));
  if (best <= 0) return [];
  return list.filter((p) => p.pontos === best).sort((a, b) => a.nome.localeCompare(b.nome));
}
