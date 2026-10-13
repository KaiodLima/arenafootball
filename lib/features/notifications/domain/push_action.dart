/// Ações que podem emitir push. [key] é a chave em `config/notificacoes` e o
/// `tipo` no histórico; [defaultEnabled] vale enquanto o admin não mexer (o
/// mesmo padrão das Cloud Functions).
enum PushAction {
  goal('gol', true),
  news('noticia', false),
  match('partida', true),
  votingOpen('votacao_aberta', true),
  votingClosed('votacao_encerrada', true),
  dailyGame('jogo_do_dia', true),
  notice('aviso', true),
  playerRequest('solicitacao_jogador', true),
  playerRequestAnswer('solicitacao_resposta', true),
  teamRequest('solicitacao_time', true),
  teamRequestAnswer('solicitacao_time_resposta', true);

  final String key;
  final bool defaultEnabled;

  const PushAction(this.key, this.defaultEnabled);

  static PushAction? fromKey(String key) {
    for (final action in values) {
      if (action.key == key) return action;
    }
    return null;
  }
}
