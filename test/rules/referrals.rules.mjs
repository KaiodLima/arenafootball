import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { Timestamp, doc, getDoc, serverTimestamp, setDoc, updateDoc } from 'firebase/firestore';

const hoursAgo = (h) => Timestamp.fromMillis(Date.now() - h * 3600 * 1000);

/** Indique amigos: código da conta, `indicadoPor` uma vez e o pacotinho extra. */
export default async function run(env, check) {
  const seed = (path, data) => env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), path), data));
  await seed('album_eventos/ev1', { titulo: 'Copa', ativo: true });
  await seed('usuarios/amigoAbc123/album/ev1', { pacotes: 1, ultimoPacote: hoursAgo(1) });
  await seed('usuarios/semSaldo99/album/ev1', { pacotes: 1, ultimoPacote: hoursAgo(1) });
  await seed('indicacoes/amigoAbc123', { pacotesExtras: 1 });
  await seed('usuarios/novaConta1', { idUsuario: 'novaConta1', admin: false, nome: 'Ana' });

  const owner = env.authenticatedContext('donoXyz789').firestore();
  const friend = env.authenticatedContext('amigoAbc123').firestore();
  const broke = env.authenticatedContext('semSaldo99').firestore();
  const fresh = env.authenticatedContext('novaConta1').firestore();
  const pack = (uid, extra = {}) => ({ uid, idEvento: 'ev1', status: 'pedido', pedidoEm: serverTimestamp(), ...extra });

  await check('cria o próprio código', assertSucceeds(setDoc(doc(owner, 'codigos_indicacao/DONOXYZ7'), { uid: 'donoXyz789' })));
  await check('código de 10 caracteres', assertSucceeds(setDoc(doc(owner, 'codigos_indicacao/DONOXYZ789'), { uid: 'donoXyz789' })));
  await check('código que não é do uid recusado', assertFails(setDoc(doc(owner, 'codigos_indicacao/AMIGOABC'), { uid: 'donoXyz789' })));
  await check('código no nome de outro recusado', assertFails(setDoc(doc(friend, 'codigos_indicacao/DONOXYZ7'), { uid: 'donoXyz789' })));
  await check('dono lê o código', assertSucceeds(getDoc(doc(owner, 'codigos_indicacao/DONOXYZ7'))));
  await check('outro não lê o código', assertFails(getDoc(doc(friend, 'codigos_indicacao/DONOXYZ7'))));

  await check('grava quem indicou', assertSucceeds(updateDoc(doc(fresh, 'usuarios/novaConta1'), { indicadoPor: 'DONOXYZ7' })));
  await check('trocar quem indicou recusado', assertFails(updateDoc(doc(fresh, 'usuarios/novaConta1'), { indicadoPor: 'AMIGOABC' })));
  await check('outros campos seguem livres', assertSucceeds(updateDoc(doc(fresh, 'usuarios/novaConta1'), { nome: 'Ana Souza' })));
  await check(
    'cadastro com o próprio código recusado',
    assertFails(setDoc(doc(friend, 'usuarios/amigoAbc123'), { idUsuario: 'amigoAbc123', admin: false, indicadoPor: 'AMIGOABC' })),
  );
  await check(
    'cadastro com código mal formado recusado',
    assertFails(setDoc(doc(owner, 'usuarios/donoXyz789'), { idUsuario: 'donoXyz789', admin: false, indicadoPor: 'abc' })),
  );

  await check('lê o próprio saldo', assertSucceeds(getDoc(doc(friend, 'indicacoes/amigoAbc123'))));
  await check('não lê o saldo de outro', assertFails(getDoc(doc(owner, 'indicacoes/amigoAbc123'))));
  await check('app não grava saldo', assertFails(setDoc(doc(friend, 'indicacoes/amigoAbc123'), { pacotesExtras: 9 })));

  await check('pacote extra com saldo antes das 24 h', assertSucceeds(setDoc(doc(friend, 'album_pacotes/ev1_amigoAbc123_2'), pack('amigoAbc123', { extra: true }))));
  await check('pacote extra sem saldo recusado', assertFails(setDoc(doc(broke, 'album_pacotes/ev1_semSaldo99_2'), pack('semSaldo99', { extra: true }))));

  await seed('usuarios/admin', { idUsuario: 'admin', admin: true });
  const admin = env.authenticatedContext('admin').firestore();
  const anon = env.unauthenticatedContext().firestore();
  await check('config da indicação pública', assertSucceeds(getDoc(doc(anon, 'config/indicacao'))));
  await check('usuário não liga a indicação', assertFails(setDoc(doc(friend, 'config/indicacao'), { ativo: true })));
  await check('admin liga a indicação', assertSucceeds(setDoc(doc(admin, 'config/indicacao'), { ativo: true })));
}
