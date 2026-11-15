/**
 * Evento de votação do admin (`noticias/{id}` com `tag: "evento"`): a
 * apuração (`noticias/{id}/apuracao/total`) é recontada a cada voto novo,
 * por opção, com `count()` — recontar duas vezes dá o mesmo resultado.
 */

type Doc = Record<string, unknown>;

export const EVENT_TAG = 'evento';
export const EVENT_VOTES = 'votos_evento';

/** Ids das opções do evento (`idsOpcoes`; sem a lista, os ids de `opcoes`). */
export function eventOptionIds(event: Doc | undefined): string[] {
  if (!event || event.tag !== EVENT_TAG) return [];
  const ids = event.idsOpcoes;
  if (Array.isArray(ids)) return ids.map((id) => String(id)).filter((id) => id.length > 0);
  const options = event.opcoes;
  if (!Array.isArray(options)) return [];
  return options
    .map((option) => (option && typeof option === 'object' ? String((option as Doc).id ?? '') : ''))
    .filter((id) => id.length > 0);
}

/** Doc da apuração: votos por opção (todas as opções, mesmo com 0) e o total. */
export function tallyDoc(counts: Record<string, number>): { votos: Record<string, number>; total: number } {
  const votos: Record<string, number> = {};
  let total = 0;
  for (const [id, n] of Object.entries(counts)) {
    const value = Number.isFinite(n) && n > 0 ? Math.floor(n) : 0;
    votos[id] = value;
    total += value;
  }
  return { votos, total };
}

/** Título do push do evento novo. */
export function eventPushTitle(title: string): string {
  return `🗳️ Vote: ${title}`;
}
