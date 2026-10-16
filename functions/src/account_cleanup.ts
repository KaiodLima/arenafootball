/**
 * Exclusão de conta: o que a function `onUserDeleted` varre. Funções puras
 * (sem Firebase), testadas em `test/account_cleanup.test.ts`.
 */
import { LEGACY_SEASON, seasonCollection } from './messages';

type Doc = Record<string, unknown>;

/**
 * Temporadas com dados do usuário: a lista do seletor, a atual e a legada
 * (2023, coleções sem sufixo), sem repetir.
 */
export function seasonsToSweep(config: Doc | undefined): string[] {
  const list = Array.isArray(config?.lista) ? config.lista : [];
  const values = [...list, config?.atual, LEGACY_SEASON]
    .map((value) => (value == null ? '' : String(value).trim()))
    .filter((value) => value !== '');
  return [...new Set(values)];
}

/** Coleções de uma temporada que guardam vínculo com a conta. */
export function seasonCollections(season: string): { matches: string; players: string; teams: string[] } {
  return {
    matches: seasonCollection('partidas', season),
    players: seasonCollection('jogadores', season),
    // O doc do time e a linha dele na classificação levam o `idDono`.
    teams: [seasonCollection('times', season), seasonCollection('classificacao', season)],
  };
}

/** Votos antigos (sem temporada): `melhorjogador{timeC}{timeF}/{uid}`. */
export function isLegacyVoteCollection(name: string): boolean {
  return name.startsWith('melhorjogador');
}

/**
 * Caminho no Storage da foto da conta, a partir da URL de download do
 * Firebase. Só da pasta `usuarios/` e do bucket do projeto (a foto do Google
 * fica como está). Nulo quando não é um arquivo nosso.
 */
export function userPhotoPath(url: unknown, bucket: string): string | null {
  if (typeof url !== 'string' || url === '') return null;
  const match = url.match(/^https:\/\/firebasestorage\.googleapis\.com\/v0\/b\/([^/]+)\/o\/([^?]+)/);
  if (!match || match[1] !== bucket) return null;
  const path = decodeURIComponent(match[2]);
  return path.startsWith('usuarios/') ? path : null;
}
