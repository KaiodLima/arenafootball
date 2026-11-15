import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { Timestamp, deleteDoc, doc, getDoc, serverTimestamp, setDoc, updateDoc } from 'firebase/firestore';

const inHours = (h) => Timestamp.fromMillis(Date.now() + h * 3600 * 1000);

/** Evento de votação: voto único, só em opção válida e com o evento aberto; apuração conforme o parcial. */
export default async function run(env, check) {
  const seed = (path, data) => env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), path), data));
  const event = (extra = {}) => ({
    tag: 'evento',
    titulo: 'Gol mais bonito',
    idsOpcoes: ['o1', 'o2'],
    encerraEm: inHours(24),
    mostrarParcial: true,
    ...extra,
  });
  await seed('usuarios/admin1', { idUsuario: 'admin1', admin: true });
  await seed('noticias/aberto', event());
  await seed('noticias/oculto', event({ mostrarParcial: false }));
  await seed('noticias/vencido', event({ encerraEm: inHours(-1), mostrarParcial: false }));
  await seed('noticias/fechado', event({ encerrado: true, mostrarParcial: false }));
  await seed('noticias/comum', { titulo: 'Notícia', idsOpcoes: ['o1'] });
  for (const id of ['aberto', 'oculto', 'vencido', 'fechado']) {
    await seed(`noticias/${id}/apuracao/total`, { votos: { o1: 3 }, total: 3 });
  }

  const ana = env.authenticatedContext('ana').firestore();
  const bia = env.authenticatedContext('bia').firestore();
  const admin = env.authenticatedContext('admin1').firestore();
  const guest = env.unauthenticatedContext().firestore();
  const vote = (opcao, uid = 'ana', extra = {}) => ({ opcao, nome: 'Ana', uid, em: serverTimestamp(), ...extra });

  await check('vota numa opção do evento', assertSucceeds(setDoc(doc(ana, 'noticias/aberto/votos_evento/ana'), vote('o1'))));
  await check('não troca o voto', assertFails(updateDoc(doc(ana, 'noticias/aberto/votos_evento/ana'), { opcao: 'o2' })));
  await check('não regrava o voto', assertFails(setDoc(doc(ana, 'noticias/aberto/votos_evento/ana'), vote('o2'))));
  await check('não apaga o voto', assertFails(deleteDoc(doc(ana, 'noticias/aberto/votos_evento/ana'))));
  await check('lê o próprio voto', assertSucceeds(getDoc(doc(ana, 'noticias/aberto/votos_evento/ana'))));
  await check('não lê o voto de outro', assertFails(getDoc(doc(bia, 'noticias/aberto/votos_evento/ana'))));
  await check('opção que não existe recusada', assertFails(setDoc(doc(bia, 'noticias/aberto/votos_evento/bia'), vote('o9', 'bia'))));
  await check('voto no nome de outro recusado', assertFails(setDoc(doc(bia, 'noticias/aberto/votos_evento/ana'), vote('o1', 'ana'))));
  await check(
    'campo extra recusado',
    assertFails(setDoc(doc(bia, 'noticias/aberto/votos_evento/bia'), vote('o1', 'bia', { peso: 10 }))),
  );
  await check(
    'hora inventada recusada',
    assertFails(setDoc(doc(bia, 'noticias/aberto/votos_evento/bia'), vote('o1', 'bia', { em: inHours(-5) }))),
  );
  await check('prazo vencido: voto recusado', assertFails(setDoc(doc(bia, 'noticias/vencido/votos_evento/bia'), vote('o1', 'bia'))));
  await check('encerrado: voto recusado', assertFails(setDoc(doc(bia, 'noticias/fechado/votos_evento/bia'), vote('o1', 'bia'))));
  await check('notícia comum: voto recusado', assertFails(setDoc(doc(bia, 'noticias/comum/votos_evento/bia'), vote('o1', 'bia'))));
  await check('convidado não vota', assertFails(setDoc(doc(guest, 'noticias/aberto/votos_evento/x'), vote('o1', 'x'))));

  await check('parcial ligado: apuração lida', assertSucceeds(getDoc(doc(bia, 'noticias/aberto/apuracao/total'))));
  await check('parcial desligado e aberto: apuração escondida', assertFails(getDoc(doc(bia, 'noticias/oculto/apuracao/total'))));
  await check('parcial desligado: o admin lê', assertSucceeds(getDoc(doc(admin, 'noticias/oculto/apuracao/total'))));
  await check('prazo vencido: apuração aberta a todos', assertSucceeds(getDoc(doc(guest, 'noticias/vencido/apuracao/total'))));
  await check('encerrado: apuração aberta a todos', assertSucceeds(getDoc(doc(bia, 'noticias/fechado/apuracao/total'))));
  await check('ninguém grava a apuração', assertFails(setDoc(doc(admin, 'noticias/aberto/apuracao/total'), { votos: {} })));
}
