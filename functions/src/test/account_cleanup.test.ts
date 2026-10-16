import assert from 'node:assert/strict';
import { test } from 'node:test';
import { isLegacyVoteCollection, seasonCollections, seasonsToSweep, userPhotoPath } from '../account_cleanup';

test('temporadas: lista, atual e a legada, sem repetir', () => {
  assert.deepEqual(seasonsToSweep({ atual: '2026', lista: ['2026', '2025', 2024] }), ['2026', '2025', '2024', '2023']);
  assert.deepEqual(seasonsToSweep({ atual: '2023', lista: ['2023'] }), ['2023']);
});

test('sem config: só a temporada legada', () => {
  assert.deepEqual(seasonsToSweep(undefined), ['2023']);
  assert.deepEqual(seasonsToSweep({ lista: 'quebrado', atual: ' ' }), ['2023']);
});

test('coleções da temporada: 2023 sem sufixo', () => {
  assert.deepEqual(seasonCollections('2023'), {
    matches: 'partidas',
    players: 'jogadores',
    teams: ['times', 'classificacao'],
  });
  assert.deepEqual(seasonCollections('2025'), {
    matches: 'partidas2025',
    players: 'jogadores2025',
    teams: ['times2025', 'classificacao2025'],
  });
});

test('votos antigos: só melhorjogador*', () => {
  assert.equal(isLegacyVoteCollection('melhorjogadorAmigosRacing'), true);
  assert.equal(isLegacyVoteCollection('partidas2025'), false);
  assert.equal(isLegacyVoteCollection('usuarios'), false);
});

test('foto da conta: só usuarios/ do bucket do projeto', () => {
  const bucket = 'arenasoccerflutter.appspot.com';
  const url = `https://firebasestorage.googleapis.com/v0/b/${bucket}/o/usuarios%2Fabc.jpg?alt=media&token=t`;
  assert.equal(userPhotoPath(url, bucket), 'usuarios/abc.jpg');
  assert.equal(userPhotoPath(url.replace('usuarios', 'jogadores'), bucket), null);
  assert.equal(userPhotoPath(url, 'outro-bucket'), null);
  assert.equal(userPhotoPath('https://lh3.googleusercontent.com/a/foto', bucket), null);
  assert.equal(userPhotoPath(undefined, bucket), null);
});
