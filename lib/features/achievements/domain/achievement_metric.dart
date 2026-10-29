/// O que uma conquista mede. A chave é o campo em
/// `usuarios/{uid}/progresso/contadores` e o valor gravado em
/// `conquistas.metrica` (as Cloud Functions usam as mesmas chaves, em
/// `functions/src/achievements.ts`).
enum AchievementMetric {
  /// Votos de melhor jogador (contado no servidor).
  votes('votos', countedByApp: false),

  /// Compartilhamentos (notícia, atleta, destaque, craque, carteirinha).
  shares('compartilhamentos', countedByApp: true),

  /// Notícias abertas.
  newsRead('noticiasLidas', countedByApp: true),

  /// Dias diferentes em que abriu o app logado.
  activeDays('diasAtivos', countedByApp: true),

  /// Maior sequência de dias seguidos abrindo o app.
  bestStreak('melhorSequencia', countedByApp: true),

  /// Escolheu o time do coração (0/1).
  favoriteTeam('timeCoracao', countedByApp: false),

  /// Pôs foto na carteirinha (0/1).
  cardPhoto('fotoCarteirinha', countedByApp: false),

  /// Conta ligada a um atleta (0/1).
  athlete('atleta', countedByApp: false),

  /// Gols do atleta da conta na temporada.
  athleteGoals('golsAtleta', countedByApp: false),

  /// Assistências do atleta da conta na temporada.
  athleteAssists('assistenciasAtleta', countedByApp: false),

  /// Dono de time aprovado (0/1).
  teamOwner('donoTime', countedByApp: false),

  /// Palpites do bolão pontuados (feitos no prazo).
  predictions('palpites', countedByApp: false),

  /// Palpites com o placar exato.
  exactPredictions('palpitesExatos', countedByApp: false),

  /// Figurinhas diferentes coladas no álbum (evento).
  albumStickers('albumFigurinhas', countedByApp: false),

  /// Páginas de time completas no álbum.
  albumPages('albumPaginas', countedByApp: false),

  /// Álbum completo (0/1).
  albumComplete('albumCompleto', countedByApp: false);

  final String key;

  /// O app soma (+1 pela regra do Firestore); os outros, as functions.
  final bool countedByApp;

  const AchievementMetric(this.key, {required this.countedByApp});

  static AchievementMetric? fromKey(String? key) {
    for (final metric in values) {
      if (metric.key == key) return metric;
    }
    return null;
  }

  /// Métricas de sim/não: a meta é sempre 1.
  bool get isBoolean => this == favoriteTeam || this == cardPhoto || this == athlete || this == teamOwner || this == albumComplete;
}

/// Nível da medalha (cor e brilho).
enum AchievementTier {
  bronze('bronze'),
  silver('prata'),
  gold('ouro'),
  legend('lenda');

  final String key;

  const AchievementTier(this.key);

  static AchievementTier fromKey(String? key) => values.firstWhere((t) => t.key == key, orElse: () => bronze);
}

/// Grupo da conquista (filtro da tela).
enum AchievementCategory {
  fan('torcida'),
  voting('votacao'),
  sharing('compartilhar'),
  news('noticias'),
  athlete('atleta'),
  predictions('palpites');

  final String key;

  const AchievementCategory(this.key);

  static AchievementCategory fromKey(String? key) => values.firstWhere((c) => c.key == key, orElse: () => fan);
}

/// Nível do torcedor pela soma dos pontos (XP) das conquistas.
enum FanLevel {
  fan(0),
  loyal(100),
  roots(300),
  ultra(700),
  legend(1500);

  /// XP mínimo do nível.
  final int minXp;

  const FanLevel(this.minXp);

  static FanLevel of(int xp) => values.lastWhere((level) => xp >= level.minXp);

  /// Próximo nível (nulo no último).
  FanLevel? get next => index + 1 < values.length ? values[index + 1] : null;

  /// Quanto do caminho até o próximo nível (0–1; 1 no último).
  double progressOf(int xp) {
    final next = this.next;
    if (next == null) return 1;
    return ((xp - minXp) / (next.minXp - minXp)).clamp(0.0, 1.0);
  }
}
