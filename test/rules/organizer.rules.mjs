import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { arrayUnion, deleteDoc, deleteField, doc, getDoc, increment, serverTimestamp, setDoc, updateDoc } from 'firebase/firestore';

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
  const six = ['a', 'b', 'c', 'd', 'e', 'f'];
  await check('grupo de 6 times (listas)', assertSucceeds(setDoc(doc(org, 'grupos2026/g7'), group({ times: six, idsTimes: six }))));
  const many = Array.from({ length: 21 }, (_, i) => `t${i}`);
  await check('grupo com mais de 20 recusado', assertFails(setDoc(doc(org, 'grupos2026/g8'), group({ times: many, idsTimes: many }))));
  const regras = { classificados: 2, proximaFase: 'Semifinal', repescagem: 1, eliminados: 1, idaVolta: true };
  await check('grupo com regras', assertSucceeds(setDoc(doc(org, 'grupos2026/g10'), group({ regras }))));
  await check('regras com chave estranha recusadas',
    assertFails(setDoc(doc(org, 'grupos2026/g11'), group({ regras: { ...regras, pontos: 3 } }))));
  await check('regras com número fora do limite recusadas',
    assertFails(setDoc(doc(org, 'grupos2026/g12'), group({ regras: { ...regras, classificados: 30 } }))));
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
  await check('organizador não edita os times da partida', assertFails(updateDoc(doc(org, 'partidas2026/m1'), { timeF: 'Outro' })));
  await check('organizador não apaga a partida', assertFails(deleteDoc(doc(org, 'partidas2026/m1'))));
  await check('usuário comum não cadastra partida', assertFails(setDoc(doc(other, 'partidas2026/m7'), match('m7'))));
  // Súmula do organizador (partida m1 da Copa Sol, c11).
  await check('súmula: inicia a partida', assertSucceeds(updateDoc(doc(org, 'partidas2026/m1'),
    { status: 'andamento', statusEm: serverTimestamp(), inicioEm: serverTimestamp() })));
  await check('súmula: salva gols, cartões, escalação e dados do jogo', assertSucceeds(updateDoc(doc(org, 'partidas2026/m1'), {
    gols: [{ id: 'g1', lado: 'casa', idJogador: 'p7', jogador: 'Ana', idAssistencia: '', assistencia: '', minuto: 12 }],
    golTimeCasa: 1, golTimeFora: 0, cartoes: [], escalacao: { casa: [], fora: [] }, arbitro: 'Zé', observacoes: '',
    data: '10/12/2026', horario: '16:00', duracao: 90, local: 'Campo',
  })));
  await check('súmula: registra substituição', assertSucceeds(updateDoc(doc(org, 'partidas2026/m1'), {
    substituicoes: [{ id: 's1', lado: 'casa', idSai: 'p7', sai: 'Ana', idEntra: 'p8', entra: 'Bia', minuto: 60 }],
    escalacao: { casa: [{ idJogador: 'p8', jogador: 'Bia', titular: false }], fora: [] },
  })));
  await check('súmula: abre a votação', assertSucceeds(updateDoc(doc(org, 'partidas2026/m1'), { votacao: 'true' })));
  await check('súmula: atrasou', assertSucceeds(updateDoc(doc(org, 'partidas2026/m1'),
    { horario: '16:20', horarioOriginal: '16:00', status: deleteField(), statusEm: deleteField(), inicioEm: deleteField() })));
  await check('súmula não troca time', assertFails(updateDoc(doc(org, 'partidas2026/m1'), { timeC: 'Outro', idTimeC: 't9' })));
  await check('súmula não troca a competição', assertFails(updateDoc(doc(org, 'partidas2026/m1'), { id_campeonato: 12 })));
  await check('súmula não grava o craque', assertFails(updateDoc(doc(org, 'partidas2026/m1'), { craque: { idJogador: 'p7' } })));
  await seed('partidas2026/m9', { id_partida: 'm9', id_campeonato: 12, idTimeC: 't1', idTimeF: 't2', golTimeCasa: 0 });
  await check('súmula de partida de outra competição recusada',
    assertFails(updateDoc(doc(org, 'partidas2026/m9'), { golTimeCasa: 1 })));
  await check('usuário comum não mexe na súmula', assertFails(updateDoc(doc(other, 'partidas2026/m1'), { golTimeCasa: 3 })));

  // Números do atleta (como o incrementStats grava).
  await seed('jogadores2026/p7', {
    idJogador: 'p7', nome: 'Ana', time: 'Leões', idTime: 't1', urlImagem: '', nGols: 3, nAssistencias: 0,
    inscricoes: { c11: { idTime: 't1', time: 'Leões', nGols: 0, nAssistencias: 0 } }, idsTimes: ['t1'],
  });
  const goal = (n = 1, extra = {}) => ({
    nGols: increment(n), 'inscricoes.c11.idTime': 't1', 'inscricoes.c11.time': 'Leões',
    'inscricoes.c11.nGols': increment(n), 'inscricoes.c11.nAssistencias': increment(0), idsTimes: arrayUnion('t1'), ...extra,
  });
  await check('gol soma no atleta (Geral + competição)', assertSucceeds(updateDoc(doc(org, 'jogadores2026/p7'), goal())));
  await check('gol tirado desconta', assertSucceeds(updateDoc(doc(org, 'jogadores2026/p7'), goal(-1))));
  await check('número inflado no Geral recusado', assertFails(updateDoc(doc(org, 'jogadores2026/p7'),
    { ...goal(), nGols: increment(5) })));
  await check('mais de 10 por vez recusado', assertFails(updateDoc(doc(org, 'jogadores2026/p7'), goal(11))));
  await check('números em competição de outro recusados', assertFails(updateDoc(doc(org, 'jogadores2026/p7'), {
    nGols: increment(1), 'inscricoes.c12.idTime': 't1', 'inscricoes.c12.time': 'Leões', 'inscricoes.c12.nGols': increment(1),
    'inscricoes.c12.nAssistencias': increment(0),
  })));
  await check('números não trocam o time principal', assertFails(updateDoc(doc(org, 'jogadores2026/p7'), { ...goal(), idTime: 't2' })));
  await seed('jogadores2026/p8', { idJogador: 'p8', nome: 'Bia', time: 'Leões', idTime: 't1', nGols: 0, nAssistencias: 0,
    inscricoes: {}, idsTimes: ['t1'] });
  await check('gol de atleta ainda sem a inscrição cria a dela', assertSucceeds(updateDoc(doc(org, 'jogadores2026/p8'), goal())));
  await check('usuário comum não soma gol', assertFails(updateDoc(doc(other, 'jogadores2026/p7'), goal())));

  // Card de gol do organizador.
  const card = (extra = {}) => ({
    id: 'k1', titulo: '', descricao: '', urlImagem: '', link: '', exibir: 'true', fk_competicao: 'Colônia', idRegiao: 'co',
    time_casa: 'Leões', time_fora: 'Tigres', gol_time_casa: '1', gol_time_fora: '0', tag: 'gol', autor_gol_id: 'p7',
    autor_gol: 'Ana', temporada: '2026', time_marcador: 'Leões', id_time_casa: 't1', id_time_fora: 't2',
    id_time_marcador: 't1', id_campeonato: 11, id_partida: 'm1', id_gol: 'g1', idAutor: 'org1', data: serverTimestamp(),
    ...extra,
  });
  await check('organizador publica card de gol', assertSucceeds(setDoc(doc(org, 'noticias/k1'), card())));
  await check('organizador edita o card dele', assertSucceeds(setDoc(doc(org, 'noticias/k1'), card({ autor_gol: 'Ana B.' }))));
  await check('card de gol de outra competição recusado',
    assertFails(setDoc(doc(org, 'noticias/k2'), card({ id: 'k2', id_campeonato: 12 }))));
  await check('card de gol com outro autor recusado', assertFails(setDoc(doc(org, 'noticias/k3'), card({ id: 'k3', idAutor: 'u2' }))));
  await check('notícia comum do organizador recusada',
    assertFails(setDoc(doc(org, 'noticias/k4'), card({ id: 'k4', tag: 'noticia' }))));
  await seed('noticias/k5', card({ id: 'k5', idAutor: '' }));
  await check('organizador não apaga card do admin', assertFails(deleteDoc(doc(org, 'noticias/k5'))));
  await check('organizador apaga o card dele', assertSucceeds(deleteDoc(doc(org, 'noticias/k1'))));

  // Card ao vivo da partida m1 (Copa Sol).
  const live = (extra = {}) => ({
    id: 'aovivo_m1', tag: 'aovivo', exibir: 'true', titulo: 'Leões 1 × 0 Tigres · ao vivo', descricao: "⚽ 12' Ana",
    fk_competicao: 'Colônia', idRegiao: 'co', time_casa: 'Leões', time_fora: 'Tigres', gol_time_casa: '1',
    gol_time_fora: '0', id_time_casa: 't1', id_time_fora: 't2', id_partida: 'm1', id_campeonato: 11, temporada: '2026',
    ultimo_lance: { id: 'g1', tipo: 'gol', lado: 'casa', minuto: 12, jogador: 'Ana' },
    lances: [{ id: 'g1', tipo: 'gol', lado: 'casa', minuto: 12, jogador: 'Ana' }], data: serverTimestamp(), ...extra,
  });
  await check('organizador cria o card ao vivo', assertSucceeds(setDoc(doc(org, 'noticias/aovivo_m1'), live())));
  await seed('noticias/aovivo_m1', { ...live(), data: new Date(), idAutor: 'admin' });
  await check('organizador atualiza o card ao vivo do admin', assertSucceeds(setDoc(doc(org, 'noticias/aovivo_m1'),
    live({ gol_time_casa: '2', descricao: "🟥 30' Bia" }))));
  await check('organizador só atualiza o conteúdo (lance apagado)', assertSucceeds(updateDoc(doc(org, 'noticias/aovivo_m1'),
    { gol_time_casa: '1', lances: [] })));
  await check('card ao vivo com id de outra partida recusado',
    assertFails(setDoc(doc(org, 'noticias/aovivo_m2'), live())));
  await check('card ao vivo de partida de outra competição recusado',
    assertFails(setDoc(doc(org, 'noticias/aovivo_m9'), live({ id: 'aovivo_m9', id_partida: 'm9', id_campeonato: 12 }))));
  await check('organizador não apaga o card ao vivo', assertFails(deleteDoc(doc(org, 'noticias/aovivo_m1'))));
  await check('organizador cria o card oculto do vermelho', assertSucceeds(setDoc(doc(org, 'noticias/v1'),
    (({ autor_gol_id, ...rest }) => rest)(card({ id: 'v1', tag: 'cartao', exibir: 'false', titulo: '🟥 Expulso: Bia' }))))); // eslint-disable-line no-unused-vars
  await check('usuário comum não grava card ao vivo', assertFails(setDoc(doc(other, 'noticias/aovivo_m1'), live())));
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
