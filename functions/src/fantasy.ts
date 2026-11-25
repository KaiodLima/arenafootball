/**
 * Arena Fantasy: rodadas a partir do campo `rodada` das partidas, rodada atual
 * e a cópia da escalação para a rodada seguinte. Funções puras (testes em
 * test/fantasy.test.ts); quem lê e grava é o index.ts.
 */
import { predictionDeadline } from './predictions';
import { scoringTable, tableToDoc, type ScoringParams } from './fantasy_scoring';

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

/** Rodada para a `rodadaAtual` (o que importa: prazo, status, partidas e se terminou). */
export interface RoundState {
  numero: number;
  fechaEm: Date | null;
  status?: string;
  idsPartidas?: string[];
  finalizada?: boolean;
}

/**
 * Rodada em andamento (mercado fechado): a menor com partidas, prazo vencido
 * e ainda não finalizada (nem todas as partidas terminadas e apuradas),
 * aberta ou já fechada; nula = nenhuma.
 */
export function roundInProgress(rounds: RoundState[], now: Date): number | null {
  const playing = rounds
    .filter(
      (r) =>
        (r.status === 'aberta' || r.status === 'fechada') &&
        (r.idsPartidas?.length ?? 0) > 0 &&
        r.fechaEm !== null &&
        r.fechaEm <= now &&
        r.finalizada !== true,
    )
    .map((r) => r.numero)
    .sort((a, b) => a - b);
  return playing[0] ?? null;
}

/**
 * Rodada atual: a em andamento (mercado fechado até ela terminar, estilo
 * Cartola); sem ela, a menor aberta com prazo no futuro; 0 = nenhuma.
 */
export function currentRound(rounds: RoundState[], now: Date): number {
  const playing = roundInProgress(rounds, now);
  if (playing !== null) return playing;
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
  /** Prazo escolhido pelo admin ("Reabrir"): a sincronia não troca. */
  prazoManual?: boolean;
  /** Fechada pelo admin ("Fechar agora"): a sincronia não reabre sozinha. */
  fechadaManual?: boolean;
}

/**
 * O que gravar na rodada [computed] diante da [existing]: nova = aberta com o
 * prazo; aberta = prazo e partidas atualizados; fechada = só as partidas (o
 * prazo não muda). Nulo = nada mudou. Rodada sem prazo (partida sem data)
 * não abre.
 */
export function roundSync(
  existing: StoredRound | undefined,
  computed: ComputedRound,
  now: Date = new Date(),
): Doc | null {
  const sameIds = (a: string[] = [], b: string[] = []) => a.length === b.length && a.every((id, i) => id === b[i]);
  if (existing?.status === 'fechada') {
    // Nenhuma partida que ela tem agora começou (a que fechou foi apagada ou
    // mudou de rodada/horário) e não foi o admin que fechou: reabre.
    if (!existing.fechadaManual && computed.fechaEm && computed.fechaEm > now) {
      return {
        numero: computed.numero,
        idsPartidas: computed.idsPartidas,
        fechaEm: computed.fechaEm,
        status: 'aberta',
      };
    }
    return sameIds(existing.idsPartidas, computed.idsPartidas) ? null : { idsPartidas: computed.idsPartidas };
  }
  // Prazo do admin: fica; só as partidas acompanham.
  if (existing?.status === 'aberta' && existing.prazoManual) {
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

/**
 * Rodada gravada que ficou sem partidas (apagadas ou mudadas de rodada):
 * aberta vira `vazia`; fechada fica fechada, sem partidas e `finalizada` (não
 * segura o mercado; os pontos e o histórico ficam). Nulo = nada a gravar.
 */
export function orphanRoundUpdate(round: { status?: string; idsPartidas?: string[]; finalizada?: boolean }): Doc | null {
  const ids = round.idsPartidas ?? [];
  if (round.status === 'aberta') return { status: 'vazia', idsPartidas: [] };
  if (round.status === 'fechada' && (ids.length > 0 || round.finalizada !== true)) {
    return { idsPartidas: [], finalizada: true };
  }
  return null;
}

/**
 * Rodada finalizada: todas as partidas dela que ainda existem terminaram
 * ([existing] = quantas existem, [finished] = quantas terminaram). Partida
 * apagada não segura a rodada; sem nenhuma, finalizada.
 */
export const roundFinalized = (existing: number, finished: number): boolean => finished >= existing;

/** Posições das vagas da escalação, na ordem, e o máximo de cada (iguais às regras e ao app). */
export const FORMATION_SLOTS: ReadonlyArray<[string, number]> = [
  ['gol', 1],
  ['zag', 4],
  ['mei', 4],
  ['ata', 4],
  ['livre', 3],
];
export const FORMATION_MIN = 3;
export const FORMATION_MAX = 7;

/** Quantas vagas de cada posição (`vagas`): gol, zag, mei, ata, livre. */
export type Formation = Record<string, number>;

export const DEFAULT_FORMATION: Formation = { gol: 1, zag: 1, mei: 1, ata: 1, livre: 1 };

/**
 * Formato da escalação lido de `vagas` (do Fantasy ou dos `parametros` da
 * rodada): cada posição inteira na faixa dela e o total de 3 a 7; inválido ou
 * sem o campo = uma vaga de cada (o formato de sempre).
 */
export function fantasyFormation(value: unknown): Formation {
  if (!value || typeof value !== 'object') return { ...DEFAULT_FORMATION };
  const doc = value as Doc;
  const formation: Formation = {};
  let total = 0;
  for (const [key, max] of FORMATION_SLOTS) {
    const count = doc[key];
    if (typeof count !== 'number' || !Number.isInteger(count) || count < 0 || count > max) {
      return { ...DEFAULT_FORMATION };
    }
    formation[key] = count;
    total += count;
  }
  return total >= FORMATION_MIN && total <= FORMATION_MAX ? formation : { ...DEFAULT_FORMATION };
}

/** Chaves das vagas em `atletas`, na ordem: `zag`, `zag2`, `zag3`... */
export function formationKeys(formation: Formation): string[] {
  const keys: string[] = [];
  for (const [slot] of FORMATION_SLOTS) {
    for (let i = 0; i < (formation[slot] ?? 0); i++) keys.push(i === 0 ? slot : `${slot}${i + 1}`);
  }
  return keys;
}

/**
 * Parâmetros congelados na rodada ao fechar (os da configuração naquele
 * momento), com a tabela de pontos (`pontos`): a já congelada em [source]
 * (`parametros` da rodada), a própria do campeonato (`pontuacao`) ou a
 * padrão [globalTable] (`config/pontuacao_fantasy`); sem nenhuma, os padrões.
 */
export function frozenParams(
  source: Doc,
  globalTable?: Doc,
): { minMinutos: number; minMinutosDefesa: number; capitao: number; pontos: Doc; vagas: Formation } {
  const num = (value: unknown, fallback: number) => (typeof value === 'number' && Number.isFinite(value) ? value : fallback);
  const isMap = (value: unknown): value is Doc => !!value && typeof value === 'object';
  const table = isMap(source.pontos) ? source.pontos : isMap(source.pontuacao) ? source.pontuacao : globalTable;
  return {
    minMinutos: num(source.minMinutos, 20),
    minMinutosDefesa: num(source.minMinutosDefesa, 45),
    capitao: num(source.capitao, 1.5),
    pontos: tableToDoc(scoringTable(table)),
    vagas: fantasyFormation(source.vagas),
  };
}

/** Parâmetros congelados ([frozenParams]) para a apuração. */
export function scoringParamsOf(frozen: ReturnType<typeof frozenParams>): ScoringParams {
  return {
    minMinutos: frozen.minMinutos,
    minMinutosDefesa: frozen.minMinutosDefesa,
    capitao: frozen.capitao,
    table: scoringTable(frozen.pontos),
  };
}

/**
 * Cópia da escalação [lineup] para a rodada seguinte (decisão D3), no formato
 * [formation] da rodada que abre (padrão = uma vaga de cada): os atletas das
 * vagas que existem nele e o capitão, marcada `copiada` (o dono troca até o
 * prazo). Formato mudado: vagas novas vazias (''), as que sumiram saem e o
 * capitão que saiu fica vazio; a escalação pontua com quem sobrou. Sem
 * nenhum atleta, nula.
 */
export function lineupCopy(lineup: Doc, formation: Formation = DEFAULT_FORMATION): Doc | null {
  const raw = lineup.atletas;
  if (!raw || typeof raw !== 'object') return null;
  const athletes = raw as Record<string, unknown>;
  const keys = formationKeys(formation);
  const copied: Record<string, string> = {};
  const seen = new Set<string>();
  for (const key of keys) {
    const id = typeof athletes[key] === 'string' ? (athletes[key] as string) : '';
    const unique = id !== '' && !seen.has(id);
    if (unique) seen.add(id);
    copied[key] = unique ? id : '';
  }
  const ids = keys.map((key) => copied[key]).filter((id) => id !== '');
  if (ids.length === 0) return null;
  const captain = String(lineup.capitao ?? '');
  return {
    uid: String(lineup.uid ?? ''),
    nome: String(lineup.nome ?? ''),
    urlImagem: String(lineup.urlImagem ?? ''),
    atletas: copied,
    idsAtletas: ids,
    capitao: ids.includes(captain) ? captain : '',
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

/** O admin pediu "Reapurar rodadas" (`reapurarEm` mudou). */
const stampMillis = (value: unknown): string =>
  value && typeof value === 'object' && 'toMillis' in value
    ? String((value as { toMillis: () => number }).toMillis())
    : String(value ?? '');

export function rescoreRequested(before: Doc | undefined, after: Doc | undefined): boolean {
  return !!after && after.reapurarEm !== undefined && stampMillis(before?.reapurarEm) !== stampMillis(after.reapurarEm);
}

/** Abrir/fechar rodada pelo admin (`acaoRodada`), validada. */
export interface RoundAction {
  numero: number;
  acao: 'abrir' | 'fechar';
  prazo: Date | null;
}

/** "Abrir/Fechar rodada" do admin: `acaoRodada.em` novo ou trocado (nulo = nada a fazer). */
export function roundActionRequested(before: Doc | undefined, after: Doc | undefined): RoundAction | null {
  const action = after?.acaoRodada as Doc | undefined;
  if (!action || typeof action !== 'object') return null;
  const previous = before?.acaoRodada as Doc | undefined;
  if (stampMillis(previous?.em) === stampMillis(action.em)) return null;
  const numero = Number(action.numero);
  const acao = action.acao;
  if (!Number.isInteger(numero) || numero < 1 || (acao !== 'abrir' && acao !== 'fechar')) return null;
  const raw = action.prazo as { toDate?: () => Date } | Date | undefined;
  const prazo = raw instanceof Date ? raw : typeof raw?.toDate === 'function' ? raw.toDate() : null;
  if (acao === 'abrir' && !prazo) return null;
  return { numero, acao, prazo };
}

/** "Zerar pontos de times" do admin: `zerarTimes.em` novo ou trocado → os ids (1 a 10); nulo = nada. */
export function teamsResetRequested(before: Doc | undefined, after: Doc | undefined): string[] | null {
  const request = after?.zerarTimes as Doc | undefined;
  if (!request || typeof request !== 'object') return null;
  const previous = before?.zerarTimes as Doc | undefined;
  if (stampMillis(previous?.em) === stampMillis(request.em)) return null;
  const ids = Array.isArray(request.ids) ? [...new Set(request.ids.map(String).filter(Boolean))] : [];
  return ids.length > 0 && ids.length <= 10 ? ids : null;
}

/** Docs de auditoria da rodada que sobraram: gravados antes e não apurados agora (partida apagada ou trocada). */
export function staleAthleteDocs(existing: string[], scored: Set<string>): string[] {
  return existing.filter((id) => !scored.has(id));
}

/**
 * Escalação sem os pontos dos atletas [removed]: zera os pontos deles,
 * tira de `atletasJogaram` e soma de novo (o capitão já vem multiplicado no
 * `pontosAtletas`). Nulo = nenhum desses atletas pontuou nela.
 */
export function lineupWithoutAthletes(
  lineup: Doc,
  removed: Set<string>,
): { pontos: number; pontosAtletas: Record<string, number>; atletasJogaram: string[] } | null {
  const points = (lineup.pontosAtletas ?? {}) as Record<string, unknown>;
  const played = Array.isArray(lineup.atletasJogaram) ? lineup.atletasJogaram.map(String) : [];
  const hit = Object.keys(points).some((id) => removed.has(id)) || played.some((id) => removed.has(id));
  if (!hit) return null;
  const pontosAtletas: Record<string, number> = {};
  for (const [id, value] of Object.entries(points)) {
    pontosAtletas[id] = removed.has(id) ? 0 : typeof value === 'number' && Number.isFinite(value) ? value : 0;
  }
  const pontos = Math.round(Object.values(pontosAtletas).reduce((sum, v) => sum + v, 0) * 100) / 100;
  return { pontos, pontosAtletas, atletasJogaram: played.filter((id) => !removed.has(id)) };
}

/** "Zerar pontuações (testes)" do admin: `zerarEm` novo ou trocado. */
export function resetRequested(before: Doc | undefined, after: Doc | undefined): boolean {
  return !!after && after.zerarEm !== undefined && stampMillis(before?.zerarEm) !== stampMillis(after.zerarEm);
}
