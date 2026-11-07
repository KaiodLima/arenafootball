import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteDoc, deleteField, doc, getDoc, serverTimestamp, setDoc, updateDoc } from 'firebase/firestore';

/** "Sou organizador de campeonato": o pedido e a edição do campeonato pelo organizador. */
export default async function run(env, check) {
  const seed = (path, data) => env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), path), data));
  await seed('usuarios/admin', { idUsuario: 'admin', admin: true });
  await seed('campeonatos/c1', {
    titulo: 'Copa Verde', idRegiao: 'co', fk_competicao: 'Colônia', abrangencia: 'municipal', ano: '2026',
    id_campeonato: 8, idsRegioes: ['co'], times: [], ids_times: [], descricao: '', idOrganizador: 'org1',
  });
  await seed('campeonatos/c2', {
    titulo: 'Copa Azul', idRegiao: 'co', abrangencia: 'intermunicipal', ano: '2026', id_campeonato: 9,
    idsRegioes: ['co'], idOrganizador: 'org1',
  });
  await seed('campeonatos/c3', { titulo: 'Do admin', idRegiao: 'fl', abrangencia: 'municipal', id_campeonato: 10 });

  const org = env.authenticatedContext('org1').firestore();
  const other = env.authenticatedContext('u2').firestore();
  const admin = env.authenticatedContext('admin').firestore();
  const request = (extra = {}) => ({
    uid: 'org1', nome_usuario: 'Ana', email: 'a@x.com', nome: 'Copa Nova', regiao: 'Colônia', idRegiao: 'co',
    abrangencia: 'municipal', descricao: '', urlImagem: '', contato: '89999999999', temporada: '2026',
    status: 'pendente', data: serverTimestamp(), atualizado_em: serverTimestamp(), ...extra,
  });

  await check('envia o próprio pedido', assertSucceeds(setDoc(doc(org, 'solicitacoes_organizador/org1'), request())));
  await check('corrige o pendente', assertSucceeds(setDoc(doc(org, 'solicitacoes_organizador/org1'), request({ nome: 'Copa Nova 2' }))));
  await check('não se aprova', assertFails(updateDoc(doc(org, 'solicitacoes_organizador/org1'), { status: 'aprovada' })));
  await check('não grava o campeonato no pedido', assertFails(setDoc(doc(org, 'solicitacoes_organizador/org1'), request({ idCampeonato: 'c9' }))));
  await check('categoria inválida recusada', assertFails(setDoc(doc(org, 'solicitacoes_organizador/org1'), request({ abrangencia: 'estadual' }))));
  await check('pedido no nome de outro recusado', assertFails(setDoc(doc(other, 'solicitacoes_organizador/org1'), request({ uid: 'u2' }))));
  await check('outro não lê o pedido', assertFails(getDoc(doc(other, 'solicitacoes_organizador/org1'))));
  await check('admin aprova', assertSucceeds(updateDoc(doc(admin, 'solicitacoes_organizador/org1'), { status: 'aprovada', idCampeonato: 'c1' })));
  await check('respondido: manda outro pedido', assertSucceeds(setDoc(doc(org, 'solicitacoes_organizador/org1'), request({ nome: 'Copa Outra' }))));

  await check('organizador edita os detalhes', assertSucceeds(updateDoc(doc(org, 'campeonatos/c1'), { descricao: 'Final em dezembro', premio1: 'Troféu' })));
  await check('organizador não troca o nome', assertFails(updateDoc(doc(org, 'campeonatos/c1'), { titulo: 'Outro' })));
  await check('organizador não troca a sede', assertFails(updateDoc(doc(org, 'campeonatos/c1'), { idRegiao: 'fl' })));
  await check('organizador não troca o organizador', assertFails(updateDoc(doc(org, 'campeonatos/c1'), { idOrganizador: 'u2' })));
  await check('municipal: regiões só a sede', assertFails(updateDoc(doc(org, 'campeonatos/c1'), { idsRegioes: ['co', 'fl'] })));
  await check('intermunicipal: regiões dos times', assertSucceeds(updateDoc(doc(org, 'campeonatos/c2'), { idsRegioes: ['co', 'fl'], times: ['A'], ids_times: ['t1'] })));
  await check('organizador não edita campeonato de outro', assertFails(updateDoc(doc(org, 'campeonatos/c3'), { descricao: 'x' })));
  await check('usuário comum não edita campeonato', assertFails(updateDoc(doc(other, 'campeonatos/c1'), { descricao: 'x' })));
  await check('organizador não cria campeonato', assertFails(setDoc(doc(org, 'campeonatos/c9'), { titulo: 'X', idOrganizador: 'org1' })));

  // Grupos do campeonato do organizador.
  const group = (extra = {}) => ({
    descricao: 'A', fk_competicao: 'Colônia', idRegiao: 'co', time1: 'Leões', idTime1: 't1', time2: '', idTime2: '',
    time3: '', idTime3: '', time4: '', idTime4: '', fk_campeonato: 8, idCampeonatoDoc: 'c1', ...extra,
  });
  await check('organizador cria grupo do campeonato dele', assertSucceeds(setDoc(doc(org, 'grupos2026/g1'), group())));
  await check('organizador edita o grupo', assertSucceeds(setDoc(doc(org, 'grupos2026/g1'), group({ time2: 'Tigres', idTime2: 't2' }))));
  await check('grupo em campeonato de outro recusado', assertFails(setDoc(doc(org, 'grupos2026/g2'), group({ fk_campeonato: 10, idCampeonatoDoc: 'c3' }))));
  await check('fk_campeonato forjado recusado', assertFails(setDoc(doc(org, 'grupos2026/g3'), group({ fk_campeonato: 10 }))));
  await check('campo fora do grupo recusado', assertFails(setDoc(doc(org, 'grupos2026/g4'), group({ pontos: 9 }))));
  await check('usuário comum não grava grupo', assertFails(setDoc(doc(other, 'grupos2026/g5'), group())));
  await check('usuário comum não apaga grupo', assertFails(deleteDoc(doc(other, 'grupos2026/g1'))));
  await seed('grupos2026/g9', group({ fk_campeonato: 10, idCampeonatoDoc: 'c3' }));
  await check('organizador não apaga grupo de outro', assertFails(deleteDoc(doc(org, 'grupos2026/g9'))));
  await check('organizador apaga o grupo dele', assertSucceeds(deleteDoc(doc(org, 'grupos2026/g1'))));
  await check('admin grava grupo', assertSucceeds(setDoc(doc(admin, 'grupos2026/g6'), group())));

  // Elenco da competição do organizador (índice campeonatos_org/c<id>).
  await seed('campeonatos/c4', { titulo: 'Copa Sol', id_campeonato: 11, ids_times: ['t1'], idOrganizador: 'org1' });
  await seed('campeonatos_org/c11', { idOrganizador: 'org1', idCampeonatoDoc: 'c4' });
  await seed('campeonatos/c5', { titulo: 'Copa Lua', id_campeonato: 12, ids_times: ['t1'] });
  await seed('campeonatos_org/c12', { idOrganizador: 'outro', idCampeonatoDoc: 'c5' });
  const athlete = {
    idJogador: 'p1', nome: 'Ana', time: 'Leões', idTime: 't1', urlImagem: '', nGols: 3, nAssistencias: 1,
    inscricoes: { c12: { idTime: 't1', time: 'Leões', nGols: 3, nAssistencias: 1 } }, idsTimes: ['t1'],
  };
  await seed('jogadores2026/p1', athlete);
  const entry = { idTime: 't1', time: 'Leões', nGols: 0, nAssistencias: 0 };
  await check('organizador põe atleta na competição dele',
    assertSucceeds(updateDoc(doc(org, 'jogadores2026/p1'), { 'inscricoes.c11': entry })));
  await check('organizador não mexe nos gols',
    assertFails(updateDoc(doc(org, 'jogadores2026/p1'), { nGols: 9 })));
  await check('organizador não mexe na competição de outro',
    assertFails(updateDoc(doc(org, 'jogadores2026/p1'), { 'inscricoes.c12.nGols': 0 })));
  await check('organizador não troca o time principal',
    assertFails(updateDoc(doc(org, 'jogadores2026/p1'), { idTime: 't2' })));
  await check('inscrição com gols recusada', assertFails(updateDoc(doc(org, 'jogadores2026/p1'),
    { 'inscricoes.c11': { ...entry, nGols: 5 } })));
  await check('organizador tira atleta da competição dele',
    assertSucceeds(updateDoc(doc(org, 'jogadores2026/p1'), { 'inscricoes.c11': deleteField() })));
  await check('time fora do campeonato recusado', assertFails(updateDoc(doc(org, 'jogadores2026/p1'),
    { 'inscricoes.c11': { ...entry, idTime: 't9' }, idsTimes: ['t1', 't9'] })));
  await seed('jogadores2026/p6', { ...athlete, idJogador: 'p6', inscricoes: {}, idsTimes: [] });
  await check('atleta com idsTimes antigo (sem o principal) entra na competição',
    assertSucceeds(updateDoc(doc(org, 'jogadores2026/p6'), { 'inscricoes.c11': entry, idsTimes: ['t1'] })));
  await check('idsTimes não ganha time de fora', assertFails(updateDoc(doc(org, 'jogadores2026/p6'),
    { 'inscricoes.c11': deleteField(), idsTimes: ['t1', 't7'] })));
  // Índice criado pelo próprio organizador (campeonato aprovado antes dele).
  await seed('campeonatos/c7', { titulo: 'Copa Mar', id_campeonato: 14, ids_times: ['t1'], idOrganizador: 'org1' });
  await check('organizador cria o índice do campeonato dele',
    assertSucceeds(setDoc(doc(org, 'campeonatos_org/c14'), { idOrganizador: 'org1', idCampeonatoDoc: 'c7' })));
  await check('organizador não edita o índice',
    assertFails(setDoc(doc(org, 'campeonatos_org/c14'), { idOrganizador: 'org1', idCampeonatoDoc: 'c4' })));
  await check('índice com a chave trocada recusado',
    assertFails(setDoc(doc(org, 'campeonatos_org/c99'), { idOrganizador: 'org1', idCampeonatoDoc: 'c7' })));
  await check('índice de campeonato de outro recusado',
    assertFails(setDoc(doc(org, 'campeonatos_org/c10'), { idOrganizador: 'org1', idCampeonatoDoc: 'c3' })));
  await check('usuário comum não cria índice',
    assertFails(setDoc(doc(other, 'campeonatos_org/c15'), { idOrganizador: 'u2', idCampeonatoDoc: 'c7' })));
  // Partidas da competição do organizador (c11 = Copa Sol, times ['t1']).
  await seed('campeonatos/c4', { titulo: 'Copa Sol', id_campeonato: 11, ids_times: ['t1', 't2'], idOrganizador: 'org1' });
  const match = (id, extra = {}) => ({
    id_partida: id, timeC: 'Leões', timeF: 'Tigres', idTimeC: 't1', idTimeF: 't2', data: '10/12/2026', horario: '16:00',
    local: 'Campo', id_campeonato: 11, fk_competicao: 'Colônia', idRegiao: 'co', golTimeCasa: 0, golTimeFora: 0,
    votacao: 'false', tituloVotacao: '', melhorJogador: '', quantidadeVotos: '', dataRegistro: serverTimestamp(),
    duracao: 90, ...extra,
  });
  await check('organizador cadastra partida da competição dele', assertSucceeds(setDoc(doc(org, 'partidas2026/m1'), match('m1'))));
  await check('partida em competição de outro recusada',
    assertFails(setDoc(doc(org, 'partidas2026/m2'), match('m2', { id_campeonato: 12 }))));
  await check('partida com time fora da competição recusada',
    assertFails(setDoc(doc(org, 'partidas2026/m3'), match('m3', { idTimeF: 't9' }))));
  await check('partida com placar recusada', assertFails(setDoc(doc(org, 'partidas2026/m4'), match('m4', { golTimeCasa: 2 }))));
  await check('partida com votos recusada', assertFails(setDoc(doc(org, 'partidas2026/m8'), match('m8', { quantidadeVotos: '7' }))));
  await check('partida com status recusada', assertFails(setDoc(doc(org, 'partidas2026/m5'), match('m5', { status: 'encerrada' }))));
  await check('partida com o mesmo time dos dois lados recusada',
    assertFails(setDoc(doc(org, 'partidas2026/m6'), match('m6', { idTimeF: 't1' }))));
  await check('organizador não edita a partida', assertFails(updateDoc(doc(org, 'partidas2026/m1'), { horario: '17:00' })));
  await check('organizador não apaga a partida', assertFails(deleteDoc(doc(org, 'partidas2026/m1'))));
  await check('usuário comum não cadastra partida', assertFails(setDoc(doc(other, 'partidas2026/m7'), match('m7'))));
  await check('usuário comum não inscreve', assertFails(updateDoc(doc(other, 'jogadores2026/p1'), { 'inscricoes.c11': entry })));
  const fresh = {
    idJogador: 'p2', nome: 'Bia', time: 'Leões', idTime: 't1', urlImagem: '', nGols: 0, nAssistencias: 0,
    nGolsAmistoso: 0, nAssistenciasAmistoso: 0, inscricoes: { c11: entry }, idsTimes: ['t1'],
  };
  await check('organizador cria atleta na competição', assertSucceeds(setDoc(doc(org, 'jogadores2026/p2'), fresh)));
  await check('atleta novo com gols recusado', assertFails(setDoc(doc(org, 'jogadores2026/p3'), { ...fresh, nGols: 2 })));
  await check('atleta novo em competição de outro recusado', assertFails(setDoc(doc(org, 'jogadores2026/p4'),
    { ...fresh, inscricoes: { c12: entry } })));
  await check('usuário comum não cria atleta', assertFails(setDoc(doc(other, 'jogadores2026/p5'), fresh)));
}
