import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, serverTimestamp, setDoc } from 'firebase/firestore';

/** Bolão: o palpite só vale com a partida ainda não iniciada (nem pausada). */
export default async function run(env, check) {
  const seed = (path, data) => env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), path), data));
  await seed('partidas2026/aberta', { timeC: 'A', timeF: 'B' });
  await seed('partidas2026/pausada', { timeC: 'A', timeF: 'B', status: 'aguardando' });
  await seed('partidas2026/andamento', { timeC: 'A', timeF: 'B', status: 'andamento' });

  const u1 = env.authenticatedContext('u1').firestore();
  const guess = () => ({ golsCasa: 2, golsFora: 1, nome: 'Ana', atualizadoEm: serverTimestamp() });

  await check('palpite antes do jogo', assertSucceeds(setDoc(doc(u1, 'partidas2026/aberta/palpites/u1'), guess())));
  await check('partida pausada: palpite recusado', assertFails(setDoc(doc(u1, 'partidas2026/pausada/palpites/u1'), guess())));
  await check('em andamento: palpite recusado', assertFails(setDoc(doc(u1, 'partidas2026/andamento/palpites/u1'), guess())));
}
