/**
 * Indique amigos: o indicado grava `usuarios/{uid}.indicadoPor` (código de
 * quem indicou) e, quando escolhe o time do coração, as functions conferem e
 * dão 1 pacotinho extra para os dois + a métrica `indicacoes` de quem indicou.
 * Funções puras (testes em test/referrals.test.ts); quem grava é o index.ts.
 * O código é derivado do uid, igual ao app (`ReferralCode`).
 */
import { PushMessage, userTopic } from './messages';

type Doc = Record<string, unknown>;

const text = (value: unknown): string => (value === undefined || value === null ? '' : String(value).trim());
const num = (value: unknown): number => (typeof value === 'number' && Number.isFinite(value) ? value : 0);

/** Só conta conta criada há no máximo isto. */
export const REFERRAL_WINDOW_DAYS = 7;

/** Pacotinhos extras guardados, no máximo (os ganhos acima disso se perdem). */
export const MAX_EXTRA_PACKS = 5;

/** Formato do código: 8 (ou 10, se colidir) letras/números maiúsculos. */
export const CODE_PATTERN = /^[A-Z0-9]{8,10}$/;

/** Código de [uid]: os [length] primeiros caracteres em maiúsculas. */
export function referralCodeOf(uid: string, length = 8): string {
  return uid.slice(0, length).toUpperCase();
}

const hasTeam = (profile: Doc | undefined): boolean => !!text(profile?.idTime) || !!text(profile?.time);

/**
 * O perfil acabou de ficar pronto para a indicação (código + time do
 * coração) nesta escrita: só então o gatilho lê alguma coisa.
 */
export function referralReady(before: Doc | undefined, after: Doc | undefined): boolean {
  const code = text(after?.indicadoPor);
  if (!CODE_PATTERN.test(code) || !hasTeam(after)) return false;
  return !(text(before?.indicadoPor) && hasTeam(before));
}

/** Indicações ligadas pelo admin (`config/indicacao.ativo`; sem o doc = desligadas). */
export function referralEnabled(config: Doc | undefined): boolean {
  return config?.ativo === true;
}

/** A config acabou de ser ligada (as pendentes são resolvidas agora). */
export function referralJustEnabled(before: Doc | undefined, after: Doc | undefined): boolean {
  return !referralEnabled(before) && referralEnabled(after);
}

/** Indicação já resolvida (valeu ou foi recusada): não processa de novo. */
export function referralSettled(referral: Doc | undefined): boolean {
  return referral?.validadaEm !== undefined || !!text(referral?.recusa);
}

export type ReferralRefusal = 'codigo' | 'propria' | 'conta_antiga';

/**
 * Vale ou não: o código precisa existir ([referrerUid] do doc do código),
 * não ser da própria conta e a conta ser nova ([createdAt] até
 * [REFERRAL_WINDOW_DAYS] dias antes de [now]).
 */
export function referralDecision(input: {
  inviteeUid: string;
  referrerUid: string;
  createdAt: Date | null;
  now: Date;
}): { ok: true } | { ok: false; motivo: ReferralRefusal } {
  if (!input.referrerUid) return { ok: false, motivo: 'codigo' };
  if (input.referrerUid === input.inviteeUid) return { ok: false, motivo: 'propria' };
  const limit = REFERRAL_WINDOW_DAYS * 24 * 60 * 60 * 1000;
  if (!input.createdAt || input.now.getTime() - input.createdAt.getTime() > limit) {
    return { ok: false, motivo: 'conta_antiga' };
  }
  return { ok: true };
}

/** Saldo de pacotinhos extras com mais um (até [MAX_EXTRA_PACKS]). */
export function addExtraPack(referral: Doc | undefined): number {
  return Math.min(MAX_EXTRA_PACKS, num(referral?.pacotesExtras) + 1);
}

/** Saldo de pacotinhos extras guardado. */
export function extraPacksOf(referral: Doc | undefined): number {
  return Math.max(0, num(referral?.pacotesExtras));
}

/** Primeiro nome (o push e a página do convite não mostram o nome inteiro). */
export function firstName(name: unknown): string {
  return text(name).split(/\s+/)[0] ?? '';
}

/** Push para quem indicou: o amigo entrou e o pacotinho extra chegou. */
export function referralMessage(referrerUid: string, inviteeName: string): PushMessage {
  const name = firstName(inviteeName);
  return {
    tipo: 'indicacao',
    titulo: '🎉 Indicação confirmada!',
    corpo: name
      ? `${name} entrou pelo seu convite. Você ganhou 1 pacotinho extra!`
      : 'Um amigo entrou pelo seu convite. Você ganhou 1 pacotinho extra!',
    aba: 'indicacao',
    regiao: '',
    alvo: { topic: userTopic(referrerUid) },
  };
}
