// Roda todos os arquivos *.rules.mjs desta pasta contra o firestore.rules do
// projeto no emulador. Uso (da raiz):
//   cd test/rules && npm install && cd ../..
//   firebase emulators:exec --only firestore --project demo-arena "node test/rules/run.mjs"
import { readdirSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';

const here = dirname(fileURLToPath(import.meta.url));
const rules = readFileSync(join(here, '..', '..', 'firestore.rules'), 'utf8');
let failures = 0;
let total = 0;

for (const file of readdirSync(here).filter((f) => f.endsWith('.rules.mjs')).sort()) {
  const env = await initializeTestEnvironment({
    projectId: 'demo-arena',
    firestore: { rules, host: '127.0.0.1', port: 8080 },
  });
  const check = async (name, promise) => {
    total++;
    try {
      await promise;
      console.log('ok   ', `${file}: ${name}`);
    } catch (e) {
      failures++;
      console.log('FAIL ', `${file}: ${name}`, e.message);
    }
  };
  const { default: run } = await import(pathToFileURL(join(here, file)).href);
  await run(env, check);
  await env.clearFirestore();
  await env.cleanup();
}

console.log(failures ? `${failures} de ${total} FALHARAM` : `TUDO OK (${total})`);
process.exit(failures ? 1 : 0);
