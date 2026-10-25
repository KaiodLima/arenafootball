/**
 * Card "Vote no craque": ~15 min antes do fim da partida (ou quando o admin
 * encerra), uma notícia `tag: "votacao"` que leva à votação do melhor jogador
 * (o index.ts abre a votação se estiver fechada). Funções puras (testes em
 * test/vote_card.test.ts).
 */
import { fillTemplate, pickIndex, ResultTeam } from './match_result';
import { matchEnd } from './voting_close';

type Doc = Record<string, unknown>;

const text = (value: unknown): string => (value === undefined || value === null ? '' : String(value).trim());
const int = (value: unknown): number => {
  const n = Number.parseInt(text(value), 10);
  return Number.isFinite(n) ? n : 0;
};

export const VOTE_TAG = 'votacao';

/** Minutos antes do fim em que o card sobe. */
export const VOTE_CARD_LEAD_MINUTES = 15;

/** Depois disto (horas após o fim), não posta mais: o jogo já ficou para trás. */
export const VOTE_CARD_STALE_HOURS = 3;

export const voteNewsId = (matchId: string): string => `votacao_${matchId}`;

// Variáveis: {casa} {fora}.
const TITLES = [
  'Quem foi o craque de {casa} × {fora}?',
  'Vote no melhor em campo!',
  'Escolha o craque do jogo',
  'Quem merece o troféu de melhor da partida?',
  'A votação do craque está aberta!',
  '{casa} × {fora}: quem jogou mais?',
  'Seu voto elege o craque da partida',
  'Hora de escolher o melhor jogador',
  'Quem brilhou em {casa} × {fora}?',
  'Eleja o craque da galera',
];

const DESCRIPTIONS = [
  'A partida está chegando ao fim. Escolha o craque do jogo entre {casa} e {fora} e ajude a eleger o melhor em campo!',
  'Quem fez a diferença em {casa} × {fora}? Dê o seu voto e escolha o melhor jogador da partida.',
  'A votação de melhor jogador de {casa} × {fora} está aberta. Toque e escolha o seu craque!',
  'Seu voto conta! Escolha quem foi o destaque do duelo entre {casa} e {fora}.',
  'Reta final de jogo entre {casa} e {fora}. Quem merece o título de craque da partida? Vote agora!',
  'A torcida decide: escolha o melhor em campo em {casa} × {fora} e acompanhe o resultado da votação.',
  'Golaço, defesa ou assistência: quem jogou mais em {casa} × {fora}? Vote no craque do jogo.',
  'Participe da eleição do craque da partida entre {casa} e {fora}. Leva só um toque!',
  'É hora de reconhecer quem brilhou: vote no melhor jogador de {casa} × {fora}.',
  'Ajude a escolher o craque de {casa} × {fora}. O mais votado leva o troféu de melhor da partida!',
];

export const ALL_VOTE_TEMPLATES = { titles: TITLES, descriptions: DESCRIPTIONS };

export function voteTexts(match: Doc, matchId: string): { titulo: string; descricao: string } {
  const vars = { casa: text(match.timeC), fora: text(match.timeF) };
  return {
    titulo: fillTemplate(TITLES[pickIndex(`${matchId}#voto`, TITLES.length)], vars),
    descricao: fillTemplate(DESCRIPTIONS[pickIndex(`${matchId}#votoTexto`, DESCRIPTIONS.length)], vars),
  };
}

/** Campos do card de votação (sem a `data`, gravada com a hora do servidor). */
export function voteCardNews(
  match: Doc,
  matchId: string,
  season: string,
  options: { home?: ResultTeam; away?: ResultTeam; championshipTitle?: string } = {},
): Doc {
  const { titulo, descricao } = voteTexts(match, matchId);
  return {
    id: voteNewsId(matchId),
    titulo,
    descricao,
    urlImagem: '',
    link: '',
    exibir: 'true',
    tag: VOTE_TAG,
    votacao: 'true',
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

/**
 * Posta agora: ainda sem card, e a partida a 15 min do fim (pelo horário +
 * duração) ou encerrada pelo admin. Muito depois do fim (jogo antigo), não.
 */
export function shouldPostVoteCard(match: Doc, season: string, now: Date = new Date()): boolean {
  if (text(match.votacaoNoticia)) return false;
  const end = matchEnd(match, season, now);
  if (end && now.getTime() > end.getTime() + VOTE_CARD_STALE_HOURS * 3_600_000) return false;
  if (text(match.status) === 'encerrada') return true;
  return end !== null && now.getTime() >= end.getTime() - VOTE_CARD_LEAD_MINUTES * 60_000;
}
