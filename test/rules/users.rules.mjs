import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, setDoc, updateDoc } from 'firebase/firestore';

/** "Meu perfil": nome (3 a 40 caracteres) e foto da própria conta. */
export default async function run(env, check) {
  const seed = (path, data) => env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), path), data));
  await seed('usuarios/contaAna', { idUsuario: 'contaAna', admin: false, nome: 'Ana' });
  await seed('usuarios/contaBia', { idUsuario: 'contaBia', admin: false, nome: 'Bia' });
  // Conta antiga com nome curto: mexer em outro campo segue livre.
  await seed('usuarios/contaJo', { idUsuario: 'contaJo', admin: false, nome: 'Jo' });

  const ana = env.authenticatedContext('contaAna').firestore();
  const jo = env.authenticatedContext('contaJo').firestore();

  await check('troca o próprio nome', assertSucceeds(updateDoc(doc(ana, 'usuarios/contaAna'), { nome: 'Ana Souza' })));
  await check('troca a própria foto', assertSucceeds(updateDoc(doc(ana, 'usuarios/contaAna'), { urlImagem: 'https://x/y.jpg' })));
  await check('nome vazio recusado', assertFails(updateDoc(doc(ana, 'usuarios/contaAna'), { nome: '' })));
  await check('nome de 2 letras recusado', assertFails(updateDoc(doc(ana, 'usuarios/contaAna'), { nome: 'An' })));
  await check('nome com mais de 40 recusado', assertFails(updateDoc(doc(ana, 'usuarios/contaAna'), { nome: 'A'.repeat(41) })));
  await check('nome que não é texto recusado', assertFails(updateDoc(doc(ana, 'usuarios/contaAna'), { nome: 42 })));
  await check('nome de outra conta recusado', assertFails(updateDoc(doc(ana, 'usuarios/contaBia'), { nome: 'Bia Lima' })));
  await check('conta antiga de nome curto troca a foto', assertSucceeds(updateDoc(doc(jo, 'usuarios/contaJo'), { urlImagem: 'https://x/z.jpg' })));
}
