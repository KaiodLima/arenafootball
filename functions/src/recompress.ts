/**
 * Recompressão das imagens antigas do Storage (manutenção do admin): o mesmo
 * perfil do upload do app (`ImageUploadProfile`), regravando no mesmo caminho
 * e com o mesmo tipo (o token de download continua, as URLs não mudam).
 */

export type Doc = Record<string, unknown>;

/** Pastas percorridas, em ordem (as do `StorageFolder` do app). */
export const RECOMPRESS_FOLDERS = ['noticias', 'destaques', 'times', 'jogadores', 'campeonatos', 'usuarios'] as const;

/** Arquivos por lote (cada lote é uma execução da function). */
export const BATCH_SIZE = 40;

/** Abaixo disso não vale a pena (já é pequeno). */
export const MIN_BYTES = 100 * 1024;

/** Só regrava se ficar pelo menos 10% menor. */
export const MIN_SAVING = 0.1;

/** Marca no `metadata` do arquivo já processado. */
export const DONE_FLAG = 'recomprimida';

export interface Profile {
  /** Lado maior, em px (nunca amplia). */
  size: number;
  quality: number;
  png: boolean;
}

/** Perfil da pasta (o mesmo do app). */
export function profileFor(folder: string): Profile {
  switch (folder) {
    case 'usuarios':
    case 'jogadores':
      return { size: 600, quality: 80, png: false };
    case 'times':
      return { size: 512, quality: 80, png: true };
    default:
      return { size: 1280, quality: 80, png: false };
  }
}

export interface FileInfo {
  name: string;
  contentType: string;
  size: number;
  metadata: Doc;
}

/** Vale processar? Só imagem JPEG/PNG/WebP, acima do mínimo e não marcada. */
export function shouldRecompress(file: FileInfo): boolean {
  if (!/^image\/(jpeg|jpg|png|webp)$/i.test(file.contentType)) return false;
  if (file.size < MIN_BYTES) return false;
  return String(file.metadata?.[DONE_FLAG] ?? '') !== 'true';
}

/**
 * Formato da saída: o mesmo do arquivo (o `contentType` não muda). Escudo em
 * PNG continua PNG; JPEG continua JPEG; WebP continua WebP.
 */
export function outputFormat(contentType: string): 'jpeg' | 'png' | 'webp' {
  if (/png/i.test(contentType)) return 'png';
  if (/webp/i.test(contentType)) return 'webp';
  return 'jpeg';
}

/** A versão nova compensa (pelo menos [MIN_SAVING] menor)? */
export function worthReplacing(before: number, after: number): boolean {
  return after > 0 && after <= before * (1 - MIN_SAVING);
}

export interface RecompressProgress {
  status: 'pedido' | 'rodando' | 'concluido' | 'erro';
  pasta: string;
  pageToken: string;
  vistos: number;
  regravados: number;
  bytesAntes: number;
  bytesDepois: number;
}

/** Progresso gravado no doc (campos ausentes = zero/início). */
export function progressOf(data: Doc | undefined): RecompressProgress {
  const num = (v: unknown) => (typeof v === 'number' && Number.isFinite(v) ? v : 0);
  const status = String(data?.status ?? '');
  return {
    status: (['pedido', 'rodando', 'concluido', 'erro'].includes(status) ? status : 'pedido') as RecompressProgress['status'],
    pasta: String(data?.pasta ?? ''),
    pageToken: String(data?.pageToken ?? ''),
    vistos: num(data?.vistos),
    regravados: num(data?.regravados),
    bytesAntes: num(data?.bytesAntes),
    bytesDepois: num(data?.bytesDepois),
  };
}

/** Próxima pasta depois de [folder] (vazio = acabou). Pasta vazia/desconhecida = a primeira. */
export function nextFolder(folder: string): string {
  if (!folder) return RECOMPRESS_FOLDERS[0];
  const index = RECOMPRESS_FOLDERS.indexOf(folder as (typeof RECOMPRESS_FOLDERS)[number]);
  if (index < 0) return RECOMPRESS_FOLDERS[0];
  return RECOMPRESS_FOLDERS[index + 1] ?? '';
}

/**
 * Deve rodar um lote? Pedido novo ("pedido") ou continuação ("rodando" com o
 * `lote` mudando: cada lote grava um número novo, e só a escrita com número
 * novo dispara o próximo — evita rodar duas vezes o mesmo lote).
 */
export function shouldRunBatch(before: Doc | undefined, after: Doc | undefined): boolean {
  const status = String(after?.status ?? '');
  if (status === 'pedido') {
    return String(before?.status ?? '') !== 'pedido' || String(before?.pedidoEm) !== String(after?.pedidoEm);
  }
  if (status === 'rodando') return Number(after?.lote ?? 0) !== Number(before?.lote ?? 0);
  return false;
}
