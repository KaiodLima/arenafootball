// Atletas: o dono do time aprova o "Sou jogador" de quem já é atleta de outro
// time. Um time por competição na temporada: o dono só mexe na inscrição da
// competição do pedido, e só se ela não é de outro time.
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, setDoc, updateDoc } from 'firebase/firestore';

export default async function run(env, check) {
  const seed = (path, data) => env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), path), data));
  // Dono da Mulekada (tB); Paulo (u1) joga pelo Açaí (tA) na Copa Verde (c3).
  await seed('usuarios/dono', { idUsuario: 'dono', admin: false });
  await seed('solicitacoes_time/dono', { status: 'aprovada', idTime: 'tB', nome: 'Mulekada' });
  await seed('solicitacoes_jogador/u1', { uid: 'u1', idTime: 'tB', time: 'Mulekada', idCampeonato: 5, status: 'pendente' });
  const paulo = {
    idUsuario: 'u1',
    nome: 'Paulo',
    time: 'Açaí',
    idTime: 'tA',
    inscricoes: { c3: { idTime: 'tA', time: 'Açaí', nGols: 2, nAssistencias: 0 } },
    idsTimes: ['tA'],
  };
  await seed('jogadores2026/p1', paulo);
  // Zé (u2) já está no Municipal (c5) pelo Açaí e pediu a Mulekada no Municipal.
  await seed('solicitacoes_jogador/u2', { uid: 'u2', idTime: 'tB', time: 'Mulekada', idCampeonato: 5, status: 'pendente' });
  await seed('jogadores2026/p2', {
    ...paulo,
    idUsuario: 'u2',
    nome: 'Zé',
    inscricoes: { c5: { idTime: 'tA', time: 'Açaí', nGols: 1, nAssistencias: 0 } },
  });

  const dono = env.authenticatedContext('dono').firestore();
  const mulekada = { idTime: 'tB', time: 'Mulekada', nGols: 0, nAssistencias: 0 };

  await check(
    'dono põe o atleta na competição do pedido',
    assertSucceeds(updateDoc(doc(dono, 'jogadores2026/p1'), { 'inscricoes.c5': mulekada, idsTimes: ['tA', 'tB'] })),
  );
  await check(
    'dono não mexe em outra competição do atleta',
    assertFails(updateDoc(doc(dono, 'jogadores2026/p1'), { 'inscricoes.c3.idTime': 'tB', 'inscricoes.c3.time': 'Mulekada' })),
  );
  await check(
    'dono edita os números da inscrição do próprio time',
    assertSucceeds(updateDoc(doc(dono, 'jogadores2026/p1'), { 'inscricoes.c5.nGols': 1, nGols: 3 })),
  );
  await check(
    'dono não tira o atleta da competição de outro time',
    assertFails(updateDoc(doc(dono, 'jogadores2026/p1'), { 'inscricoes.c3.nGols': 0 })),
  );
  await check(
    'dono não troca o time de inscrição de outro time',
    assertFails(updateDoc(doc(dono, 'jogadores2026/p2'), { 'inscricoes.c5': mulekada, idsTimes: ['tA', 'tB'] })),
  );

  // O atleta vinculado (idUsuario) troca só a própria foto.
  await seed('jogadores2026/p3', { nome: 'Sem conta', time: 'Açaí', idTime: 'tA', urlImagem: '' });
  const u1 = env.authenticatedContext('u1').firestore();
  const foto = 'https://example.com/nova.jpg';
  await check('atleta troca a própria foto', assertSucceeds(updateDoc(doc(u1, 'jogadores2026/p1'), { urlImagem: foto })));
  await check('atleta não troca a foto de outro atleta', assertFails(updateDoc(doc(u1, 'jogadores2026/p2'), { urlImagem: foto })));
  await check('atleta não troca a foto de atleta sem conta', assertFails(updateDoc(doc(u1, 'jogadores2026/p3'), { urlImagem: foto })));
  await check(
    'atleta não muda outro campo junto com a foto',
    assertFails(updateDoc(doc(u1, 'jogadores2026/p1'), { urlImagem: 'https://example.com/2.jpg', nome: 'Paulão' })),
  );
  await check('atleta não muda os próprios gols', assertFails(updateDoc(doc(u1, 'jogadores2026/p1'), { nGols: 99 })));
  await check(
    'atleta não mexe nas próprias inscrições',
    assertFails(updateDoc(doc(u1, 'jogadores2026/p1'), { 'inscricoes.c3.nGols': 50 })),
  );
  await check('atleta não se desvincula', assertFails(updateDoc(doc(u1, 'jogadores2026/p1'), { idUsuario: 'outro' })));
  await check(
    'foto precisa ser texto',
    assertFails(updateDoc(doc(u1, 'jogadores2026/p1'), { urlImagem: 123 })),
  );
}
