import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { Timestamp, doc, getDoc, serverTimestamp, setDoc, updateDoc } from 'firebase/firestore';

const hoursAgo = (h) => Timestamp.fromMillis(Date.now() - h * 3600 * 1000);

/** Álbum de figurinhas: catálogo, pacotinho a cada 24 h e o álbum da conta. */
export default async function run(env, check) {
  const seed = (path, data) => env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), path), data));
  await seed('usuarios/admin', { idUsuario: 'admin', admin: true });
  await seed('album_eventos/ev1', { titulo: 'Copa', ativo: true });
  await seed('album_eventos/ev2', { titulo: 'Velha', ativo: false });
  await seed('album_eventos/ev3', { titulo: 'Teste', ativo: true, somenteAdmin: true });
  await seed('album_eventos/ev1/figurinhas/f1', { idTime: 't1', nome: 'Escudo' });
  // u2 abriu o 1º pacote há 1 h; u3 abriu há 25 h.
  await seed('usuarios/u2/album/ev1', { figurinhas: { f1: 1 }, pacotes: 1, ultimoPacote: hoursAgo(1) });
  await seed('usuarios/u3/album/ev1', { figurinhas: { f1: 1 }, pacotes: 1, ultimoPacote: hoursAgo(25) });

  const u1 = env.authenticatedContext('u1').firestore();
  const u2 = env.authenticatedContext('u2').firestore();
  const u3 = env.authenticatedContext('u3').firestore();
  const admin = env.authenticatedContext('admin').firestore();
  const anon = env.unauthenticatedContext().firestore();
  const pack = (extra = {}) => ({ uid: 'u1', idEvento: 'ev1', status: 'pedido', pedidoEm: serverTimestamp(), ...extra });

  await check('catálogo público', assertSucceeds(getDoc(doc(anon, 'album_eventos/ev1/figurinhas/f1'))));
  await check('usuário não mexe no catálogo', assertFails(setDoc(doc(u1, 'album_eventos/ev1/figurinhas/f2'), { nome: 'x' })));
  await check('admin mexe no catálogo', assertSucceeds(setDoc(doc(admin, 'album_eventos/ev1/figurinhas/f2'), { nome: 'x' })));
  await check('usuário não liga o evento', assertFails(updateDoc(doc(u1, 'album_eventos/ev1'), { ativo: false })));

  await check('pede o 1º pacote', assertSucceeds(setDoc(doc(u1, 'album_pacotes/ev1_u1_1'), pack())));
  await check('o mesmo pacote de novo recusado', assertFails(setDoc(doc(u1, 'album_pacotes/ev1_u1_1'), pack())));
  await check('pular a sequência recusado', assertFails(setDoc(doc(u1, 'album_pacotes/ev1_u1_2'), pack())));
  await check('id no formato antigo (dia) recusado', assertFails(setDoc(doc(u1, 'album_pacotes/ev1_u1_2026-10-30'), pack())));
  await check('antes das 24 h recusado', assertFails(setDoc(doc(u2, 'album_pacotes/ev1_u2_2'), pack({ uid: 'u2' }))));
  await check('depois das 24 h libera', assertSucceeds(setDoc(doc(u3, 'album_pacotes/ev1_u3_2'), pack({ uid: 'u3' }))));
  await check('não acumula (pacote seguinte ao liberado) recusado', assertFails(setDoc(doc(u3, 'album_pacotes/ev1_u3_3'), pack({ uid: 'u3' }))));
  await check('pacote no nome de outro recusado', assertFails(setDoc(doc(u1, 'album_pacotes/ev1_u3_2'), pack({ uid: 'u3' }))));
  await check('pacote já aberto pelo app recusado', assertFails(setDoc(doc(u2, 'album_pacotes/ev2_u2_1'), pack({ uid: 'u2', idEvento: 'ev2', status: 'aberto' }))));
  await check('evento desligado recusado', assertFails(setDoc(doc(u2, 'album_pacotes/ev2_u2_1'), pack({ uid: 'u2', idEvento: 'ev2' }))));
  await check('com figurinhas escolhidas recusado', assertFails(setDoc(doc(u1, 'album_pacotes/ev3_u1_1'), pack({ idEvento: 'ev1', figurinhas: ['f1'] }))));
  await check('evento em teste: usuário não pede pacote', assertFails(setDoc(doc(u2, 'album_pacotes/ev3_u2_1'), pack({ uid: 'u2', idEvento: 'ev3' }))));
  await check('evento em teste: admin pede pacote', assertSucceeds(setDoc(doc(admin, 'album_pacotes/ev3_admin_1'), pack({ uid: 'admin', idEvento: 'ev3' }))));
  await check('lê o próprio pacote', assertSucceeds(getDoc(doc(u1, 'album_pacotes/ev1_u1_1'))));
  await check('não lê o pacote de outro', assertFails(getDoc(doc(u2, 'album_pacotes/ev1_u1_1'))));

  await seed('album_eventos/ev1/ranking/u2', { uid: 'u2', nome: 'Bia', coladas: 1 });
  await check('ranking público', assertSucceeds(getDoc(doc(anon, 'album_eventos/ev1/ranking/u2'))));
  await check('dono não mexe no ranking', assertFails(setDoc(doc(u2, 'album_eventos/ev1/ranking/u2'), { coladas: 99 })));
  await check('admin não grava ranking (só as functions)', assertFails(setDoc(doc(admin, 'album_eventos/ev1/ranking/u1'), { coladas: 1 })));
  await check('dono lê o álbum', assertSucceeds(getDoc(doc(u2, 'usuarios/u2/album/ev1'))));
  await check('não lê o álbum de outro', assertFails(getDoc(doc(u1, 'usuarios/u2/album/ev1'))));
  await check('dono não cola figurinha na mão', assertFails(setDoc(doc(u2, 'usuarios/u2/album/ev1'), { figurinhas: { f1: 99 } })));
}
