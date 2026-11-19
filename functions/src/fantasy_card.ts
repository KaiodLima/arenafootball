/**
 * Card "Craques da rodada" do Arena Fantasy (`noticias/fantasy_<idDoc>_r<n>`,
 * tag `fantasy`): os 3 atletas que mais pontuaram na rodada, postado quando a
 * rodada fica finalizada (todas as partidas terminadas e apuradas). Funções
 * puras (testes em test/fantasy_card.test.ts).
 */

import { PushMessage, regionIdTopic, regionTopicOf, targetFor } from './messages';

type Doc = Record<string, unknown>;

export const FANTASY_TAG = 'fantasy';

export const fantasyRoundNewsId = (fantasyId: string, round: number): string => `fantasy_${fantasyId}_r${round}`;

const text = (value: unknown): string => (value === undefined || value === null ? '' : String(value).trim());

/** Atleta apurado na rodada (o que o card mostra). */
export interface FantasyCardAthlete {
  idJogador: string;
  nome: string;
  time: string;
  idTime: string;
  urlImagem: string;
  /** `gol`/`zag`/`mei`/`ata` (vazio = sem posição). */
  posicao: string;
  pontos: number;
}

export interface FantasyTopAthlete extends FantasyCardAthlete {
  /** Colocação (empate no total = a mesma). */
  colocacao: number;
}

/**
 * Os 3 de maior total com pontos (> 0): total desc e, no empate, o nome.
 * Empate no total = mesma colocação. Nenhum com pontos = lista vazia.
 */
export function fantasyTopThree(athletes: FantasyCardAthlete[]): FantasyTopAthlete[] {
  const sorted = athletes
    .filter((a) => a.pontos > 0)
    .sort((a, b) => b.pontos - a.pontos || a.nome.localeCompare(b.nome, 'pt-BR'))
    .slice(0, 3);
  const top: FantasyTopAthlete[] = [];
  sorted.forEach((a, i) => {
    const colocacao = i > 0 && a.pontos === sorted[i - 1].pontos ? top[i - 1].colocacao : i + 1;
    top.push({ ...a, colocacao });
  });
  return top;
}

/** "22" / "7,5" (pontos com 1 casa só quando houver). */
export function fantasyPointsText(points: number): string {
  const rounded = Math.round(points * 10) / 10;
  return Number.isInteger(rounded) ? String(rounded) : String(rounded).replace('.', ',');
}

/** Doc do card (sem a `data`, que é a hora do servidor na criação). */
export function fantasyRoundNews(fantasyId: string, config: Doc, round: number, top: FantasyTopAthlete[]): Doc | null {
  if (top.length === 0 || round <= 0) return null;
  const title = text(config.titulo);
  const regionIds = Array.isArray(config.idsRegioes) ? config.idsRegioes.map(text).filter(Boolean) : [];
  const id = Number(config.idCampeonato);
  const podium = top.map((a) => `${a.colocacao}º ${a.nome} (${fantasyPointsText(a.pontos)} pts)`).join(' · ');
  return {
    id: fantasyRoundNewsId(fantasyId, round),
    tag: FANTASY_TAG,
    exibir: 'true',
    titulo: `⭐ Craques da rodada ${round}${title ? ` · ${title}` : ''}`,
    descricao: `Arena Fantasy${title ? ` · ${title}` : ''}: ${podium}.`,
    urlImagem: text(config.urlImagem),
    link: '',
    fk_competicao: text(config.fk_competicao),
    ...(text(config.idRegiao) ? { idRegiao: text(config.idRegiao) } : {}),
    ...(regionIds.length > 1 ? { idsRegioes: regionIds } : {}),
    campeonato: title,
    ...(id > 0 ? { id_campeonato: id } : {}),
    id_campeonato_doc: fantasyId,
    temporada: text(config.temporada),
    rodada: round,
    craques_fantasy: top.map((a) => ({ ...a })),
  };
}

/** Push: a região-sede e, na intermunicipal, as outras regiões (até 5 tópicos). */
export function fantasyRoundMessage(news: Doc): PushMessage | null {
  const list = Array.isArray(news.craques_fantasy) ? (news.craques_fantasy as Doc[]) : [];
  const round = Number(news.rodada) || 0;
  if (list.length === 0 || round <= 0) return null;
  const others = (Array.isArray(news.idsRegioes) ? news.idsRegioes.map(text) : [])
    .filter((id) => id && id !== text(news.idRegiao))
    .map(regionIdTopic);
  const alvo = targetFor([regionTopicOf(news), ...others]);
  if (!alvo) return null;
  const title = text(news.campeonato);
  const first = text(list[0].urlImagem);
  return {
    tipo: 'fantasy_rodada',
    titulo: `⭐ Craques da rodada ${round}!`,
    corpo: `${title ? `${title}: ` : ''}${list
      .map((a) => `${Number(a.colocacao) || 0}º ${text(a.nome)} (${fantasyPointsText(Number(a.pontos) || 0)} pts)`)
      .join(', ')}. Veja no Arena Fantasy!`,
    aba: 'home',
    regiao: text(news.fk_competicao),
    alvo,
    ...(first.startsWith('https://') ? { imagem: first } : {}),
  };
}
