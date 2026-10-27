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
  | 'solicitacao_resposta'
  | 'solicitacao_time'
  | 'solicitacao_time_resposta'
  | 'solicitacao_parceiro'
  | 'solicitacao_parceiro_resposta'
  | 'conquista';

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
  solicitacao_time: true,
  solicitacao_time_resposta: true,
  solicitacao_parceiro: true,
  solicitacao_parceiro_resposta: true,
  conquista: true,
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
  aba:
    | 'home'
    | 'tabelas'
    | 'solicitacoes'
    | 'sou_jogador'
    | 'solicitacoes_time'
    | 'meu_time'
    | 'solicitacoes_parceiro'
    | 'parceiro'
    | 'conquistas';
  regiao: string;
  alvo: Target;
  /** Imagem do push (URL https): o escudo do time no card de gol. */
  imagem?: string;
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

/**
 * Temporadas (igual a lib/core/firebase/season_collection.dart): 2023 é a
 * única sem sufixo; as outras usam o ano (`partidas2024`). A atual fica em
 * `config/temporadas.atual`.
 */
export const LEGACY_SEASON = '2023';

export function seasonCollection(base: string, season: string): string {
  return !season || season === LEGACY_SEASON ? base : `${base}${season}`;
}

/** Temporada atual gravada na config (sem config: a legada). */
export function currentSeasonOf(config: Doc | undefined): string {
  const value = text(config?.atual);
  return value || LEGACY_SEASON;
}
export const regionTopic = (region: string): string => `regiao_${topicSlug(region)}`;
/** Tópico da região pelo id (o vínculo), igual ao `regionIdTopic` do app. */
export const regionIdTopic = (id: string): string => `regiaoid_${id.replace(/[^A-Za-z0-9_-]/g, '_')}`;
/**
 * Tópico da região de um doc: pelo `idRegiao` (app novo assina) e, em doc
 * antigo sem id, pelo nome. Um só tópico: a condition dos jogos já usa 4 dos 5.
 */
export function regionTopicOf(doc: Doc, nameKey = 'fk_competicao'): string {
  const id = text(doc.idRegiao);
  if (id) return regionIdTopic(id);
  const name = text(doc[nameKey]);
  return name ? regionTopic(name) : '';
}
/** Tópico antigo do time, pelo nome (app antigo / conta sem o id). */
export const teamTopic = (team: string): string => `time_${topicSlug(team)}`;
/**
 * Tópico do time pelo id (o vínculo), igual ao `teamIdTopic` do app
 * (lib/core/utils/push_topics.dart). Prefixo próprio: não colide com o do nome.
 */
export const teamIdTopic = (id: string): string => `timeid_${id.replace(/[^A-Za-z0-9_-]/g, '_')}`;

/**
 * Tópicos de um time durante a transição: o do id (app novo) e o do nome
 * (app antigo). Cada aparelho assina só um deles, então ninguém recebe duas vezes.
 */
export function teamTopics(name: string, id: string): string[] {
  return [...(id ? [teamIdTopic(id)] : []), ...(name ? [teamTopic(name)] : [])];
}
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

/** Região do jogo + torcedores dos dois times (id e nome: até 5 tópicos, o limite da condition). */
function gameTarget(regionTopicName: string, home: string, away: string, homeId = '', awayId = ''): Target | null {
  return targetFor([
    ...(regionTopicName ? [regionTopicName] : []),
    ...teamTopics(home, homeId),
    ...teamTopics(away, awayId),
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
  const alvo = gameTarget(regionTopicOf(news), home, away, text(news.id_time_casa), text(news.id_time_fora));
  if (!home || !away || !alvo) return null;
  const scorer = text(news.autor_gol);
  const assist = text(news.assistencia);
  const team = text(news.time_marcador);
  const corpo = scorer
    ? `${scorer}${assist ? ` (assist. ${assist})` : ''}${team ? ` · ${team}` : ''}`
    : team
      ? `Gol do ${team}`
      : 'Confira no Arena Football';
  const crest = text(news.escudo_marcador);
  return {
    tipo: 'gol',
    titulo: `⚽ GOL! ${home} ${text(news.gol_time_casa) || '0'} × ${text(news.gol_time_fora) || '0'} ${away}`,
    corpo,
    aba: 'home',
    regiao: region,
    alvo,
    ...(crest.startsWith('https://') ? { imagem: crest } : {}),
  };
}

/** Notícia comum publicada visível (sem gol, publicidade). */
export function newsMessage(news: Doc): PushMessage | null {
  const tag = text(news.tag);
  // Gol, resultado e votação têm card próprio (os automáticos não mandam push de notícia).
  if (
    tag === 'gol' ||
    tag === 'resultado' ||
    tag === 'votacao' ||
    tag === 'publicidade' ||
    text(news.exibir) !== 'true'
  ) {
    return null;
  }
  const titulo = text(news.titulo);
  const region = text(news.fk_competicao);
  if (!titulo || !region) return null;
  return {
    tipo: 'noticia',
    titulo: shorten(titulo, 80),
    corpo: shorten(text(news.descricao).replace(/\s+/g, ' ') || 'Leia no Arena Football', 140),
    aba: 'home',
    regiao: region,
    alvo: { topic: regionTopicOf(news) },
  };
}

function matchTeams(match: Doc) {
  return {
    home: text(match.timeC),
    away: text(match.timeF),
    homeId: text(match.idTimeC),
    awayId: text(match.idTimeF),
    region: text(match.fk_competicao),
    regionTopicName: regionTopicOf(match),
  };
}

/** Partida cadastrada. */
export function matchCreatedMessage(match: Doc): PushMessage | null {
  const { home, away, homeId, awayId, region, regionTopicName } = matchTeams(match);
  const alvo = gameTarget(regionTopicName, home, away, homeId, awayId);
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
  const { home, away, homeId, awayId, region, regionTopicName } = matchTeams(after);
  const alvo = gameTarget(regionTopicName, home, away, homeId, awayId);
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
        corpo: `Veja o resultado de ${home} × ${away}`,
        aba: 'tabelas',
        regiao: region,
        alvo,
      };
}

/** Lembrete do dia: só para os torcedores dos dois times. */
export function dailyGameMessage(match: Doc): PushMessage | null {
  const { home, away, homeId, awayId, region } = matchTeams(match);
  const alvo = targetFor([...teamTopics(home, homeId), ...teamTopics(away, awayId)]);
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
    alvo: { topic: region ? regionTopicOf(notice, 'regiao') : ALL_TOPIC },
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
  // Pedido de vínculo com atleta já cadastrado: `nome` é o do atleta.
  const account = text(after.nome_usuario);
  // Competição do pedido (opcional): "… no Lava Jato na Copa Floresta".
  const championship = text(after.campeonato);
  const where = championship ? `${team} na ${championship}` : team;
  const body = text(after.idJogadorVinculo)
    ? `${account || 'Um usuário'} diz ser o atleta ${name} do ${where}`
    : `${name} quer jogar no ${where}`;
  return {
    tipo: 'solicitacao_jogador',
    titulo: 'Nova solicitação de jogador',
    corpo: shorten(body, 240),
    aba: 'solicitacoes',
    regiao: text(after.regiao),
    alvo: { topic: ADMINS_TOPIC },
  };
}

/** Pedido "Sou jogador" chegou para o time de um dono: avisa o dono também. */
export function playerRequestToOwnerMessage(
  ownerUid: string,
  before: Doc | undefined,
  after: Doc | undefined,
): PushMessage | null {
  const forAdmins = playerRequestMessage('-', before, after);
  if (!forAdmins || !ownerUid) return null;
  return {
    ...forAdmins,
    titulo: 'Pedido para entrar no seu time',
    aba: 'meu_time',
    alvo: { topic: userTopic(ownerUid) },
  };
}

/** Pedido "Sou dono de time" novo ou reenviado: avisa os admins. */
export function teamRequestMessage(uid: string, before: Doc | undefined, after: Doc | undefined): PushMessage | null {
  if (!after || !uid || text(after.status) !== 'pendente' || text(before?.status) === 'pendente') return null;
  const owner = text(after.nome_usuario);
  const team = text(after.nome);
  if (!team) return null;
  return {
    tipo: 'solicitacao_time',
    titulo: 'Novo pedido de time',
    corpo: shorten(owner ? `${owner} quer cadastrar o time ${team}` : `Pedido para cadastrar o time ${team}`, 240),
    aba: 'solicitacoes_time',
    regiao: text(after.regiao),
    alvo: { topic: ADMINS_TOPIC },
  };
}

/** Admin respondeu o pedido de time: avisa só quem pediu. */
export function teamRequestAnswerMessage(uid: string, before: Doc | undefined, after: Doc | undefined): PushMessage | null {
  if (!before || !after || !uid || text(before.status) !== 'pendente') return null;
  const status = text(after.status);
  if (status !== 'aprovada' && status !== 'rejeitada') return null;
  const team = text(after.nome);
  const reason = text(after.motivo);
  const approved = status === 'aprovada';
  return {
    tipo: 'solicitacao_time_resposta',
    titulo: approved ? '✅ Seu time foi aprovado!' : 'Pedido de time',
    corpo: shorten(
      approved
        ? `O ${team} já está no app. Agora é só montar o elenco.`
        : `O pedido do time ${team} não foi aprovado.${reason ? ` Motivo: ${reason}` : ''}`,
      240,
    ),
    aba: 'meu_time',
    regiao: text(after.regiao),
    alvo: { topic: userTopic(uid) },
  };
}

/** Pedido "Sou parceiro" novo ou reenviado: avisa os admins. */
export function partnerRequestMessage(uid: string, before: Doc | undefined, after: Doc | undefined): PushMessage | null {
  if (!after || !uid || text(after.status) !== 'pendente' || text(before?.status) === 'pendente') return null;
  const user = text(after.nome_usuario);
  const partner = text(after.nome);
  if (!partner) return null;
  const region = text(after.regiao);
  return {
    tipo: 'solicitacao_parceiro',
    titulo: 'Novo pedido de parceiro',
    corpo: shorten(
      `${user ? `${user} quer ser parceiro` : 'Pedido de parceiro'}: ${partner}${region ? ` (${region})` : ''}`,
      240,
    ),
    aba: 'solicitacoes_parceiro',
    regiao: region,
    alvo: { topic: ADMINS_TOPIC },
  };
}

/** Parceiro aprovado pediu vínculo com destaques sem dono: avisa os admins. */
export function partnerLinkRequestMessage(uid: string, before: Doc | undefined, after: Doc | undefined): PushMessage | null {
  if (!before || !after || !uid || text(after.status) !== 'aprovada') return null;
  const ids = (value: unknown) => (Array.isArray(value) ? value.map((id) => text(id)) : []);
  const previous = new Set(ids(before.idsDestaquesVinculo));
  const added = ids(after.idsDestaquesVinculo).filter((id) => id && !previous.has(id));
  if (added.length === 0) return null;
  const partner = text(after.nome);
  return {
    tipo: 'solicitacao_parceiro',
    titulo: 'Pedido de vínculo de destaque',
    corpo: shorten(
      `${partner || 'Um parceiro'} diz que ${added.length === 1 ? 'um destaque é dele' : `${added.length} destaques são dele`}`,
      240,
    ),
    aba: 'solicitacoes_parceiro',
    regiao: text(after.regiao),
    alvo: { topic: ADMINS_TOPIC },
  };
}

/** Admin aprovou, rejeitou ou encerrou a parceria: avisa só quem pediu. */
export function partnerRequestAnswerMessage(uid: string, before: Doc | undefined, after: Doc | undefined): PushMessage | null {
  if (!before || !after || !uid) return null;
  const from = text(before.status);
  const status = text(after.status);
  const answered = from === 'pendente' && (status === 'aprovada' || status === 'rejeitada');
  const revoked = from === 'aprovada' && status === 'removido';
  if (!answered && !revoked) return null;
  const reason = text(after.motivo);
  const why = reason ? ` Motivo: ${reason}` : '';
  const region = text(after.regiao);
  return {
    tipo: 'solicitacao_parceiro_resposta',
    titulo: status === 'aprovada' ? '🤝 Você agora é parceiro!' : 'Parceria',
    corpo: shorten(
      status === 'aprovada'
        ? `Já pode publicar no app${region ? ` em ${region}` : ''}. Toque para ver o que está liberado.`
        : status === 'rejeitada'
          ? `O pedido de parceria não foi aprovado.${why}`
          : `A sua parceria foi encerrada.${why}`,
      240,
    ),
    aba: 'parceiro',
    regiao: region,
    alvo: { topic: userTopic(uid) },
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
