import assert from 'node:assert/strict';
import { test } from 'node:test';
import { claimReconcilePlan, missingEnrollmentFix, needsClaimReconcile } from '../claim_reconcile';

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

test('vínculo com competição: a inscrição vai para o reivindicado e o principal fica', () => {
  const plan = claimReconcilePlan(
    'u1',
    { ...approved, idCampeonato: 9, time: 'Volta', idTime: '2' },
    { time: 'Lava Jato', idTime: '1', nGols: 3, idsTimes: ['1'], inscricoes: { c7: { idTime: '1', nGols: 3 } } },
    { idUsuario: 'u1', idTime: '2', nGols: 1 },
  );
  assert.equal(plan?.claimedUpdate.time, undefined);
  assert.equal(plan?.claimedUpdate['inscricoes.c9.idTime'], '2');
  assert.equal(plan?.claimedUpdate['inscricoes.c9.nGols'], 1);
  assert.deepEqual(plan?.claimedUpdate.idsTimes, ['1', '2']);
  assert.equal(plan?.claimedUpdate.nGols, 4);
});

test('aprovado pelo app antigo sem a inscrição: completa a da competição do pedido', () => {
  const request = { status: 'aprovada', idJogador: 'p1', idCampeonato: 9, time: 'Volta', idTime: '2' };
  const fix = missingEnrollmentFix(request, { time: 'Volta', idTime: '2', idsTimes: ['1'], inscricoes: { c7: { idTime: '1' } } });
  assert.equal(fix?.['inscricoes.c9.idTime'], '2');
  assert.deepEqual(fix?.idsTimes, ['1', '2']);
  // Já inscrito, sem competição ou ainda pendente: nada a fazer.
  assert.equal(missingEnrollmentFix(request, { inscricoes: { c9: { idTime: '2' } } }), null);
  assert.equal(missingEnrollmentFix({ ...request, idCampeonato: undefined }, {}), null);
  assert.equal(missingEnrollmentFix({ ...request, status: 'pendente' }, {}), null);
});

