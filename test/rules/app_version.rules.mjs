import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, serverTimestamp, setDoc } from 'firebase/firestore';

/** Versão do app (`config/versao`): leitura pública, escrita do admin validada. */
export default async function run(env, check) {
  await env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), 'usuarios/admin'), { idUsuario: 'admin', admin: true }));
  const admin = env.authenticatedContext('admin').firestore();
  const user = env.authenticatedContext('u1').firestore();
  const guest = env.unauthenticatedContext().firestore();
  const config = (extra = {}) => ({
    minimoAndroid: 40, recomendadoAndroid: 44, minimoIos: 40, recomendadoIos: 44, mensagem: 'Novidades',
    atualizadoEm: serverTimestamp(), ...extra,
  });

  await check('admin grava as versões', assertSucceeds(setDoc(doc(admin, 'config/versao'), config())));
  await check('convidado lê', assertSucceeds(getDoc(doc(guest, 'config/versao'))));
  await check('usuário comum não grava', assertFails(setDoc(doc(user, 'config/versao'), config())));
  await check('mínimo acima do recomendado recusado', assertFails(setDoc(doc(admin, 'config/versao'),
    config({ minimoAndroid: 50 }))));
  await check('build negativo recusado', assertFails(setDoc(doc(admin, 'config/versao'), config({ minimoIos: -1 }))));
  await check('build como texto recusado', assertFails(setDoc(doc(admin, 'config/versao'),
    config({ recomendadoAndroid: '44' }))));
  await check('mensagem longa recusada', assertFails(setDoc(doc(admin, 'config/versao'),
    config({ mensagem: 'x'.repeat(301) }))));
  await check('campo estranho recusado', assertFails(setDoc(doc(admin, 'config/versao'), config({ forcar: true }))));
}
