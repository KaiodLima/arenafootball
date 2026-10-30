import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  MIN_BYTES,
  nextFolder,
  outputFormat,
  profileFor,
  progressOf,
  shouldRecompress,
  shouldRunBatch,
  worthReplacing,
} from '../recompress';

test('perfil por pasta igual ao do app', () => {
  assert.deepEqual(profileFor('jogadores'), { size: 600, quality: 80, png: false });
  assert.deepEqual(profileFor('usuarios').size, 600);
  assert.deepEqual(profileFor('times'), { size: 512, quality: 80, png: true });
  assert.deepEqual(profileFor('noticias').size, 1280);
});

test('pula PDF, pequeno e já marcado', () => {
  const base = { name: 'noticias/a.jpg', contentType: 'image/jpeg', size: MIN_BYTES * 3, metadata: {} };
  assert.equal(shouldRecompress(base), true);
  assert.equal(shouldRecompress({ ...base, contentType: 'application/pdf' }), false);
  assert.equal(shouldRecompress({ ...base, size: MIN_BYTES - 1 }), false);
  assert.equal(shouldRecompress({ ...base, metadata: { recomprimida: 'true' } }), false);
});

test('formato mantido e só regrava se ganhar 10%', () => {
  assert.equal(outputFormat('image/png'), 'png');
  assert.equal(outputFormat('image/webp'), 'webp');
  assert.equal(outputFormat('image/jpeg'), 'jpeg');
  assert.equal(worthReplacing(1000, 900), true);
  assert.equal(worthReplacing(1000, 901), false);
  assert.equal(worthReplacing(1000, 0), false);
});

test('pastas em ordem e fim; progresso padrão', () => {
  assert.equal(nextFolder(''), 'noticias');
  assert.equal(nextFolder('noticias'), 'destaques');
  assert.equal(nextFolder('usuarios'), 'album');
  assert.equal(nextFolder('album'), '');
  assert.equal(progressOf(undefined).vistos, 0);
  assert.equal(progressOf({ status: 'rodando', vistos: 5 }).vistos, 5);
});

test('só roda lote no pedido novo ou com lote novo', () => {
  assert.equal(shouldRunBatch(undefined, { status: 'pedido' }), true);
  assert.equal(shouldRunBatch({ status: 'concluido' }, { status: 'pedido' }), true);
  assert.equal(shouldRunBatch({ status: 'rodando', lote: 1 }, { status: 'rodando', lote: 2 }), true);
  assert.equal(shouldRunBatch({ status: 'rodando', lote: 2 }, { status: 'rodando', lote: 2 }), false);
  assert.equal(shouldRunBatch({ status: 'rodando', lote: 2 }, { status: 'concluido', lote: 3 }), false);
});
