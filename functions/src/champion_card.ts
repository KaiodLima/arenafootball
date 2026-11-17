/**
 * Card de campeão (`noticias/campeao_<idDoc>`, tag `campeao`): postado quando
 * o admin ou o organizador encerra a competição (`campeonatos.encerrado`) com
 * o campeão; reaberta, o card fica oculto. Funções puras (testes em
 * test/champion_card.test.ts).
 *
 * Campos do card no app (`ChampionCard`): campeão em `time_casa`/`escudo_casa`/
 * `cor_casa`/`id_time_casa`, vice em `time_fora`/`escudo_fora`/`id_time_fora`,
 * competição em `campeonato`/`id_campeonato`/`id_campeonato_doc`/`urlImagem`.
 */

import { PushMessage, regionIdTopic, regionTopicOf, targetFor, teamTopics } from './messages';

type Doc = Record<string, unknown>;

export const CHAMPION_TAG = 'campeao';

export const championNewsId = (championshipDocId: string): string => `campeao_${championshipDocId}`;

const text = (value: unknown): string => (value === undefined || value === null ? '' : String(value).trim());

/** Pódio gravado no campeonato (`campeao`/`vice`). */
export interface PodiumTeam {
  idTime: string;
  nome: string;
  urlImagem: string;
  corPrimaria: string;
}

export function podiumOf(raw: unknown): PodiumTeam | null {
  if (!raw || typeof raw !== 'object') return null;
  const data = raw as Doc;
  const nome = text(data.nome);
  if (!nome) return null;
  return {
    idTime: text(data.idTime),
    nome,
    urlImagem: text(data.urlImagem),
    corPrimaria: text(data.corPrimaria),
  };
}

/** O que mudou no encerramento: encerrou (com campeão), reabriu ou nada. */
export function championChange(before: Doc, after: Doc): 'closed' | 'reopened' | null {
  const was = before.encerrado === true;
  const is = after.encerrado === true;
  if (!was && is && podiumOf(after.campeao)) return 'closed';
  if (was && !is) return 'reopened';
  return null;
}

/** Doc do card (sem a `data`, que é a hora do servidor). */
export function championNews(championshipDocId: string, champ: Doc): Doc | null {
  const champion = podiumOf(champ.campeao);
  if (!champion) return null;
  const runnerUp = podiumOf(champ.vice);
  const title = text(champ.titulo);
  const regionIds = Array.isArray(champ.idsRegioes) ? champ.idsRegioes.map(text).filter(Boolean) : [];
  const id = Number(champ.id_campeonato);
  return {
    id: championNewsId(championshipDocId),
    tag: CHAMPION_TAG,
    exibir: 'true',
    titulo: title ? `🏆 ${champion.nome} é campeão · ${title}` : `🏆 ${champion.nome} é campeão!`,
    descricao: `${title ? `${title}: ` : ''}${champion.nome} conquistou o título.${runnerUp ? ` Vice: ${runnerUp.nome}.` : ''}`,
    urlImagem: text(champ.urlImagem),
    link: '',
    fk_competicao: text(champ.fk_competicao),
    ...(text(champ.idRegiao) ? { idRegiao: text(champ.idRegiao) } : {}),
    ...(regionIds.length > 1 ? { idsRegioes: regionIds } : {}),
    campeonato: title,
    ...(id > 0 ? { id_campeonato: id } : {}),
    id_campeonato_doc: championshipDocId,
    temporada: text(champ.ano),
    time_casa: champion.nome,
    id_time_casa: champion.idTime,
    escudo_casa: champion.urlImagem,
    cor_casa: champion.corPrimaria,
    ...(runnerUp
      ? { time_fora: runnerUp.nome, id_time_fora: runnerUp.idTime, escudo_fora: runnerUp.urlImagem }
      : {}),
  };
}

/**
 * Push do campeão: a região-sede, a torcida do campeão e, na intermunicipal,
 * as outras regiões (até o limite de 5 tópicos da condition).
 */
export function championMessage(champ: Doc): PushMessage | null {
  const champion = podiumOf(champ.campeao);
  if (!champion) return null;
  const title = text(champ.titulo);
  const home = regionTopicOf(champ);
  const others = (Array.isArray(champ.idsRegioes) ? champ.idsRegioes.map(text) : [])
    .filter((id) => id && id !== text(champ.idRegiao))
    .map(regionIdTopic);
  const alvo = targetFor([home, ...teamTopics(champion.nome, champion.idTime), ...others]);
  if (!alvo) return null;
  const image = champion.urlImagem.startsWith('https://') ? { imagem: champion.urlImagem } : {};
  return {
    tipo: 'campeao',
    titulo: `🏆 ${champion.nome} é campeão!`,
    corpo: `${title ? `${title}: ` : ''}${champion.nome} conquistou o título. Parabéns, torcida!`,
    aba: 'home',
    regiao: text(champ.fk_competicao),
    alvo,
    ...image,
  };
}
