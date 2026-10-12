/// Recorte da lista de partidas de um campeonato.
enum MatchesFilter {
  /// Só as partidas de ontem (aba de tabelas da home).
  yesterday(-1),

  /// Só as partidas do dia (aba de tabelas da home).
  today(0),

  /// Só as partidas de amanhã (aba de tabelas da home).
  tomorrow(1),

  /// Todas as partidas do campeonato na temporada ("TODOS OS JOGOS").
  all(null);

  /// Dias a partir de hoje; nulo = sem recorte por data.
  final int? dayOffset;

  const MatchesFilter(this.dayOffset);
}
