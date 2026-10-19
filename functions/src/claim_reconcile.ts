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
const isRecord = (value: unknown): value is Doc => typeof value === 'object' && value !== null && !Array.isArray(value);

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
  const teamId = text(created?.idTime) || text(request.idTime) || text(claimed.idTime);
  const extraGoals = createdIsOwn ? count(created?.nGols) : 0;
  const extraAssists = createdIsOwn ? count(created?.nAssistencias) : 0;
  // Pedido com competição: a inscrição do pedido vai para o reivindicado (com
  // o que o criado já tinha recebido nela); o time principal fica o dele.
  const championshipId = typeof request.idCampeonato === 'number' ? request.idCampeonato : null;
  const enrollments = isRecord(claimed.inscricoes) ? claimed.inscricoes : {};
  const key = championshipId === null ? '' : `c${championshipId}`;
  const current = key && isRecord(enrollments[key]) ? (enrollments[key] as Doc) : {};
  const teamIds = Array.isArray(claimed.idsTimes) ? claimed.idsTimes.map(text).filter((id) => id !== '') : [];
  const enrollmentUpdate: Doc = key
    ? {
        [`inscricoes.${key}.idTime`]: teamId,
        [`inscricoes.${key}.time`]: text(request.time),
        [`inscricoes.${key}.nGols`]: count(current.nGols) + extraGoals,
        [`inscricoes.${key}.nAssistencias`]: count(current.nAssistencias) + extraAssists,
        idsTimes: [...new Set([...teamIds, ...(teamId ? [teamId] : [])])],
      }
    : {};
  const keepsPrimary = key !== '' && text(claimed.time) !== '';
  return {
    claimedUpdate: {
      idUsuario: uid,
      ...(keepsPrimary ? {} : { time: text(request.time), idTime: teamId }),
      ...(position ? { posicao: position } : {}),
      ...(photo ? { urlImagem: photo } : {}),
      nGols: count(claimed.nGols) + extraGoals,
      nAssistencias: count(claimed.nAssistencias) + extraAssists,
      ...enrollmentUpdate,
    },
    deleteCreated: createdIsOwn,
    requestPlayerId: text(request.idJogadorVinculo),
  };
}

/**
 * Pedido aprovado com competição (`idCampeonato`): a inscrição precisa estar
 * no atleta da aprovação (`idJogador`). O app antigo aprova sem gravá-la (só
 * troca o time); aqui ela é completada. Nulo = já está certo (ou não se aplica).
 */
export function missingEnrollmentFix(request: Doc | undefined, player: Doc | undefined): Doc | null {
  if (!request || !player || text(request.status) !== 'aprovada' || needsClaimReconcile(request)) return null;
  const championshipId = typeof request.idCampeonato === 'number' ? request.idCampeonato : null;
  if (championshipId === null || text(request.idJogador) === '') return null;
  const key = `c${championshipId}`;
  const enrollments = isRecord(player.inscricoes) ? player.inscricoes : {};
  if (isRecord(enrollments[key])) return null;
  const teamId = text(request.idTime) || text(player.idTime);
  const teamIds = Array.isArray(player.idsTimes) ? player.idsTimes.map(text).filter((id) => id !== '') : [];
  return {
    [`inscricoes.${key}.idTime`]: teamId,
    [`inscricoes.${key}.time`]: text(request.time),
    [`inscricoes.${key}.nGols`]: 0,
    [`inscricoes.${key}.nAssistencias`]: 0,
    idsTimes: [...new Set([...teamIds, ...(teamId ? [teamId] : [])])],
  };
}

