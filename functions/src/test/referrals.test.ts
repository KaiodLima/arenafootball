import assert from 'node:assert/strict';
import { test } from 'node:test';
import { packKind } from '../album';
import { invitePageData, parseSharePath, schemeHref } from '../share_page';
import {
  MAX_EXTRA_PACKS,
  addExtraPack,
  firstName,
  referralCodeOf,
  referralDecision,
  referralEnabled,
  referralJustEnabled,
  referralMessage,
  referralReady,
  referralSettled,
} from '../referrals';

const now = new Date('2026-11-01T12:00:00Z');
const days = (n: number) => new Date(now.getTime() - n * 24 * 60 * 60 * 1000);

test('código derivado do uid', () => {
  assert.equal(referralCodeOf('aB3dEf9hIjk'), 'AB3DEF9H');
  assert.equal(referralCodeOf('aB3dEf9hIjk', 10), 'AB3DEF9HIJ');
});

test('pronto para a indicação só quando ganha código + time nesta escrita', () => {
  assert.equal(referralReady(undefined, { indicadoPor: 'AB3DEF9H', idTime: 't1' }), true);
  assert.equal(referralReady({ indicadoPor: 'AB3DEF9H' }, { indicadoPor: 'AB3DEF9H', idTime: 't1' }), true);
  assert.equal(referralReady({ indicadoPor: 'AB3DEF9H', idTime: 't1' }, { indicadoPor: 'AB3DEF9H', idTime: 't2' }), false);
  assert.equal(referralReady(undefined, { indicadoPor: 'AB3DEF9H' }), false);
  assert.equal(referralReady(undefined, { indicadoPor: 'x', idTime: 't1' }), false);
  assert.equal(referralSettled({ recusa: 'codigo' }), true);
  assert.equal(referralSettled({ pacotesExtras: 2 }), false);
});

test('decisão: vale, código inexistente, própria conta e conta antiga', () => {
  const base = { inviteeUid: 'u2', referrerUid: 'u1', createdAt: days(2), now };
  assert.deepEqual(referralDecision(base), { ok: true });
  assert.deepEqual(referralDecision({ ...base, referrerUid: '' }), { ok: false, motivo: 'codigo' });
  assert.deepEqual(referralDecision({ ...base, referrerUid: 'u2' }), { ok: false, motivo: 'propria' });
  assert.deepEqual(referralDecision({ ...base, createdAt: days(8) }), { ok: false, motivo: 'conta_antiga' });
  assert.deepEqual(referralDecision({ ...base, createdAt: null }), { ok: false, motivo: 'conta_antiga' });
});

test('saldo de pacotinhos extras para no limite', () => {
  assert.equal(addExtraPack(undefined), 1);
  assert.equal(addExtraPack({ pacotesExtras: MAX_EXTRA_PACKS }), MAX_EXTRA_PACKS);
});

test('pacote extra: antes das 24 h só com pedido extra e saldo', () => {
  const album = { pacotes: 2, ultimoPacote: new Date('2026-11-01T10:00:00Z') };
  const at = new Date('2026-11-01T12:00:00Z');
  assert.equal(packKind(album, 3, at), null);
  assert.equal(packKind(album, 3, at, { requested: true, extraPacks: 1 }), 'extra');
  assert.equal(packKind(album, 3, at, { requested: true, extraPacks: 0 }), null);
  assert.equal(packKind(album, 4, at, { requested: true, extraPacks: 1 }), null);
  // Com o diário liberado, usa o diário (o saldo fica).
  assert.equal(packKind(album, 3, new Date('2026-11-02T11:00:00Z'), { requested: true, extraPacks: 1 }), 'diario');
});

test('push e página do convite', () => {
  const message = referralMessage('u1', 'Ana Souza');
  assert.deepEqual(message.alvo, { topic: 'usuario_u1' });
  assert.equal(message.tipo, 'indicacao');
  assert.match(message.corpo, /^Ana entrou/);
  assert.equal(firstName('  Ana  Souza '), 'Ana');
  const share = parseSharePath('/convite/ab3def9h');
  assert.deepEqual(share, { kind: 'convite', code: 'AB3DEF9H' });
  assert.equal(schemeHref(share!), 'arenafootball://convite/AB3DEF9H');
  assert.equal(parseSharePath('/convite/abc'), null);
  assert.match(invitePageData('Ana', 'AB3DEF9H').title, /^Ana te convidou/);
});

test('liga/desliga: sem a config = desligada; religar resolve as pendentes', () => {
  assert.equal(referralEnabled(undefined), false);
  assert.equal(referralEnabled({ ativo: false }), false);
  assert.equal(referralEnabled({ ativo: true }), true);
  assert.equal(referralJustEnabled({ ativo: false }, { ativo: true }), true);
  assert.equal(referralJustEnabled(undefined, { ativo: true }), true);
  assert.equal(referralJustEnabled({ ativo: true }, { ativo: true }), false);
  assert.equal(referralJustEnabled({ ativo: true }, { ativo: false }), false);
});
