/**
 * Ranking de torcidas: monta a lista gravada em `ranking_torcidas/{temporada}`
 * a partir dos times da temporada e das contagens de torcedores (feitas com
 * `count()` em `usuarios`). Funções puras, testadas em `test/fan_ranking.test.ts`.
 */
type Doc = Record<string, unknown>;

const text = (value: unknown): string => (value === undefined || value === null ? '' : String(value).trim());

export interface FanRankingTeam {
  id: string;
  nome: string;
  idRegiao: string;
  regiao: string;
  urlImagem: string;
  corPrimaria: string;
  corSecundaria: string;
  torcedores: number;
}

/** Dados do time que vão para o ranking (o vínculo é o id do doc). */
export function rankingTeamOf(id: string, data: Doc, fans: number): FanRankingTeam {
  return {
    id,
    nome: text(data.nome),
    idRegiao: text(data.idRegiao),
    regiao: text(data.fk_competicao),
    urlImagem: text(data.urlImagem),
    corPrimaria: text(data.corPrimaria),
    corSecundaria: text(data.corSecundaria),
    torcedores: Number.isFinite(fans) && fans > 0 ? Math.floor(fans) : 0,
  };
}

/** Mais torcedores primeiro; empate (e os zerados) em ordem alfabética. */
export function sortFanRanking(teams: FanRankingTeam[]): FanRankingTeam[] {
  return [...teams]
    .filter((team) => team.nome !== '')
    .sort((a, b) => b.torcedores - a.torcedores || a.nome.localeCompare(b.nome, 'pt-BR'));
}

/** Total de torcedores contados (para a porcentagem no app). */
export function fanRankingTotal(teams: FanRankingTeam[]): number {
  return teams.reduce((sum, team) => sum + team.torcedores, 0);
}
