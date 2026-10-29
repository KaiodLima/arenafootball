/**
 * Álbum de figurinhas (evento do admin): o pacotinho grátis do dia é sorteado
 * aqui, no servidor (o app só pede). Funções puras; quem grava é o index.ts.
 */

export type Doc = Record<string, unknown>;

export interface Sticker {
  id: string;
  teamId: string;
}

export interface AlbumProgress {
  /** idFig → quantidade (repetidas contam). */
  figurinhas: Record<string, number>;
  /** Figurinhas diferentes já coladas. */
  coladas: number;
  /** Times (ids) com todas as figurinhas coladas. */
  paginasCompletas: string[];
  completo: boolean;
}

/** Figurinhas por pacote quando o evento não diz. */
export const DEFAULT_PER_PACK = 5;

const text = (value: unknown): string => (value === undefined || value === null ? '' : String(value).trim());

/** Dia de [now] em Brasília (UTC-3), igual ao app (`PartnerSlots.brasiliaDay`) e às regras. */
export function brasiliaDay(now: Date): string {
  const local = new Date(now.getTime() - 3 * 3600 * 1000);
  return `${local.getUTCFullYear()}-${local.getUTCMonth() + 1}-${local.getUTCDate()}`;
}

/** Id do pacote do dia: `<evento>_<uid>_<a-m-d>`. */
export function packId(eventId: string, uid: string, now: Date): string {
  return `${eventId}_${uid}_${brasiliaDay(now)}`;
}

/** Evento e uid do id do pacote (o uid não tem "_"; o evento pode ter). */
export function parsePackId(id: string): { eventId: string; uid: string; day: string } | null {
  const parts = id.split('_');
  if (parts.length < 3) return null;
  const day = parts[parts.length - 1];
  const uid = parts[parts.length - 2];
  const eventId = parts.slice(0, -2).join('_');
  if (!eventId || !uid || !/^\d{4}-\d{1,2}-\d{1,2}$/.test(day)) return null;
  return { eventId, uid, day };
}

/** Sorteia [count] figurinhas (chance igual, pode repetir). [random] em [0, 1). */
export function drawPack(stickers: Sticker[], count: number, random: () => number = Math.random): string[] {
  if (stickers.length === 0 || count <= 0) return [];
  const drawn: string[] = [];
  for (let i = 0; i < count; i++) {
    drawn.push(stickers[Math.min(stickers.length - 1, Math.floor(random() * stickers.length))].id);
  }
  return drawn;
}

/** Álbum gravado (campos ausentes = vazio). */
export function albumOf(data: Doc | undefined): AlbumProgress {
  const raw = (data?.figurinhas ?? {}) as Record<string, unknown>;
  const figurinhas: Record<string, number> = {};
  for (const [id, value] of Object.entries(raw)) {
    const n = typeof value === 'number' ? value : Number(value);
    if (Number.isFinite(n) && n > 0) figurinhas[id] = n;
  }
  return {
    figurinhas,
    coladas: Object.keys(figurinhas).length,
    paginasCompletas: Array.isArray(data?.paginasCompletas) ? (data!.paginasCompletas as unknown[]).map(text) : [],
    completo: data?.completo === true,
  };
}

/**
 * Cola o pacote [drawn] no álbum [before]: soma as quantidades, recalcula as
 * coladas, as páginas completas e o álbum completo. Devolve também quais
 * figurinhas do pacote eram novas (a 1ª vez de cada uma).
 */
export function applyPack(
  before: AlbumProgress,
  drawn: string[],
  stickers: Sticker[],
): { album: AlbumProgress; novas: string[]; newPages: string[]; justCompleted: boolean } {
  const figurinhas = { ...before.figurinhas };
  const novas: string[] = [];
  for (const id of drawn) {
    if (!figurinhas[id]) novas.push(id);
    figurinhas[id] = (figurinhas[id] ?? 0) + 1;
  }
  const byTeam = new Map<string, string[]>();
  for (const sticker of stickers) {
    const list = byTeam.get(sticker.teamId) ?? [];
    list.push(sticker.id);
    byTeam.set(sticker.teamId, list);
  }
  const paginasCompletas = [...byTeam.entries()]
    .filter(([teamId, ids]) => teamId && ids.every((id) => figurinhas[id]))
    .map(([teamId]) => teamId);
  const coladas = stickers.filter((s) => figurinhas[s.id]).length;
  const completo = stickers.length > 0 && coladas === stickers.length;
  return {
    album: { figurinhas, coladas, paginasCompletas, completo },
    novas,
    newPages: paginasCompletas.filter((id) => !before.paginasCompletas.includes(id)),
    justCompleted: completo && !before.completo,
  };
}

/** Figurinha do catálogo (doc de `album_eventos/{id}/figurinhas`). */
export function stickerOf(id: string, data: Doc): Sticker {
  return { id, teamId: text(data.idTime) };
}

/** Figurinhas por pacote do evento (1 a 10; sem o campo, 5). */
export function perPackOf(event: Doc | undefined): number {
  const n = Number(event?.porPacote);
  return Number.isFinite(n) && n >= 1 ? Math.min(10, Math.floor(n)) : DEFAULT_PER_PACK;
}
