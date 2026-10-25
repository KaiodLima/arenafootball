/**
 * Card automático de resultado: quando a partida termina (pelo horário +
 * duração, ou encerrada pelo admin), uma notícia `tag: "resultado"` com o
 * placar e um título/texto escolhidos das frases abaixo. Funções puras
 * (testes em test/match_result.test.ts); quem grava é o index.ts.
 */
import { matchEnd } from './voting_close';

type Doc = Record<string, unknown>;

const text = (value: unknown): string => (value === undefined || value === null ? '' : String(value).trim());
const int = (value: unknown): number => {
  const n = Number.parseInt(text(value), 10);
  return Number.isFinite(n) ? n : 0;
};

export const RESULT_TAG = 'resultado';

/** Id do card de resultado da partida (um por partida). */
export const resultNewsId = (matchId: string): string => `resultado_${matchId}`;

export type ResultGroup = 'vitoria' | 'goleada' | 'empate' | 'zero';

// Variáveis: {vencedor} {perdedor} {gv} {gp} (vitória/goleada) e {casa} {fora}
// {gc} {gf} {total} (empates). Sem artigo antes do nome do time.
const TITLES: Record<ResultGroup, string[]> = {
  vitoria: [
    'Apita o árbitro: {vencedor} vence {perdedor}',
    'Fim de jogo: {vencedor} {gv} × {gp} {perdedor}',
    '{vencedor} leva a melhor sobre {perdedor}',
    '{vencedor} bate {perdedor} por {gv} a {gp}',
    'Deu {vencedor}!',
    '{vencedor} supera {perdedor} e soma três pontos',
    'Três pontos para {vencedor}',
    '{vencedor} vence e deixa {perdedor} para trás',
    'Festa de {vencedor}: {gv} a {gp} no placar',
    '{vencedor} sai de campo com a vitória',
    '{perdedor} não segura {vencedor}',
    'É de {vencedor}! Vitória por {gv} a {gp}',
    '{vencedor} garante a vitória contra {perdedor}',
    '{vencedor} conquista a vitória diante de {perdedor}',
    'Vitória com gosto especial para {vencedor}',
    '{vencedor} faz a festa da torcida',
    '{vencedor} vence o duelo contra {perdedor}',
    'Placar final: {vencedor} {gv}, {perdedor} {gp}',
    '{vencedor} derrota {perdedor} e comemora',
    'Missão cumprida para {vencedor}',
  ],
  goleada: [
    'Goleada! {vencedor} {gv} × {gp} {perdedor}',
    '{vencedor} atropela {perdedor}',
    'Show de gols: {vencedor} massacra {perdedor}',
    '{vencedor} não toma conhecimento de {perdedor}',
    'Chuva de gols para {vencedor}',
    '{vencedor} passeia em campo e vence por {gv} a {gp}',
    'Placar elástico: {vencedor} {gv} × {gp} {perdedor}',
    '{vencedor} aplica goleada em {perdedor}',
    'Ataque inspirado: {vencedor} marca {gv} vezes',
    '{vencedor} dá show e goleia {perdedor}',
  ],
  empate: [
    'Empate: {casa} {gc} × {gf} {fora}',
    '{casa} e {fora} ficam no {gc} a {gf}',
    'Tudo igual entre {casa} e {fora}',
    'Ninguém sai vencedor: {gc} a {gf}',
    '{casa} e {fora} dividem os pontos',
    'Empate movimentado entre {casa} e {fora}',
    'Igualdade no placar: {casa} {gc} × {gf} {fora}',
    'Fim de jogo com empate em {gc} a {gf}',
    '{casa} e {fora} não se vencem',
    'Cada um com seu ponto: {casa} {gc} × {gf} {fora}',
    'Empate com gols entre {casa} e {fora}',
    'Duelo equilibrado termina empatado',
    '{casa} e {fora} empatam por {gc} a {gf}',
  ],
  zero: [
    'Sem gols: {casa} 0 × 0 {fora}',
    '{casa} e {fora} ficam no zero a zero',
    'Empate sem gols entre {casa} e {fora}',
    'Placar zerado no duelo entre {casa} e {fora}',
    'As defesas venceram: 0 × 0',
    '{casa} e {fora} não saem do zero',
    'Zero a zero entre {casa} e {fora}',
    'Jogo truncado termina sem gols',
    'Ninguém marca: {casa} 0 × 0 {fora}',
    'Empate sem gols e um ponto para cada',
  ],
};

const DESCRIPTIONS: Record<ResultGroup, string[]> = {
  vitoria: [
    'Apita o árbitro! Final de jogo. {vencedor} bate {perdedor} pelo placar de {gv} a {gp} e sai de campo com os três pontos.',
    'Fim de papo! {vencedor} venceu {perdedor} por {gv} a {gp} em uma partida disputada do começo ao fim.',
    'Acabou! Com {gv} gols marcados contra {gp} do adversário, {vencedor} levou a melhor sobre {perdedor}.',
    '{vencedor} fez valer a vontade de vencer e superou {perdedor} por {gv} a {gp}. Os três pontos ficam com quem foi mais eficiente.',
    'Bola parada no centro do campo e festa de um lado só: {vencedor} {gv} × {gp} {perdedor}.',
    'Jogo encerrado! {perdedor} até tentou, mas {vencedor} foi melhor e venceu por {gv} a {gp}.',
    'Três pontos na conta de {vencedor}, que venceu {perdedor} por {gv} a {gp} e deixou a torcida feliz.',
    'O árbitro encerra a partida e o placar não deixa dúvidas: {vencedor} {gv}, {perdedor} {gp}.',
    'Partida movimentada, e quem comemorou no fim foi {vencedor}: vitória por {gv} a {gp} sobre {perdedor}.',
    '{vencedor} soube aproveitar as chances, marcou {gv} vezes e venceu {perdedor}, que fez {gp}.',
    'Final de jogo! {vencedor} confirmou a vitória diante de {perdedor} com o placar de {gv} a {gp}.',
    'A torcida de {vencedor} tem motivo para comemorar: vitória por {gv} a {gp} sobre {perdedor}.',
    '{perdedor} vendeu caro a derrota, mas {vencedor} segurou o resultado e venceu por {gv} a {gp}.',
    'Apito final! Em campo, {vencedor} foi superior e bateu {perdedor} por {gv} a {gp}.',
    'Vitória construída com garra: {vencedor} {gv} × {gp} {perdedor}. Agora é pensar no próximo desafio.',
    '{vencedor} sai de campo com sorriso no rosto depois de vencer {perdedor} por {gv} a {gp}.',
    'Encerrada a partida: {vencedor} venceu, {perdedor} perdeu e o placar marcou {gv} a {gp}.',
    'Quem viu, viu! {vencedor} superou {perdedor} por {gv} a {gp} em um jogo cheio de emoção.',
    'Resultado final: {vencedor} {gv} × {gp} {perdedor}. Os três pontos foram para quem balançou mais as redes.',
    'Mais um capítulo escrito no futebol da região: {vencedor} venceu {perdedor} por {gv} a {gp}.',
  ],
  goleada: [
    'Apita o árbitro! Final de jogo e goleada: {vencedor} passou por cima de {perdedor} e venceu por {gv} a {gp}.',
    'Não teve para ninguém! {vencedor} balançou as redes {gv} vezes e goleou {perdedor} por {gv} a {gp}.',
    'Atuação de gala de {vencedor}, que aplicou {gv} a {gp} em {perdedor} e deu show para a torcida.',
    'Placar elástico no fim da partida: {vencedor} {gv} × {gp} {perdedor}. Um jogo para ficar na memória.',
    '{perdedor} não conseguiu conter o ataque de {vencedor}, que marcou {gv} gols e venceu com sobras.',
    'Foi um verdadeiro passeio: {vencedor} dominou a partida e goleou {perdedor} por {gv} a {gp}.',
    'Chuva de gols! {vencedor} venceu {perdedor} por {gv} a {gp} e mandou um recado para os adversários.',
    'Acabou! Com um ataque inspirado, {vencedor} construiu a goleada de {gv} a {gp} sobre {perdedor}.',
    '{vencedor} não deu chances: {gv} a {gp} sobre {perdedor}, numa atuação dominante do início ao fim.',
    'O placar diz tudo: {vencedor} {gv}, {perdedor} {gp}. Goleada para a torcida comemorar.',
  ],
  empate: [
    'Apita o árbitro! Final de jogo. {casa} e {fora} empataram por {gc} a {gf} e cada equipe leva um ponto.',
    'Ninguém conseguiu sair na frente de vez: {casa} {gc} × {gf} {fora}, empate justo pelo que se viu em campo.',
    'Jogo equilibrado do início ao fim, e o placar refletiu isso: {casa} e {fora} ficaram no {gc} a {gf}.',
    'Foi gol de lá, gol de cá, e no fim ninguém venceu: {casa} {gc}, {fora} {gf}.',
    'Fim de jogo! {casa} e {fora} dividiram os pontos em um empate por {gc} a {gf}.',
    'As duas equipes balançaram as redes, mas ninguém conseguiu desempatar: {gc} a {gf} entre {casa} e {fora}.',
    'Empate com emoção! {casa} e {fora} terminaram a partida em {gc} a {gf}.',
    'Acabou em igualdade: {casa} {gc} × {gf} {fora}. Um ponto para cada lado.',
    'Partida disputada e placar igual no apito final: {casa} e {fora} empataram por {gc} a {gf}.',
    '{casa} e {fora} fizeram um jogo aberto, com {total} gols, e terminaram empatados.',
    'O árbitro encerra a partida com o placar empatado em {gc} a {gf} entre {casa} e {fora}.',
    'Nenhuma das equipes saiu derrotada: {casa} {gc} × {gf} {fora}. Agora é pensar no próximo jogo.',
    'Empate na conta: {casa} e {fora} ficaram no {gc} a {gf} e somam um ponto cada.',
  ],
  zero: [
    'Apita o árbitro! Final de jogo. {casa} e {fora} não saíram do zero e dividiram os pontos.',
    'As defesas levaram a melhor: {casa} e {fora} empataram sem gols.',
    'Jogo amarrado do começo ao fim, e o placar ficou zerado entre {casa} e {fora}.',
    'Faltou a bola na rede: {casa} 0 × 0 {fora}. Um ponto para cada equipe.',
    'Fim de jogo sem gols! {casa} e {fora} criaram, mas os goleiros e as defesas foram melhores.',
    'Empate sem gols entre {casa} e {fora} em uma partida de muita marcação.',
    'O zero a zero foi o resultado final do duelo entre {casa} e {fora}.',
    'Ninguém conseguiu furar o bloqueio: {casa} e {fora} terminaram empatados sem gols.',
    'Acabou sem gols: {casa} 0 × 0 {fora}. As duas equipes seguem em busca da vitória no próximo jogo.',
    'Partida equilibrada e sem gols: {casa} e {fora} ficam no 0 a 0.',
  ],
};

/** Todas as frases (para os testes conferirem as variáveis). */
export const ALL_TEMPLATES = { titles: TITLES, descriptions: DESCRIPTIONS };

export function resultGroup(home: number, away: number): ResultGroup {
  if (home === away) return home === 0 ? 'zero' : 'empate';
  return Math.abs(home - away) >= 3 ? 'goleada' : 'vitoria';
}

/** Índice estável pelo id da partida (a mesma frase ao atualizar o card). */
export function pickIndex(seed: string, length: number): number {
  let hash = 0;
  for (const char of seed) hash = (hash * 31 + char.charCodeAt(0)) >>> 0;
  return length === 0 ? 0 : hash % length;
}

export function fillTemplate(template: string, vars: Record<string, string | number>): string {
  return template.replace(/\{(\w+)\}/g, (match, key: string) => (key in vars ? String(vars[key]) : match));
}

/** "Gols: Dudu (2), Rafa · Ana" pela lista `gols` (casa · fora); vazio sem autor. */
export function scorersLine(match: Doc): string {
  const goals = Array.isArray(match.gols) ? (match.gols as Doc[]) : [];
  const side = (key: string): string => {
    const counts = new Map<string, number>();
    for (const goal of goals) {
      const name = text(goal.jogador);
      if (text(goal.lado) !== key || !text(goal.idJogador) || !name) continue;
      counts.set(name, (counts.get(name) ?? 0) + 1);
    }
    return [...counts].map(([name, n]) => (n > 1 ? `${name} (${n})` : name)).join(', ');
  };
  const parts = [side('casa'), side('fora')].filter((part) => part.length > 0);
  return parts.length ? `Gols: ${parts.join(' · ')}` : '';
}

/** Título e texto do card (frase do grupo + gols, competição e local). */
export function resultTexts(match: Doc, matchId: string, championshipTitle = ''): { titulo: string; descricao: string } {
  const home = text(match.timeC);
  const away = text(match.timeF);
  const gc = int(match.golTimeCasa);
  const gf = int(match.golTimeFora);
  const group = resultGroup(gc, gf);
  const homeWon = gc > gf;
  const vars = {
    casa: home,
    fora: away,
    gc,
    gf,
    total: gc + gf,
    vencedor: homeWon ? home : away,
    perdedor: homeWon ? away : home,
    gv: Math.max(gc, gf),
    gp: Math.min(gc, gf),
  };
  const titles = TITLES[group];
  const descriptions = DESCRIPTIONS[group];
  const extras = [
    scorersLine(match),
    int(match.id_campeonato) > 0 ? (championshipTitle ? `Competição: ${championshipTitle}` : '') : 'Amistoso',
    text(match.local) ? `Local: ${text(match.local)}` : '',
  ].filter((line) => line.length > 0);
  return {
    titulo: fillTemplate(titles[pickIndex(matchId, titles.length)], vars),
    descricao: [fillTemplate(descriptions[pickIndex(`${matchId}#texto`, descriptions.length)], vars), ...extras].join(
      '\n\n',
    ),
  };
}

/** Escudo e cor de um time (`times{ano}`); vazios se não achar. */
export interface ResultTeam {
  crest: string;
  color: string;
}

/** Campos do card de resultado (sem a `data`, gravada com a hora do servidor). */
export function resultNews(
  match: Doc,
  matchId: string,
  season: string,
  options: { home?: ResultTeam; away?: ResultTeam; championshipTitle?: string } = {},
): Doc {
  const { titulo, descricao } = resultTexts(match, matchId, options.championshipTitle);
  return {
    id: resultNewsId(matchId),
    titulo,
    descricao,
    urlImagem: '',
    link: '',
    exibir: 'true',
    tag: RESULT_TAG,
    time_casa: text(match.timeC),
    time_fora: text(match.timeF),
    id_time_casa: text(match.idTimeC),
    id_time_fora: text(match.idTimeF),
    gol_time_casa: String(int(match.golTimeCasa)),
    gol_time_fora: String(int(match.golTimeFora)),
    escudo_casa: options.home?.crest ?? '',
    escudo_fora: options.away?.crest ?? '',
    cor_casa: options.home?.color ?? '',
    cor_fora: options.away?.color ?? '',
    id_partida: matchId,
    temporada: season,
    id_campeonato: int(match.id_campeonato),
    campeonato: options.championshipTitle ?? '',
    fk_competicao: text(match.fk_competicao),
    ...(text(match.idRegiao) ? { idRegiao: text(match.idRegiao) } : {}),
  };
}

/** A partida acabou: encerrada pelo admin, ou passou do horário + duração (sem estar iniciada na mão). */
export function isMatchOver(match: Doc, season: string, now: Date = new Date()): boolean {
  const status = text(match.status);
  if (status === 'encerrada') return true;
  // Em andamento ou no intervalo (marcados pelo admin): ainda não acabou.
  if (status === 'andamento' || status === 'intervalo') return false;
  const end = matchEnd(match, season, now);
  return end !== null && now.getTime() >= end.getTime();
}

/** Ainda sem card e já acabou. */
export function shouldPostResult(match: Doc, season: string, now: Date = new Date()): boolean {
  return !text(match.resultadoNoticia) && isMatchOver(match, season, now);
}

/** Placar ou gols mudaram (o card já postado precisa acompanhar). */
export function resultChanged(before: Doc, after: Doc): boolean {
  return (
    int(before.golTimeCasa) !== int(after.golTimeCasa) ||
    int(before.golTimeFora) !== int(after.golTimeFora) ||
    JSON.stringify(before.gols ?? []) !== JSON.stringify(after.gols ?? [])
  );
}

/** "dd/MM" de hoje e de ontem em Brasília (partidas que podem ter acabado). */
export function recentDays(now: Date = new Date()): string[] {
  const key = (date: Date) => {
    const brasilia = new Date(date.getTime() - 3 * 3_600_000);
    const two = (n: number) => String(n).padStart(2, '0');
    return `${two(brasilia.getUTCDate())}/${two(brasilia.getUTCMonth() + 1)}`;
  };
  return [key(now), key(new Date(now.getTime() - 24 * 3_600_000))];
}
