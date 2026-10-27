/**
 * Classificação automática: tabela de um grupo calculada das partidas do
 * campeonato entre times do grupo, com o desempate escolhido no campeonato.
 * Funções puras (testes em test/standings.test.ts); quem lê e grava é o index.ts.
 */

type Doc = Record<string, unknown>;

const text = (value: unknown): string => (value === undefined || value === null ? '' : String(value).trim());
const int = (value: unknown): number => {
  const n = Number.parseInt(text(value), 10);
  return Number.isFinite(n) ? n : 0;
};

/** Nome comparável (sem acento, caixa e espaços extras), para docs antigos sem id. */
const nameKey = (value: unknown): string =>
  text(value)
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/\s+/g, ' ');

export const POINTS = { win: 3, draw: 1 } as const;

/** Critérios de desempate (depois dos pontos), na ordem gravada em `campeonatos.desempate`. */
export const CRITERIA = ['vitorias', 'saldo', 'golsPro', 'confronto', 'menosGolsContra'] as const;
export type Criterion = (typeof CRITERIA)[number];

/** Sem `desempate` no campeonato: vitórias, saldo e gols pró. */
export const DEFAULT_CRITERIA: Criterion[] = ['vitorias', 'saldo', 'golsPro'];

/** Critérios válidos do campo (sem repetidos); vazio ou inválido = o padrão. */
export function criteriaOf(value: unknown): Criterion[] {
  if (!Array.isArray(value)) return [...DEFAULT_CRITERIA];
  const list: Criterion[] = [];
  for (const item of value) {
    const key = text(item) as Criterion;
    if ((CRITERIA as readonly string[]).includes(key) && !list.includes(key)) list.push(key);
  }
  return list.length ? list : [...DEFAULT_CRITERIA];
}

export interface GroupTeam {
  id: string;
  name: string;
}

/** Times do grupo (`time1-4` / `idTime1-4`), sem as vagas vazias. */
export function groupTeams(group: Doc): GroupTeam[] {
  const teams: GroupTeam[] = [];
  for (let i = 1; i <= 4; i++) {
    const id = text(group[`idTime${i}`]);
    const name = text(group[`time${i}`]);
    if (id || name) teams.push({ id, name });
  }
  return teams;
}

/** Grupo calculado automaticamente: só os ligados a um campeonato. */
export const groupChampionshipId = (group: Doc): number => int(group.fk_campeonato);

/** Índice do time no grupo: pelo id; doc antigo sem id, pelo nome. */
export function teamIndex(teams: GroupTeam[], id: unknown, name: unknown): number {
  const teamId = text(id);
  if (teamId) {
    const byId = teams.findIndex((t) => t.id === teamId);
    if (byId >= 0) return byId;
  }
  const key = nameKey(name);
  return key ? teams.findIndex((t) => (!t.id || !teamId) && nameKey(t.name) === key) : -1;
}

/** Partida terminada: encerrada pelo admin ou com o card de resultado já postado (fim pelo horário). */
export const isFinishedMatch = (match: Doc): boolean => text(match.status) === 'encerrada' || !!text(match.resultadoNoticia);

/** Ids/nomes dos dois times da partida (para achar os grupos a recalcular). */
export const matchTeams = (match: Doc): GroupTeam[] => [
  { id: text(match.idTimeC), name: text(match.timeC) },
  { id: text(match.idTimeF), name: text(match.timeF) },
];

interface Game {
  home: number;
  away: number;
  homeGoals: number;
  awayGoals: number;
}

/** Jogos do grupo: terminados, do campeonato, entre dois times diferentes do grupo. */
export function groupGames(teams: GroupTeam[], matches: Doc[], championshipId: number): Game[] {
  const games: Game[] = [];
  for (const match of matches) {
    if (int(match.id_campeonato) !== championshipId || !isFinishedMatch(match)) continue;
    const home = teamIndex(teams, match.idTimeC, match.timeC);
    const away = teamIndex(teams, match.idTimeF, match.timeF);
    if (home < 0 || away < 0 || home === away) continue;
    games.push({ home, away, homeGoals: int(match.golTimeCasa), awayGoals: int(match.golTimeFora) });
  }
  return games;
}

export interface TableRow {
  idTime: string;
  nome: string;
  posicao: number;
  jogos: number;
  vitorias: number;
  empates: number;
  derrotas: number;
  golsPro: number;
  golsContra: number;
  saldo: number;
  pontos: number;
}

function statsOf(teamCount: number, games: Game[]): Omit<TableRow, 'idTime' | 'nome' | 'posicao'>[] {
  const rows = Array.from({ length: teamCount }, () => ({
    jogos: 0,
    vitorias: 0,
    empates: 0,
    derrotas: 0,
    golsPro: 0,
    golsContra: 0,
    saldo: 0,
    pontos: 0,
  }));
  const add = (index: number, scored: number, conceded: number) => {
    const row = rows[index];
    row.jogos++;
    row.golsPro += scored;
    row.golsContra += conceded;
    row.saldo = row.golsPro - row.golsContra;
    if (scored > conceded) {
      row.vitorias++;
      row.pontos += POINTS.win;
    } else if (scored === conceded) {
      row.empates++;
      row.pontos += POINTS.draw;
    } else {
      row.derrotas++;
    }
  };
  for (const game of games) {
    add(game.home, game.homeGoals, game.awayGoals);
    add(game.away, game.awayGoals, game.homeGoals);
  }
  return rows;
}

/**
 * Tabela do grupo, já em ordem: pontos, depois os [criteria] em sequência
 * (o confronto direto vale só entre os empatados naquele ponto: pontos e
 * depois saldo nos jogos entre eles) e, por fim, o nome.
 */
export function computeTable(teams: GroupTeam[], games: Game[], criteria: Criterion[] = DEFAULT_CRITERIA): TableRow[] {
  const stats = statsOf(teams.length, games);

  const keyOf = (criterion: Criterion | 'pontos', index: number, tied: number[]): number => {
    const s = stats[index];
    switch (criterion) {
      case 'pontos':
        return s.pontos;
      case 'vitorias':
        return s.vitorias;
      case 'saldo':
        return s.saldo;
      case 'golsPro':
        return s.golsPro;
      case 'menosGolsContra':
        return -s.golsContra;
      case 'confronto': {
        const between = games.filter((g) => tied.includes(g.home) && tied.includes(g.away));
        const mini = statsOf(teams.length, between)[index];
        return mini.pontos * 10000 + mini.saldo;
      }
    }
  };

  const levels: (Criterion | 'pontos')[] = ['pontos', ...criteria];
  const order = (tied: number[], level: number): number[] => {
    if (tied.length <= 1) return tied;
    if (level >= levels.length) {
      return [...tied].sort((a, b) => nameKey(teams[a].name).localeCompare(nameKey(teams[b].name)));
    }
    const keys = new Map(tied.map((i) => [i, keyOf(levels[level], i, tied)]));
    const values = [...new Set(keys.values())].sort((a, b) => b - a);
    return values.flatMap((value) => order(tied.filter((i) => keys.get(i) === value), level + 1));
  };

  return order(
    teams.map((_, i) => i),
    0,
  ).map((index, position) => ({
    idTime: teams[index].id,
    nome: teams[index].name,
    posicao: position + 1,
    ...stats[index],
  }));
}

/** Campos da linha antiga em `classificacao{ano}` (espelho para o app antigo). */
export function legacyStandingFields(row: TableRow, groupName: string): Doc {
  return {
    vitorias: row.vitorias,
    derrotas: row.derrotas,
    empates: row.empates,
    gols_feitos: row.golsPro,
    gols_sofridos: row.golsContra,
    pontos: row.pontos,
    saldo_gols: row.saldo,
    fk_grupo: groupName,
  };
}

/** O grupo tem algum dos times (para recalcular só os grupos da partida). */
export const groupHasAny = (teams: GroupTeam[], wanted: GroupTeam[]): boolean =>
  wanted.some((w) => teamIndex(teams, w.id, w.name) >= 0);
