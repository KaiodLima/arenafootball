/**
 * Craque da partida (melhor jogador eleito pelos votos), apurado quando a
 * votação fecha. Mesmas regras do app (`VotingOutcome`): mínimo de votos,
 * o mais votado com a porcentagem mínima e à frente do 2º (empate = sem
 * eleito); voto no próprio atleta não conta.
 */

export type Doc = Record<string, unknown>;

export interface Vote {
  /** Conta que votou (id do doc em `votos`). */
  voterId: string;
  /** Nome do atleta votado. */
  name: string;
  teamId: string;
}

export interface Candidate {
  id: string;
  name: string;
  teamId: string;
  teamIds: string[];
  userId: string;
}

export interface VotingRules {
  minVotes: number;
  minPercent: number;
}

export interface BestPlayer {
  nome: string;
  idJogador: string;
  idTime: string;
  votos: number;
  percentual: number;
}

const text = (value: unknown) => (value == null ? '' : String(value));
const key = (name: string) => name.trim().toLowerCase();

/** `config/votacao`; sem o doc, os padrões do app (20 votos, 35%). */
export function rulesOf(config: Doc | undefined): VotingRules {
  const minVotes = Number(config?.minVotos);
  const minPercent = Number(config?.percentualMinimo);
  return {
    minVotes: Number.isFinite(minVotes) && minVotes > 0 ? minVotes : 20,
    minPercent: Number.isFinite(minPercent) && minPercent > 0 ? minPercent : 35,
  };
}

export function voteOf(id: string, data: Doc): Vote {
  return { voterId: id, name: text(data.nome), teamId: text(data.idTime) };
}

export function candidateOf(id: string, data: Doc): Candidate {
  const ids = Array.isArray(data.idsTimes) ? data.idsTimes.map(text) : [];
  return { id, name: text(data.nome), teamId: text(data.idTime), teamIds: ids, userId: text(data.idUsuario) };
}

/** Atleta do voto: pelo nome e, havendo vários, pelo time. */
function findCandidate(vote: Vote, candidates: Candidate[]): Candidate | undefined {
  const sameName = candidates.filter((c) => key(c.name) === key(vote.name));
  if (sameName.length <= 1 || !vote.teamId) return sameName[0];
  return sameName.find((c) => c.teamId === vote.teamId || c.teamIds.includes(vote.teamId)) ?? sameName[0];
}

/** Craque eleito; nulo sem eleito (poucos votos, empate ou sem a % mínima). */
export function electBestPlayer(votes: Vote[], candidates: Candidate[], rules: VotingRules): BestPlayer | null {
  const tallies = new Map<string, { name: string; teamId: string; votes: number; candidate?: Candidate }>();
  for (const vote of votes) {
    if (!vote.name.trim()) continue;
    const candidate = findCandidate(vote, candidates);
    // Voto no próprio atleta não conta.
    if (candidate?.userId && candidate.userId === vote.voterId) continue;
    const id = `${key(vote.name)}|${vote.teamId}`;
    const current = tallies.get(id) ?? { name: vote.name.trim(), teamId: vote.teamId, votes: 0, candidate };
    current.votes += 1;
    tallies.set(id, current);
  }
  const ranking = [...tallies.values()].sort((a, b) => b.votes - a.votes);
  const total = ranking.reduce((sum, t) => sum + t.votes, 0);
  const leader = ranking[0];
  if (!leader || total < rules.minVotes) return null;
  if (ranking.length > 1 && ranking[1].votes === leader.votes) return null;
  if (leader.votes * 100 < rules.minPercent * total) return null;
  return {
    nome: leader.name,
    idJogador: leader.candidate?.id ?? '',
    idTime: leader.teamId || leader.candidate?.teamId || '',
    votos: leader.votes,
    percentual: Math.round((leader.votes * 100) / total),
  };
}

/** A votação acabou de fechar (`votacao` é string). */
export function votingJustClosed(before: Doc, after: Doc): boolean {
  return text(before.votacao) === 'true' && text(after.votacao) !== 'true';
}
