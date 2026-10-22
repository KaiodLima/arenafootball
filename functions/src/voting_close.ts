/**
 * Encerramento automático da votação de melhor jogador: a votação aberta
 * fecha 24h depois do fim da partida (data + horário + duração). Funções puras
 * (testes em test/voting_close.test.ts); o agendamento fica em index.ts.
 */

type Doc = Record<string, unknown>;

const text = (value: unknown): string => (value === undefined || value === null ? '' : String(value).trim());

/** Duração de partida sem o campo `duracao` (igual ao app). */
export const DEFAULT_DURATION_MINUTES = 90;

/** Horas depois do fim da partida em que a votação fecha sozinha. */
export const CLOSE_AFTER_HOURS = 24;

/** Brasília não tem horário de verão desde 2019: UTC-3 fixo. */
const BRASILIA_OFFSET_HOURS = 3;

/**
 * Fim da partida em UTC. A data é "dd/MM" (ano da temporada) ou "dd/MM/aaaa";
 * sem horário legível, vale o fim do dia. Nulo sem data legível.
 */
export function matchEnd(match: Doc, season: string, now: Date = new Date()): Date | null {
  const [dayText, monthText, yearText] = text(match.data).split('/');
  const day = Number.parseInt(dayText ?? '', 10);
  const month = Number.parseInt(monthText ?? '', 10);
  if (!day || !month) return null;
  const year = Number.parseInt(yearText ?? '', 10) || Number.parseInt(season, 10) || now.getUTCFullYear();
  const [hourText, minuteText] = text(match.horario).split(':');
  const hour = Number.parseInt(hourText ?? '', 10);
  const minute = Number.parseInt(minuteText ?? '0', 10);
  const hasTime = Number.isFinite(hour) && Number.isFinite(minute);
  const duration = Number(match.duracao) > 0 ? Number(match.duracao) : DEFAULT_DURATION_MINUTES;
  const start = Date.UTC(year, month - 1, day, (hasTime ? hour : 23) + BRASILIA_OFFSET_HOURS, hasTime ? minute : 59);
  return new Date(start + (hasTime ? duration : 0) * 60_000);
}

/** A votação aberta desta partida já deve fechar (24h depois do fim). */
export function shouldCloseVoting(match: Doc, season: string, now: Date = new Date()): boolean {
  if (text(match.votacao) !== 'true') return false;
  const end = matchEnd(match, season, now);
  if (!end) return false;
  return now.getTime() >= end.getTime() + CLOSE_AFTER_HOURS * 3_600_000;
}
