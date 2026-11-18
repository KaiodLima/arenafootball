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

  // --- Fase 2: participantes, rodadas e escalações ---
  const future = new Date(Date.now() + 86400000);
  const past = new Date(Date.now() - 86400000);
  await seed('fantasy/fx', { idCampeonato: 8, temporada: '2026', ativo: true, minMinutos: 20, minMinutosDefesa: 45, capitao: 1.5, rodadaAtual: 1 });
  await seed('fantasy/fx/rodadas/1', { numero: 1, status: 'aberta', fechaEm: future, idsPartidas: ['m1'] });
  await seed('fantasy/fx/rodadas/9', { numero: 9, status: 'aberta', fechaEm: past, idsPartidas: ['m9'] });
  await seed('fantasy/fx/rodadas/8', { numero: 8, status: 'fechada', fechaEm: future, idsPartidas: ['m8'] });
  const athlete = (posicao, inscricoes = { c8: { idTime: 't1', time: 'Leões', nGols: 0, nAssistencias: 0 } }) => ({ nome: 'X', posicao, inscricoes });
  await seed('jogadores2026/gk', athlete('goleiro'));
  await seed('jogadores2026/lb', athlete('lateral'));
  await seed('jogadores2026/mf', athlete('meia'));
  await seed('jogadores2026/fw', athlete('atacante'));
  await seed('jogadores2026/dm', athlete('volante'));
  await seed('jogadores2026/fw2', athlete('atacante'));
  await seed('jogadores2026/other', athlete('atacante', { c9: { idTime: 't9' } }));
  await seed('jogadores2026/noteam', athlete('atacante', { c8: { idTime: '' } }));
  await seed('jogadores2026/nopos', athlete(''));

  const participant = (extra = {}) => ({ uid: 'u1', nome: 'Ana', urlImagem: '', entrouEm: serverTimestamp(), rodadaInicial: 1, ...extra });
  await check('entra no Fantasy na rodada atual', assertSucceeds(setDoc(doc(user, 'fantasy/fx/participantes/u1'), participant())));
  await check('não entra no nome de outro', assertFails(setDoc(doc(user, 'fantasy/fx/participantes/u2'), participant({ uid: 'u2' }))));
  await check('rodada inicial forjada recusada', assertFails(setDoc(doc(org, 'fantasy/fx/participantes/org1'),
    participant({ uid: 'org1', rodadaInicial: 0 }))));
  await check('não grava pontos no participante', assertFails(updateDoc(doc(user, 'fantasy/fx/participantes/u1'), { pontos: 99 })));
  await check('troca o nome', assertSucceeds(updateDoc(doc(user, 'fantasy/fx/participantes/u1'), { nome: 'Ana B' })));
  await check('não sai do Fantasy', assertFails(deleteDoc(doc(user, 'fantasy/fx/participantes/u1'))));
  await check('Fantasy desligado: não entra', assertFails(setDoc(doc(org, 'fantasy/fc1/participantes/org1'),
    participant({ uid: 'org1', rodadaInicial: 2 }))));

  const lineup = (atletas = { gol: 'gk', zag: 'lb', mei: 'mf', ata: 'fw', livre: 'dm' }, extra = {}) => ({
    uid: 'u1', nome: 'Ana', urlImagem: '', atletas,
    idsAtletas: [atletas.gol, atletas.zag, atletas.mei, atletas.ata, atletas.livre],
    capitao: atletas.ata, atualizadoEm: serverTimestamp(), copiada: false, ...extra,
  });
  const mine = (round = 1) => doc(user, `fantasy/fx/rodadas/${round}/escalacoes/u1`);
  await check('escalação válida (lateral na ZAG, volante na livre)', assertSucceeds(setDoc(mine(), lineup())));
  await check('troca o capitão até o prazo', assertSucceeds(setDoc(mine(), lineup(undefined, { capitao: 'gk' }))));
  await check('atacante na livre também vale', assertSucceeds(setDoc(mine(),
    lineup({ gol: 'gk', zag: 'lb', mei: 'mf', ata: 'fw', livre: 'fw2' }))));
  await check('incompleta recusada', assertFails(setDoc(mine(), { ...lineup(), atletas: { gol: 'gk', zag: 'lb', mei: 'mf', ata: 'fw' }, idsAtletas: ['gk', 'lb', 'mf', 'fw'] })));
  await check('atleta repetido recusado', assertFails(setDoc(mine(), lineup({ gol: 'gk', zag: 'lb', mei: 'mf', ata: 'fw', livre: 'fw' }))));
  await check('sem capitão recusado', assertFails(setDoc(mine(), lineup(undefined, { capitao: '' }))));
  await check('capitão de fora recusado', assertFails(setDoc(mine(), lineup(undefined, { capitao: 'fw2' }))));
  await check('idsAtletas diferentes das vagas recusado', assertFails(setDoc(mine(),
    { ...lineup(), idsAtletas: ['gk', 'lb', 'mf', 'fw2', 'dm'] })));
  await check('atleta de outra competição recusado', assertFails(setDoc(mine(), lineup({ gol: 'gk', zag: 'lb', mei: 'mf', ata: 'other', livre: 'dm' }))));
  await check('atleta sem time na competição recusado', assertFails(setDoc(mine(), lineup({ gol: 'gk', zag: 'lb', mei: 'mf', ata: 'noteam', livre: 'dm' }))));
  await check('posição errada na vaga recusada', assertFails(setDoc(mine(), lineup({ gol: 'fw', zag: 'lb', mei: 'mf', ata: 'fw2', livre: 'dm' }))));
  await check('sem posição nem na livre', assertFails(setDoc(mine(), lineup({ gol: 'gk', zag: 'lb', mei: 'mf', ata: 'fw', livre: 'nopos' }))));
  await check('cliente gravando pontos recusado', assertFails(setDoc(mine(), lineup(undefined, { pontos: 50 }))));
  await check('fora do prazo recusado', assertFails(setDoc(mine(9), lineup())));
  await check('rodada fechada recusada', assertFails(setDoc(mine(8), lineup())));
  await check('sem ser participante recusado', assertFails(setDoc(doc(org, 'fantasy/fx/rodadas/1/escalacoes/org1'),
    lineup(undefined, { uid: 'org1' }))));
  await check('escalação no nome de outro recusada', assertFails(setDoc(doc(user, 'fantasy/fx/rodadas/1/escalacoes/u2'),
    lineup(undefined, { uid: 'u2' }))));
  await check('marcar como copiada recusado', assertFails(setDoc(mine(), lineup(undefined, { copiada: true }))));
  await check('convidado lê a escalação', assertSucceeds(getDoc(doc(guest, 'fantasy/fx/rodadas/1/escalacoes/u1'))));
  await check('cliente não grava rodada', assertFails(updateDoc(doc(admin, 'fantasy/fx/rodadas/1'), { status: 'fechada' })));
  await check('não apaga a escalação', assertFails(deleteDoc(mine())));
}
