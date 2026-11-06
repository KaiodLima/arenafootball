import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, serverTimestamp, setDoc, updateDoc } from 'firebase/firestore';

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
}
