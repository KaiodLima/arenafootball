import assert from 'node:assert/strict';
import { test } from 'node:test';
import { claimReconcilePlan, needsClaimReconcile } from '../claim_reconcile';

const approved = {
  status: 'aprovada',
  idJogador: 'novo',
  idJogadorVinculo: 'antigo',
  time: 'Lava Jato',
  idTime: '1',
  posicao: 'volante',
  urlImagem: '',
};

test('vínculo: só reconcilia aprovado, com vínculo e atleta diferente', () => {
  assert.equal(needsClaimReconcile(approved), true);
  assert.equal(needsClaimReconcile({ ...approved, idJogador: 'antigo' }), false);
  assert.equal(needsClaimReconcile({ ...approved, idJogadorVinculo: '' }), false);
  assert.equal(needsClaimReconcile({ ...approved, status: 'pendente' }), false);
  assert.equal(needsClaimReconcile(undefined), false);
});

test('vínculo: reivindicado de outra conta (ou inexistente) não mexe', () => {
  assert.equal(claimReconcilePlan('u1', approved, { idUsuario: 'outra' }, { idUsuario: 'u1' }), null);
  assert.equal(claimReconcilePlan('u1', approved, undefined, { idUsuario: 'u1' }), null);
});

test('vínculo: liga a conta, soma os números e apaga o criado', () => {
  const plan = claimReconcilePlan(
    'u1',
    approved,
    { nome: 'Dudu', nGols: 3, nAssistencias: 1, idTime: '1' },
    { idUsuario: 'u1', nGols: 1, nAssistencias: 0, idTime: '1' },
  );
  assert.deepEqual(plan, {
    claimedUpdate: { idUsuario: 'u1', time: 'Lava Jato', idTime: '1', posicao: 'volante', nGols: 4, nAssistencias: 1 },
    deleteCreated: true,
    requestPlayerId: 'antigo',
  });
});

test('vínculo: criado de outra conta não é apagado nem somado', () => {
  const plan = claimReconcilePlan('u1', approved, { nGols: 3 }, { idUsuario: 'outra', nGols: 5 });
  assert.equal(plan?.deleteCreated, false);
  assert.equal(plan?.claimedUpdate.nGols, 3);
});
