import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, serverTimestamp, setDoc } from 'firebase/firestore';

/** Pontuações (painel do admin): tabela padrão do Fantasy e regras do bolão. */
export default async function run(env, check) {
  await env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), 'usuarios/admin'), { idUsuario: 'admin', admin: true }));
  const admin = env.authenticatedContext('admin').firestore();
  const user = env.authenticatedContext('u1').firestore();
  const guest = env.unauthenticatedContext().firestore();
  const table = (extra = {}) => ({
    base: 10, gol: 5, assistencia: 5, vitoria: 3, empate: 0, derrota: -3, amarelo: -3, vermelho: -5,
    golsSofridos: { gol: -3, zag: -2, mei: -1, ata: -1 },
    semSofrerGols: { gol: 5, zag: 3, mei: 2, ata: 2 },
    golEquipe: { gol: 0.5, zag: 0.5, mei: 0.5, ata: 0.5 },
    ...extra,
  });
  const fantasy = (t) => ({ tabela: t, atualizadoEm: serverTimestamp() });
  const ref = (db) => doc(db, 'config/pontuacao_fantasy');

  await check('admin grava a tabela do Fantasy', assertSucceeds(setDoc(ref(admin), fantasy(table()))));
  await check('convidado lê a tabela', assertSucceeds(getDoc(ref(guest))));
  await check('usuário comum não grava', assertFails(setDoc(ref(user), fantasy(table()))));
  await check('fora da faixa recusado', assertFails(setDoc(ref(admin), fantasy(table({ gol: 25 })))));
  await check('passo diferente de 0,5 recusado', assertFails(setDoc(ref(admin), fantasy(table({ base: 1.3 })))));
  await check('posição estranha recusada', assertFails(setDoc(ref(admin),
    fantasy(table({ golEquipe: { gol: 1, lat: 1 } })))));
  await check('regra estranha recusada', assertFails(setDoc(ref(admin), fantasy(table({ hatTrick: 3 })))));
  await check('valor como texto recusado', assertFails(setDoc(ref(admin), fantasy(table({ vitoria: '3' })))));

  const bolao = (extra = {}) => ({ exato: 12, vencedorSaldo: 8, vencedor: 4, atualizadoEm: serverTimestamp(), ...extra });
  const bolaoRef = (db) => doc(db, 'config/bolao');
  await check('admin grava o bolão', assertSucceeds(setDoc(bolaoRef(admin), bolao())));
  await check('convidado lê o bolão', assertSucceeds(getDoc(bolaoRef(guest))));
  await check('usuário comum não grava o bolão', assertFails(setDoc(bolaoRef(user), bolao())));
  await check('exato abaixo do saldo recusado', assertFails(setDoc(bolaoRef(admin), bolao({ exato: 5 }))));
  await check('acima de 50 recusado', assertFails(setDoc(bolaoRef(admin), bolao({ exato: 60 }))));
  await check('decimal recusado', assertFails(setDoc(bolaoRef(admin), bolao({ vencedor: 2.5 }))));
}
