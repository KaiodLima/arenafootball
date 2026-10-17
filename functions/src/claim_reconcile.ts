/**
 * Pedido de vínculo ("Sou jogador" com `idJogadorVinculo`) aprovado por um
 * app antigo: ele não conhece o vínculo e cria um atleta novo para a conta,
 * deixando o atleta reivindicado (com os números) sem conta. Aqui, sem
 * Firebase, decide-se como juntar os dois. Testado em
 * `test/claim_reconcile.test.ts`.
 */
type Doc = Record<string, unknown>;

const text = (value: unknown): string => (value === undefined || value === null ? '' : String(value).trim());
const count = (value: unknown): number => (typeof value === 'number' && Number.isFinite(value) ? value : 0);

/** O pedido precisa de reconciliação: aprovado, com vínculo e outro atleta. */
export function needsClaimReconcile(request: Doc | undefined): boolean {
  if (!request || text(request.status) !== 'aprovada') return false;
  const claimed = text(request.idJogadorVinculo);
  return claimed !== '' && text(request.idJogador) !== '' && text(request.idJogador) !== claimed;
}

export interface ClaimReconcilePlan {
  /** Campos gravados no atleta reivindicado. */
  claimedUpdate: Doc;
  /** Apagar o atleta criado na aprovação (só se for desta conta). */
  deleteCreated: boolean;
  /** Novo `idJogador` do pedido. */
  requestPlayerId: string;
}

/**
 * Como juntar: o reivindicado ganha a conta, o time e a posição/foto do
 * pedido, e soma os números que o criado já tenha recebido; o criado some.
 * Nulo = não mexer (reivindicado inexistente ou de outra conta).
 */
export function claimReconcilePlan(
  uid: string,
  request: Doc,
  claimed: Doc | undefined,
  created: Doc | undefined,
): ClaimReconcilePlan | null {
  if (!uid || !claimed) return null;
  const owner = text(claimed.idUsuario);
  if (owner !== '' && owner !== uid) return null;
  const createdIsOwn = created !== undefined && text(created.idUsuario) === uid;
  const position = text(request.posicao);
  const photo = text(request.urlImagem);
  return {
    claimedUpdate: {
      idUsuario: uid,
      time: text(request.time),
      idTime: text(created?.idTime) || text(request.idTime) || text(claimed.idTime),
      ...(position ? { posicao: position } : {}),
      ...(photo ? { urlImagem: photo } : {}),
      nGols: count(claimed.nGols) + (createdIsOwn ? count(created?.nGols) : 0),
      nAssistencias: count(claimed.nAssistencias) + (createdIsOwn ? count(created?.nAssistencias) : 0),
    },
    deleteCreated: createdIsOwn,
    requestPlayerId: text(request.idJogadorVinculo),
  };
}
