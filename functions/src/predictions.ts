/**
 * Palpites (bolão grátis): pontos de cada palpite quando a partida acaba e
 * o quanto muda no ranking da região. Funções puras (testes em
 * test/predictions.test.ts); quem lê e grava é o index.ts.
 */

type Doc = Record<string, unknown>;

const text = (value: unknown): string => (value === undefined || value === null ? '' : String(value).trim());
const int = (value: unknown): number => {
  const n = Number.parseInt(text(value), 10);
  return Number.isFinite(n) ? n : 0;
};

export const PREDICTION_POINTS = { exact: 10, winnerAndDiff: 7, winner: 5 } as const;

/** Id do doc do palpiteiro no ranking da região. */
export const rankingDocId = (regionId: string, uid: string): string => `${regionId}_${uid}`;

/**
 * Pontos do palpite: placar exato 10; vencedor e saldo (ou empate com outro
 * placar) 7; só o vencedor 5; errou 0.
 */
export function predictionPoints(
  prediction: { home: number; away: number },
  result: { home: number; away: number },
): { points: number; exact: boolean } {
  if (prediction.home === result.home && prediction.away === result.away) {
    return { points: PREDICTION_POINTS.exact, exact: true };
  }
  const sign = (n: number) => Math.sign(n);
  const predictedDiff = prediction.home - prediction.away;
  const resultDiff = result.home - result.away;
  if (sign(predictedDiff) !== sign(resultDiff)) return { points: 0, exact: false };
  if (predictedDiff === resultDiff) return { points: PREDICTION_POINTS.winnerAndDiff, exact: false };
  return { points: PREDICTION_POINTS.winner, exact: false };
}

const dateOf = (value: unknown): Date | null => {
  if (value instanceof Date) return value;
  const toDate = (value as { toDate?: () => Date } | null | undefined)?.toDate;
  return typeof toDate === 'function' ? toDate.call(value) : null;
};

/**
 * Prazo do palpite: o horário marcado (data "dd/MM" do ano da temporada ou
 * "dd/MM/aaaa" + "HH:mm", Brasília) ou o início manual do admin, o que vier
 * antes. Nulo sem data/hora legível (aí vale todo palpite).
 */
export function predictionDeadline(match: Doc, season: string): Date | null {
  const [dayText, monthText, yearText] = text(match.data).split('/');
  const [hourText, minuteText] = text(match.horario).split(':');
  const day = Number.parseInt(dayText ?? '', 10);
  const month = Number.parseInt(monthText ?? '', 10);
  const hour = Number.parseInt(hourText ?? '', 10);
  const minute = Number.parseInt(minuteText ?? '0', 10);
  let kickoff: Date | null = null;
  if (day && month && Number.isFinite(hour) && Number.isFinite(minute)) {
    const year = Number.parseInt(yearText ?? '', 10) || Number.parseInt(season, 10) || new Date().getUTCFullYear();
    kickoff = new Date(Date.UTC(year, month - 1, day, hour + 3, minute));
  }
  const manualStart = dateOf(match.inicioEm);
  if (manualStart && (!kickoff || manualStart < kickoff)) return manualStart;
  return kickoff;
}

/** O palpite foi feito/alterado dentro do prazo. */
export function isOnTime(savedAt: unknown, deadline: Date | null): boolean {
  if (!deadline) return true;
  const at = dateOf(savedAt);
  return at !== null && at.getTime() < deadline.getTime();
}

/** Pontuação de um palpite para a partida (com o prazo). */
export function scorePrediction(prediction: Doc, match: Doc, season: string) {
  const valid = isOnTime(prediction.atualizadoEm, predictionDeadline(match, season));
  const score = valid
    ? predictionPoints(
        { home: int(prediction.golsCasa), away: int(prediction.golsFora) },
        { home: int(match.golTimeCasa), away: int(match.golTimeFora) },
      )
    : { points: 0, exact: false };
  return { valid, points: score.points, exact: score.exact };
}

/**
 * O que somar no ranking ao (re)pontuar: a diferença para o que já tinha
 * sido contado (placar corrigido = só a diferença). Nulo se nada muda.
 */
export function rankingDelta(
  previous: Doc,
  next: { valid: boolean; points: number; exact: boolean },
): { points: number; exact: number; counted: number } | null {
  const scoredBefore = typeof previous.valido === 'boolean';
  const prevCounted = previous.valido === true ? 1 : 0;
  const delta = {
    points: next.points - (scoredBefore ? int(previous.pontos) : 0),
    exact: (next.exact ? 1 : 0) - (previous.exato === true ? 1 : 0),
    counted: (next.valid ? 1 : 0) - prevCounted,
  };
  const unchanged =
    scoredBefore && delta.points === 0 && delta.exact === 0 && delta.counted === 0 && previous.valido === next.valid;
  return unchanged ? null : delta;
}
