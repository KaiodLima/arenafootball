import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  achievementFromDoc,
  achievementMessage,
  athleteCounters,
  changedFields,
  countersChanged,
  isFirstEvaluation,
  missingServerFields,
  newUnlocks,
  profileCounters,
} from '../achievements';

const catalog = [
  achievementFromDoc('v1', { titulo: 'Primeiro voto', metrica: 'votos', meta: 1, pontos: 10 }),
  achievementFromDoc('v10', { titulo: 'Jurado', metrica: 'votos', meta: 10, pontos: 40 }),
  achievementFromDoc('off', { titulo: 'Desligada', metrica: 'votos', meta: 1, ativa: false }),
  achievementFromDoc('x', { titulo: 'Métrica nova', metrica: 'desconhecida', meta: 1 }),
];

test('desbloqueia só o que atingiu, ativa e ainda não ganha', () => {
  assert.deepEqual(
    newUnlocks(catalog, { votos: 1, desbloqueadas: [] }).map((a) => a.id),
    ['v1'],
  );
  assert.deepEqual(
    newUnlocks(catalog, { votos: 12, desbloqueadas: ['v1'] }).map((a) => a.id),
    ['v10'],
  );
  assert.deepEqual(newUnlocks(catalog, { votos: 12, desbloqueadas: ['v1', 'v10'] }), []);
});

test('primeira avaliação (sem a lista) e mudança de contadores', () => {
  assert.equal(isFirstEvaluation({ votos: 3 }), true);
  assert.equal(isFirstEvaluation({ votos: 3, desbloqueadas: [] }), false);
  assert.equal(countersChanged({ votos: 1 }, { votos: 2 }), true);
  // Só a lista de desbloqueadas mudou: não reavalia (evita laço).
  assert.equal(countersChanged({ votos: 2 }, { votos: 2, desbloqueadas: ['v1'] }), false);
  assert.equal(countersChanged(undefined, { votos: 1 }), true);
});

test('contadores do perfil, do atleta e o que falta preencher', () => {
  assert.deepEqual(profileCounters({ idTime: 't1', urlImagem: '' }), { timeCoracao: 1, fotoCarteirinha: 0 });
  assert.deepEqual(profileCounters({ time: 'Volta', urlImagem: 'https://x' }), { timeCoracao: 1, fotoCarteirinha: 1 });
  assert.deepEqual(athleteCounters({ nGols: 7, nAssistencias: 2 }), { atleta: 1, golsAtleta: 7, assistenciasAtleta: 2 });
  assert.deepEqual(athleteCounters(undefined), { atleta: 0, golsAtleta: 0, assistenciasAtleta: 0 });
  assert.deepEqual(missingServerFields({ votos: 1 }), { profile: true, athlete: true, owner: true });
  assert.deepEqual(missingServerFields({ timeCoracao: 1, fotoCarteirinha: 0, atleta: 0, donoTime: 0 }), {
    profile: false,
    athlete: false,
    owner: false,
  });
  assert.deepEqual(changedFields({ timeCoracao: 1, fotoCarteirinha: 0 }, { timeCoracao: 1, fotoCarteirinha: 1 }), {
    fotoCarteirinha: 1,
  });
});

test('push da conquista para a própria conta', () => {
  const message = achievementMessage('u1', catalog[1]);
  assert.equal(message.tipo, 'conquista');
  assert.equal(message.corpo, 'Jurado · +40 XP');
  assert.equal(message.aba, 'conquistas');
  assert.deepEqual(message.alvo, { topic: 'usuario_u1' });
});
