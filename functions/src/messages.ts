/**
 * Mensagens e alvos das notificações (funções puras, testáveis sem Firebase).
 *
 * Tópicos assinados pelo app: `todos`, `regiao_<slug>` e `time_<slug>`. O
 * slug é o mesmo do app (lib/core/utils/push_topics.dart): minúsculas, sem
 * acento, e o que não for [a-z0-9] vira "_".
 */

/** Ações que podem emitir push (chaves de `config/notificacoes`). */
export type ActionKey =
  | 'gol'
  | 'noticia'
  | 'partida'
  | 'votacao_aberta'
  | 'votacao_encerrada'
  | 'jogo_do_dia'
  | 'aviso'
  | 'solicitacao_jogador'
  | 'solicitacao_resposta';

/** Sem configuração gravada, vale este padrão (notícia vem desligada). */
export const DEFAULT_ENABLED: Record<ActionKey, boolean> = {
  gol: true,
  noticia: false,
  partida: true,
  votacao_aberta: true,
  votacao_encerrada: true,
  jogo_do_dia: true,
  aviso: true,
  solicitacao_jogador: true,
  solicitacao_resposta: true,
};

export type Target = { topic: string } | { condition: string };

export interface PushMessage {
  tipo: ActionKey;
  titulo: string;
  corpo: string;
  /**
   * O que abre ao tocar: feed, tabelas, painel de pedidos de jogador (admin)
   * ou a situação do pedido do usuário.
   */
  aba: 'home' | 'tabelas' | 'solicitacoes' | 'sou_jogador';
  regiao: string;
  alvo: Target;
}

type Doc = Record<string, unknown>;

const text = (value: unknown): string => (value === undefined || value === null ? '' : String(value).trim());

export function topicSlug(value: string): string {
  return value
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');
}

export const ALL_TOPIC = 'todos';
export const regionTopic = (region: string): string => `regiao_${topicSlug(region)}`;
export const teamTopic = (team: string): string => `time_${topicSlug(team)}`;
/** Administradores (o app assina quando a conta é admin). */
export const ADMINS_TOPIC = 'admins';
/** Um usuário só. O uid já é alfanumérico: vai sem slug, igual ao app. */
export const userTopic = (uid: string): string => `usuario_${uid}`;

/** Um tópico vira `topic`; vários, uma condition com OR (cada aparelho recebe uma vez). */
export function targetFor(topics: string[]): Target | null {
  const unique = [...new Set(topics.filter((t) => !/_$/.test(t) && t.length > 0))];
  if (unique.length === 0) return null;
  if (unique.length === 1) return { topic: unique[0] };
  return { condition: unique.slice(0, 5).map((t) => `'${t}' in topics`).join(' || ') };
}

/** Região do jogo + torcedores dos dois times. */
function gameTarget(region: string, home: string, away: string): Target | null {
  return targetFor([
    ...(region ? [regionTopic(region)] : []),
    ...(home ? [teamTopic(home)] : []),
    ...(away ? [teamTopic(away)] : []),
  ]);
}

export function describeTarget(target: Target): string {
  return 'topic' in target ? target.topic : target.condition;
}

export function isEnabled(config: Doc | undefined, action: ActionKey): boolean {
  const value = config?.[action];
  return typeof value === 'boolean' ? value : DEFAULT_ENABLED[action];
}

function shorten(value: string, max: number): string {
  return value.length <= max ? value : `${value.slice(0, max - 1).trimEnd()}…`;
}

/** Card de gol (noticias com tag "gol"). */
export function goalMessage(news: Doc): PushMessage | null {
  const home = text(news.time_casa);
  const away = text(news.time_fora);
  const region = text(news.fk_competicao);
  const alvo = gameTarget(region, home, away);
  if (!home || !away || !alvo) return null;
  const scorer = text(news.autor_gol);
  const assist = text(news.assistencia);
  const team = text(news.time_marcador);
  const corpo = scorer
    ? `${scorer}${assist ? ` (assist. ${assist})` : ''}${team ? ` · ${team}` : ''}`
    : team
      ? `Gol do ${team}`
      : 'Confira no Arena Football';
  return {
    tipo: 'gol',
    titulo: `⚽ GOL! ${home} ${text(news.gol_time_casa) || '0'} × ${text(news.gol_time_fora) || '0'} ${away}`,
    corpo,
    aba: 'home',
    regiao: region,
    alvo,
  };
}

/** Notícia comum publicada visível (sem gol, publicidade). */
export function newsMessage(news: Doc): PushMessage | null {
  const tag = text(news.tag);
  if (tag === 'gol' || tag === 'publicidade' || text(news.exibir) !== 'true') return null;
  const titulo = text(news.titulo);
  const region = text(news.fk_competicao);
  if (!titulo || !region) return null;
  return {
    tipo: 'noticia',
    titulo: shorten(titulo, 80),
    corpo: shorten(text(news.descricao).replace(/\s+/g, ' ') || 'Leia no Arena Football', 140),
    aba: 'home',
    regiao: region,
    alvo: { topic: regionTopic(region) },
  };
}

function matchTeams(match: Doc) {
  return { home: text(match.timeC), away: text(match.timeF), region: text(match.fk_competicao) };
}

/** Partida cadastrada. */
export function matchCreatedMessage(match: Doc): PushMessage | null {
  const { home, away, region } = matchTeams(match);
  const alvo = gameTarget(region, home, away);
  if (!home || !away || !alvo) return null;
  const when = [text(match.data), text(match.horario) && `às ${text(match.horario)}`].filter(Boolean).join(' ');
  const place = text(match.local);
  return {
    tipo: 'partida',
    titulo: `Nova partida: ${home} × ${away}`,
    corpo: [when, place].filter(Boolean).join(' · ') || 'Confira na tabela',
    aba: 'tabelas',
    regiao: region,
    alvo,
  };
}

/** Votação de melhor jogador aberta ou encerrada (`votacao` é string). */
export function votingMessage(before: Doc, after: Doc): PushMessage | null {
  const was = text(before.votacao) === 'true';
  const is = text(after.votacao) === 'true';
  if (was === is) return null;
  const { home, away, region } = matchTeams(after);
  const alvo = gameTarget(region, home, away);
  if (!home || !away || !alvo) return null;
  return is
    ? {
        tipo: 'votacao_aberta',
        titulo: '🗳️ Votação aberta',
        corpo: `Vote no melhor da partida ${home} × ${away}`,
        aba: 'tabelas',
        regiao: region,
        alvo,
      }
    : {
        tipo: 'votacao_encerrada',
        titulo: '🏆 Votação encerrada',
        corpo: `Veja quem foi eleito o melhor de ${home} × ${away}`,
        aba: 'tabelas',
        regiao: region,
        alvo,
      };
}

/** Lembrete do dia: só para os torcedores dos dois times. */
export function dailyGameMessage(match: Doc): PushMessage | null {
  const { home, away, region } = matchTeams(match);
  const alvo = targetFor([...(home ? [teamTopic(home)] : []), ...(away ? [teamTopic(away)] : [])]);
  if (!home || !away || !alvo) return null;
  const time = text(match.horario);
  return {
    tipo: 'jogo_do_dia',
    titulo: 'Hoje tem jogo do seu time!',
    corpo: `${home} × ${away}${time ? ` às ${time}` : ''}`,
    aba: 'tabelas',
    regiao: region,
    alvo,
  };
}

/** Aviso manual do admin (`regiao` vazia = todos). */
export function manualMessage(notice: Doc): PushMessage | null {
  const titulo = text(notice.titulo);
  const corpo = text(notice.corpo);
  if (!titulo || !corpo) return null;
  const region = text(notice.regiao);
  return {
    tipo: 'aviso',
    titulo: shorten(titulo, 80),
    corpo: shorten(corpo, 240),
    aba: 'home',
    regiao: region,
    alvo: { topic: region ? regionTopic(region) : ALL_TOPIC },
  };
}

/**
 * Pedido "Sou jogador" chegou para análise: criado, ou reenviado depois de
 * rejeitado. Correções num pedido já pendente não avisam de novo.
 */
export function playerRequestMessage(uid: string, before: Doc | undefined, after: Doc | undefined): PushMessage | null {
  if (!after || text(after.status) !== 'pendente' || text(before?.status) === 'pendente') return null;
  const name = text(after.nome);
  const team = text(after.time);
  if (!name || !team || !uid) return null;
  return {
    tipo: 'solicitacao_jogador',
    titulo: 'Nova solicitação de jogador',
    corpo: shorten(`${name} quer jogar no ${team}`, 240),
    aba: 'solicitacoes',
    regiao: text(after.regiao),
    alvo: { topic: ADMINS_TOPIC },
  };
}

/** Admin respondeu o pedido, ou tirou o atleta do elenco: avisa só quem pediu. */
export function playerRequestAnswerMessage(uid: string, before: Doc | undefined, after: Doc | undefined): PushMessage | null {
  if (!before || !after || !uid) return null;
  const status = text(after.status);
  if (text(before.status) === 'aprovada' && status === 'removido') {
    return {
      tipo: 'solicitacao_resposta',
      titulo: 'Você saiu do elenco',
      corpo: `Você não faz mais parte do ${text(after.time)}. Suas estatísticas continuam salvas.`,
      aba: 'sou_jogador',
      regiao: text(after.regiao),
      alvo: { topic: userTopic(uid) },
    };
  }
  if (text(before.status) !== 'pendente') return null;
  if (status !== 'aprovada' && status !== 'rejeitada') return null;
  const team = text(after.time);
  const reason = text(after.motivo);
  const approved = status === 'aprovada';
  return {
    tipo: 'solicitacao_resposta',
    titulo: approved ? '✅ Você está no elenco!' : 'Solicitação de jogador',
    corpo: shorten(
      approved
        ? `Sua solicitação para jogar no ${team} foi aprovada.`
        : `Sua solicitação para jogar no ${team} não foi aprovada.${reason ? ` Motivo: ${reason}` : ''}`,
      240,
    ),
    aba: 'sou_jogador',
    regiao: text(after.regiao),
    alvo: { topic: userTopic(uid) },
  };
}

/** "dd/MM" de hoje no fuso de Brasília (formato do campo `data` das partidas). */
export function todayKey(now: Date = new Date()): string {
  const parts = new Intl.DateTimeFormat('pt-BR', {
    timeZone: 'America/Sao_Paulo',
    day: '2-digit',
    month: '2-digit',
  }).formatToParts(now);
  const get = (type: string) => parts.find((p) => p.type === type)?.value ?? '';
  return `${get('day')}/${get('month')}`;
}
