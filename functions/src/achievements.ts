/**
 * Conquistas no servidor: contadores que o usuário não pode fraudar (votos,
 * time do coração, foto, atleta, dono de time) e o desbloqueio com push.
 * Funções puras (testes em test/achievements.test.ts); quem grava é o index.ts.
 * As métricas são as mesmas do app (`AchievementMetric`).
 */
import { PushMessage, userTopic } from './messages';

type Doc = Record<string, unknown>;

const text = (value: unknown): string => (value === undefined || value === null ? '' : String(value).trim());
const num = (value: unknown): number => (typeof value === 'number' && Number.isFinite(value) ? value : 0);

/** Campos de `usuarios/{uid}/progresso/contadores` que valem como métrica. */
export const METRIC_KEYS = [
  'votos',
  'compartilhamentos',
  'noticiasLidas',
  'diasAtivos',
  'melhorSequencia',
  'timeCoracao',
  'fotoCarteirinha',
  'atleta',
  'golsAtleta',
  'assistenciasAtleta',
  'donoTime',
  'palpites',
  'palpitesExatos',
] as const;

/** Ids das conquistas já desbloqueadas (gravado só pelo servidor). */
export const UNLOCKED_FIELD = 'desbloqueadas';

export interface Achievement {
  id: string;
  titulo: string;
  metrica: string;
  meta: number;
  pontos: number;
  ativa: boolean;
}

export function achievementFromDoc(id: string, data: Doc): Achievement {
  const meta = Math.max(1, Math.trunc(num(Number(data.meta)) || 1));
  return {
    id,
    titulo: text(data.titulo),
    metrica: text(data.metrica),
    meta,
    pontos: Math.max(0, Math.trunc(num(Number(data.pontos)))),
    ativa: data.ativa !== false,
  };
}

/** Algum contador mudou (só mudar a lista de desbloqueadas não reavalia). */
export function countersChanged(before: Doc | undefined, after: Doc): boolean {
  return METRIC_KEYS.some((key) => num(before?.[key]) !== num(after[key]));
}

/** Primeira avaliação do usuário: o que ele já tinha atingido entra sem push nem comemoração. */
export const isFirstEvaluation = (progress: Doc): boolean => !Array.isArray(progress[UNLOCKED_FIELD]);

/** Conquistas ativas atingidas que ainda não foram desbloqueadas. */
export function newUnlocks(catalog: Achievement[], progress: Doc): Achievement[] {
  const unlocked = new Set(Array.isArray(progress[UNLOCKED_FIELD]) ? (progress[UNLOCKED_FIELD] as unknown[]).map(String) : []);
  return catalog.filter(
    (a) =>
      a.ativa &&
      (METRIC_KEYS as readonly string[]).includes(a.metrica) &&
      !unlocked.has(a.id) &&
      num(progress[a.metrica]) >= a.meta,
  );
}

/** Contadores do perfil: escolheu o time do coração e pôs foto. */
export function profileCounters(user: Doc | undefined): { timeCoracao: number; fotoCarteirinha: number } {
  return {
    timeCoracao: text(user?.idTime) || text(user?.time) ? 1 : 0,
    fotoCarteirinha: text(user?.urlImagem) ? 1 : 0,
  };
}

/** Contadores do atleta ligado à conta (Geral da temporada); sem atleta, zeros. */
export function athleteCounters(player: Doc | undefined): { atleta: number; golsAtleta: number; assistenciasAtleta: number } {
  if (!player) return { atleta: 0, golsAtleta: 0, assistenciasAtleta: 0 };
  return { atleta: 1, golsAtleta: num(player.nGols), assistenciasAtleta: num(player.nAssistencias) };
}

/** Só os campos que mudaram (para não regravar à toa). */
export function changedFields<T extends Record<string, number>>(progress: Doc | undefined, fields: T): Partial<T> {
  const changes: Partial<T> = {};
  for (const [key, value] of Object.entries(fields) as [keyof T, number][]) {
    if (progress?.[key as string] !== value) changes[key] = value as T[keyof T];
  }
  return changes;
}

/** Conta antiga: campos do servidor que ainda faltam (preenchimento preguiçoso). */
export function missingServerFields(progress: Doc): { profile: boolean; athlete: boolean; owner: boolean } {
  return {
    profile: !('timeCoracao' in progress) || !('fotoCarteirinha' in progress),
    athlete: !('atleta' in progress),
    owner: !('donoTime' in progress),
  };
}

/** Push "Conquista desbloqueada" para a própria conta. */
export function achievementMessage(uid: string, achievement: Achievement): PushMessage {
  return {
    tipo: 'conquista',
    titulo: '🏅 Conquista desbloqueada!',
    corpo: achievement.pontos > 0 ? `${achievement.titulo} · +${achievement.pontos} XP` : achievement.titulo,
    aba: 'conquistas',
    regiao: '',
    alvo: { topic: userTopic(uid) },
  };
}
