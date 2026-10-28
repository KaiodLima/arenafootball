/**
 * Páginas públicas dos links compartilhados (arenasoccerflutter.web.app):
 * `/noticia/<id>`, `/atleta/<temporada>/<idJogador>`, `/destaque/<id>` e
 * `/app`. Têm as meta tags Open Graph (prévia do link no WhatsApp/redes), um
 * resumo do conteúdo, o botão que abre o app (sem o app, a loja do aparelho)
 * e os links das duas lojas.
 * Funções puras: o handler HTTP fica no index.ts.
 */

export const SITE_URL = 'https://arenasoccerflutter.web.app';
export const APP_PACKAGE = 'com.caiolima.arenafootball';
export const PLAY_STORE_URL = `https://play.google.com/store/apps/details?id=${APP_PACKAGE}`;
export const APP_STORE_URL = 'https://apps.apple.com/us/app/arena-football/id6823678208';
/** Esquema do app (o mesmo do intent-filter no AndroidManifest e do Info.plist do iOS). */
export const APP_SCHEME = 'arenafootball';

export type SharePath =
  | { kind: 'noticia'; id: string }
  | { kind: 'atleta'; season: string; id: string }
  | { kind: 'destaque'; id: string }
  | { kind: 'app' };

const SAFE_ID = /^[A-Za-z0-9_-]{1,128}$/;

/** Caminho do link → o que mostrar (nulo = link inválido). */
export function parseSharePath(path: string): SharePath | null {
  const parts = path.split('?')[0].split('/').filter(Boolean).map((p) => decodeURIComponent(p));
  const [kind, a, b] = parts;
  if (kind === 'app' && parts.length === 1) return { kind: 'app' };
  if (kind === 'noticia' && parts.length === 2 && SAFE_ID.test(a)) return { kind: 'noticia', id: a };
  if (kind === 'destaque' && parts.length === 2 && SAFE_ID.test(a)) return { kind: 'destaque', id: a };
  if (kind === 'atleta' && parts.length === 3 && /^\d{4}$/.test(a) && SAFE_ID.test(b)) {
    return { kind: 'atleta', season: a, id: b };
  }
  return null;
}

/** Caminho dentro do app (`arenafootball://<caminho>`), igual ao do link. */
export function appPath(share: SharePath): string {
  switch (share.kind) {
    case 'noticia':
      return `noticia/${share.id}`;
    case 'destaque':
      return `destaque/${share.id}`;
    case 'atleta':
      return `atleta/${share.season}/${share.id}`;
    case 'app':
      return 'app';
  }
}

/**
 * Link do botão "Abrir no app": intent do Android que abre o app no
 * conteúdo; sem o app instalado, o navegador vai para a Play Store.
 */
export function openAppHref(share: SharePath): string {
  return (
    `intent://${appPath(share)}#Intent;scheme=${APP_SCHEME};package=${APP_PACKAGE};` +
    `S.browser_fallback_url=${encodeURIComponent(PLAY_STORE_URL)};end`
  );
}

/** Link do esquema do app (`arenafootball://<caminho>`): o botão no iPhone. */
export function schemeHref(share: SharePath): string {
  return `${APP_SCHEME}://${appPath(share)}`;
}

/**
 * Script do botão "Abrir no app" no iPhone/iPad (o `intent://` é só do
 * Android): tenta o esquema do app e, se a página continuar visível depois de
 * 1,5 s (app não instalado), vai para a App Store.
 */
function iosOpenScript(scheme: string): string {
  return `<script>
(function(){
  var ios=/iPad|iPhone|iPod/.test(navigator.userAgent)||(navigator.platform==='MacIntel'&&navigator.maxTouchPoints>1);
  if(!ios)return;
  var open=document.getElementById('open');
  open.addEventListener('click',function(e){
    e.preventDefault();
    var start=Date.now();
    window.location.href=${JSON.stringify(scheme)};
    setTimeout(function(){
      if(!document.hidden&&Date.now()-start<3000)window.location.href=${JSON.stringify(APP_STORE_URL)};
    },1500);
  });
})();
</script>`;
}

export interface PageData {
  title: string;
  description: string;
  image: string;
  /** Texto pequeno acima do título (ex.: "Notícia · Floresta"). */
  kicker: string;
}

type Doc = Record<string, unknown>;
const text = (value: unknown): string => (value === undefined || value === null ? '' : String(value).trim());

function shorten(value: string, max: number): string {
  const clean = value.replace(/\s+/g, ' ').trim();
  return clean.length <= max ? clean : `${clean.slice(0, max - 1).trimEnd()}…`;
}

export function newsPageData(news: Doc): PageData {
  const region = text(news.fk_competicao);
  return {
    title: text(news.titulo) || 'Notícia do Arena Football',
    description: shorten(text(news.descricao), 200) || 'Leia no app Arena Football.',
    image: text(news.urlImagem),
    kicker: ['Notícia', region].filter(Boolean).join(' · '),
  };
}

export function athletePageData(player: Doc, season: string): PageData {
  const goals = Number(player.nGols) || 0;
  const assists = Number(player.nAssistencias) || 0;
  const team = text(player.time);
  return {
    title: text(player.nome) || 'Atleta',
    description: `${goals} ${goals === 1 ? 'gol' : 'gols'} e ${assists} ${assists === 1 ? 'assistência' : 'assistências'} na temporada ${season}${team ? ` · ${team}` : ''}.`,
    image: text(player.urlImagem),
    kicker: ['Atleta', team].filter(Boolean).join(' · '),
  };
}

export function highlightPageData(highlight: Doc): PageData {
  return {
    title: text(highlight.title) || 'Destaque',
    description: 'Veja as notícias deste destaque no app Arena Football.',
    image: text(highlight.urlImagem),
    kicker: 'Destaque',
  };
}

export const APP_PAGE: PageData = {
  title: 'Arena Football',
  description: 'Futebol amador da sua região: notícias, tabelas, artilharia e votação do melhor da partida.',
  image: '',
  kicker: 'Baixe o app',
};

export const NOT_FOUND_PAGE: PageData = {
  title: 'Conteúdo não encontrado',
  description: 'Esse link não existe mais. Abra o app para ver as novidades.',
  image: '',
  kicker: 'Arena Football',
};

const escapeHtml = (value: string): string =>
  value.replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]!);

/** Página HTML completa (com Open Graph) para [share]. */
export function renderSharePage(data: PageData, share: SharePath, path: string): string {
  const title = escapeHtml(data.title);
  const description = escapeHtml(data.description);
  const kicker = escapeHtml(data.kicker);
  const url = escapeHtml(`${SITE_URL}${path}`);
  const image = escapeHtml(data.image || `${SITE_URL}/logo.png`);
  const open = escapeHtml(openAppHref(share));
  const playStore = escapeHtml(PLAY_STORE_URL);
  const appStore = escapeHtml(APP_STORE_URL);
  const photo = data.image ? `<img class="photo" src="${image}" alt="">` : '';
  return `<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${title} · Arena Football</title>
<meta name="description" content="${description}">
<meta property="og:type" content="article">
<meta property="og:site_name" content="Arena Football">
<meta property="og:title" content="${title}">
<meta property="og:description" content="${description}">
<meta property="og:image" content="${image}">
<meta property="og:url" content="${url}">
<meta name="twitter:card" content="summary_large_image">
<style>
  body{margin:0;font-family:system-ui,-apple-system,Roboto,sans-serif;background:#F3F6F3;color:#14231A}
  header{background:#1B431C;padding:18px 20px;display:flex;align-items:center;gap:10px}
  header img{height:28px}
  main{max-width:560px;margin:0 auto;padding:16px}
  .card{background:#fff;border-radius:18px;overflow:hidden;box-shadow:0 6px 18px rgba(0,0,0,.08)}
  .photo{width:100%;height:auto;max-height:80vh;object-fit:contain;display:block;background:#111}
  .body{padding:18px}
  .kicker{font-size:13px;font-weight:700;color:#2D5E2D;text-transform:uppercase;letter-spacing:.06em}
  h1{font-size:22px;line-height:1.25;margin:8px 0 10px}
  p{font-size:16px;line-height:1.5;color:#46564B;margin:0}
  .open{display:block;margin:20px 0 10px;padding:15px;border-radius:14px;background:#4CAF50;color:#fff;
    text-align:center;font-weight:700;font-size:17px;text-decoration:none}
  .stores{text-align:center;color:#46564B;font-size:14px}
  .store{display:inline-block;margin:6px 4px;padding:9px 14px;border-radius:10px;border:1px solid #B7CBB8;
    color:#1B431C;font-weight:600;text-decoration:none;background:#fff}
</style>
</head>
<body>
<header><img src="/logo.png" alt="Arena Football"></header>
<main>
  <div class="card">
    ${photo}
    <div class="body">
      <div class="kicker">${kicker}</div>
      <h1>${title}</h1>
      <p>${description}</p>
    </div>
  </div>
  <a class="open" id="open" href="${open}">Abrir no app Arena Football</a>
  <div class="stores">
    Ainda não tem o app?<br>
    <a class="store" href="${playStore}">Baixar na Play Store</a>
    <a class="store" href="${appStore}">Baixar na App Store</a>
  </div>
</main>
${iosOpenScript(schemeHref(share))}
</body>
</html>`;
}
