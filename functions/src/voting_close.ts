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

/** Pausa suposta do intervalo e folga do encerramento automático (iguais ao app, `MatchClock`). */
export const HALF_TIME_BREAK_MINUTES = 15;
export const AUTO_FINISH_MARGIN_MINUTES = 30;

const dateOf = (value: unknown): Date | null => {
  const toDate = (value as { toDate?: () => Date } | null | undefined)?.toDate;
  return typeof toDate === 'function' ? toDate.call(value) : null;
};

/**
 * Fim esperado: 2º tempo marcado + o que falta; no intervalo, a pausa + o
 * 2º tempo; iniciada na mão (`inicioEm`, ou `statusEm` em doc antigo) +
 * duração; senão, horário + duração ([matchEnd]).
 */
export function expectedEnd(match: Doc, season: string, now: Date = new Date()): Date | null {
  const duration = Number(match.duracao) > 0 ? Number(match.duracao) : DEFAULT_DURATION_MINUTES;
  const secondHalfMinutes = duration - Math.round(duration / 2);
  const minutes = (n: number) => n * 60_000;
  const secondHalf = dateOf(match.segundoTempoEm);
  if (secondHalf) return new Date(secondHalf.getTime() + minutes(secondHalfMinutes));
  const halfTime = dateOf(match.intervaloEm);
  if (text(match.status) === 'intervalo' && halfTime) {
    return new Date(halfTime.getTime() + minutes(HALF_TIME_BREAK_MINUTES + secondHalfMinutes));
  }
  const start = dateOf(match.inicioEm) ?? (text(match.status) === 'andamento' ? dateOf(match.statusEm) : null);
  if (start) return new Date(start.getTime() + minutes(duration));
  return matchEnd(match, season, now);
}

/** Iniciada na mão e esquecida em andamento/intervalo: encerra 30 min depois do fim esperado. */
export function shouldAutoFinish(match: Doc, season: string, now: Date = new Date()): boolean {
  const status = text(match.status);
  if (status !== 'andamento' && status !== 'intervalo') return false;
  const end = expectedEnd(match, season, now);
  return end !== null && now.getTime() >= end.getTime() + AUTO_FINISH_MARGIN_MINUTES * 60_000;
}
