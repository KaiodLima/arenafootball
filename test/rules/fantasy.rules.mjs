import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, serverTimestamp, setDoc, updateDoc } from 'firebase/firestore';

/** Arena Fantasy: configuração por campeonato (`fantasy/{idDocCampeonato}`). */
export default async function run(env, check) {
  const seed = (path, data) => env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), path), data));
  await seed('usuarios/admin', { idUsuario: 'admin', admin: true });
  await seed('campeonatos/fc1', { titulo: 'Copa Verde', id_campeonato: 8, idOrganizador: 'org1' });

  const admin = env.authenticatedContext('admin').firestore();
  const user = env.authenticatedContext('u1').firestore();
  const org = env.authenticatedContext('org1').firestore();
  const guest = env.unauthenticatedContext().firestore();
  const config = (extra = {}) => ({
    idCampeonato: 8, temporada: '2026', titulo: 'Copa Verde', urlImagem: '', fk_competicao: 'Colônia', idRegiao: 'co',
    idsRegioes: ['co'], ativo: true, minMinutos: 20, minMinutosDefesa: 45, capitao: 1.5,
    atualizadoEm: serverTimestamp(), ...extra,
  });

  await check('admin ativa o Fantasy', assertSucceeds(setDoc(doc(admin, 'fantasy/fc1'), config())));
  await check('admin muda os parâmetros', assertSucceeds(setDoc(doc(admin, 'fantasy/fc1'),
    config({ minMinutos: 30, minMinutosDefesa: 60, capitao: 2 }), { merge: true })));
  await check('convidado lê a configuração', assertSucceeds(getDoc(doc(guest, 'fantasy/fc1'))));
  await check('usuário comum não grava', assertFails(setDoc(doc(user, 'fantasy/fc2'), config())));
  await check('organizador não grava', assertFails(updateDoc(doc(org, 'fantasy/fc1'),
    { ativo: false, atualizadoEm: serverTimestamp() })));
  await check('mínimo fora da faixa recusado', assertFails(setDoc(doc(admin, 'fantasy/fc1'), config({ minMinutos: 200 }))));
  await check('defensivo menor que o mínimo recusado', assertFails(setDoc(doc(admin, 'fantasy/fc1'),
    config({ minMinutos: 30, minMinutosDefesa: 20 }))));
  await check('capitão 5× recusado', assertFails(setDoc(doc(admin, 'fantasy/fc1'), config({ capitao: 5 }))));
  await check('ativo como texto recusado', assertFails(setDoc(doc(admin, 'fantasy/fc1'), config({ ativo: 'true' }))));
  await check('campo estranho recusado', assertFails(setDoc(doc(admin, 'fantasy/fc1'), config({ pontos: 10 }))));
  await check('admin não grava participantes', assertFails(setDoc(doc(admin, 'fantasy/fc1'),
    config({ participantes: 99 }), { merge: true })));
  await check('admin não cria com rodada atual', assertFails(setDoc(doc(admin, 'fantasy/fc3'), config({ rodadaAtual: 1 }))));
  await check('não se apaga', assertFails(deleteDoc(doc(admin, 'fantasy/fc1'))));

  // Campos das functions já gravados: o admin segue editando sem mexer neles.
  await env.withSecurityRulesDisabled((ctx) => updateDoc(doc(ctx.firestore(), 'fantasy/fc1'), { participantes: 3, rodadaAtual: 2 }));
  await check('admin desliga com participantes gravados', assertSucceeds(setDoc(doc(admin, 'fantasy/fc1'),
    config({ ativo: false }), { merge: true })));
  await check('subcoleção sem regra é negada', assertFails(setDoc(doc(user, 'fantasy/fc1/participantes/u1'), { nome: 'U' })));
}
