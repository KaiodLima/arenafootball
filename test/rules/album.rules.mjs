import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, serverTimestamp, setDoc, updateDoc } from 'firebase/firestore';

const today = (() => {
  const d = new Date(Date.now() - 3 * 3600 * 1000);
  return `${d.getUTCFullYear()}-${d.getUTCMonth() + 1}-${d.getUTCDate()}`;
})();

/** Álbum de figurinhas: catálogo, pacote do dia e o álbum da conta. */
export default async function run(env, check) {
  const seed = (path, data) => env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), path), data));
  await seed('usuarios/admin', { idUsuario: 'admin', admin: true });
  await seed('album_eventos/ev1', { titulo: 'Copa', ativo: true });
  await seed('album_eventos/ev2', { titulo: 'Velha', ativo: false });
  await seed('album_eventos/ev1/figurinhas/f1', { idTime: 't1', nome: 'Escudo' });
  await seed('usuarios/u2/album/ev1', { figurinhas: { f1: 1 } });

  const u1 = env.authenticatedContext('u1').firestore();
  const u2 = env.authenticatedContext('u2').firestore();
  const admin = env.authenticatedContext('admin').firestore();
  const anon = env.unauthenticatedContext().firestore();
  const pack = (extra = {}) => ({ uid: 'u1', idEvento: 'ev1', status: 'pedido', pedidoEm: serverTimestamp(), ...extra });

  await check('catálogo público', assertSucceeds(getDoc(doc(anon, 'album_eventos/ev1/figurinhas/f1'))));
  await check('usuário não mexe no catálogo', assertFails(setDoc(doc(u1, 'album_eventos/ev1/figurinhas/f2'), { nome: 'x' })));
  await check('admin mexe no catálogo', assertSucceeds(setDoc(doc(admin, 'album_eventos/ev1/figurinhas/f2'), { nome: 'x' })));
  await check('usuário não liga o evento', assertFails(updateDoc(doc(u1, 'album_eventos/ev1'), { ativo: false })));

  await check('pede o pacote de hoje', assertSucceeds(setDoc(doc(u1, `album_pacotes/ev1_u1_${today}`), pack())));
  await check('segundo pacote no dia recusado', assertFails(setDoc(doc(u1, `album_pacotes/ev1_u1_${today}`), pack())));
  await check('pacote de outro dia recusado', assertFails(setDoc(doc(u1, 'album_pacotes/ev1_u1_2020-1-1'), pack())));
  await check('pacote no nome de outro recusado', assertFails(setDoc(doc(u1, `album_pacotes/ev1_u2_${today}`), pack({ uid: 'u2' }))));
  await check('pacote já aberto pelo app recusado', assertFails(setDoc(doc(u2, `album_pacotes/ev1_u2_${today}`), pack({ uid: 'u2', status: 'aberto' }))));
  await check('evento desligado recusado', assertFails(setDoc(doc(u2, `album_pacotes/ev2_u2_${today}`), pack({ uid: 'u2', idEvento: 'ev2' }))));
  await check('com figurinhas escolhidas recusado', assertFails(setDoc(doc(u2, `album_pacotes/ev1_u2_${today}`), pack({ uid: 'u2', figurinhas: ['f1'] }))));
  await check('lê o próprio pacote', assertSucceeds(getDoc(doc(u1, `album_pacotes/ev1_u1_${today}`))));
  await check('não lê o pacote de outro', assertFails(getDoc(doc(u2, `album_pacotes/ev1_u1_${today}`))));

  await check('dono lê o álbum', assertSucceeds(getDoc(doc(u2, 'usuarios/u2/album/ev1'))));
  await check('não lê o álbum de outro', assertFails(getDoc(doc(u1, 'usuarios/u2/album/ev1'))));
  await check('dono não cola figurinha na mão', assertFails(setDoc(doc(u2, 'usuarios/u2/album/ev1'), { figurinhas: { f1: 99 } })));
}
