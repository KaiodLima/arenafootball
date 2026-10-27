/// Critério de desempate da tabela do grupo (depois dos pontos), na ordem
/// gravada em `campeonatos.desempate`. As functions usam as mesmas chaves
/// (`functions/src/standings.ts`).
enum StandingsCriterion {
  wins('vitorias'),
  goalDifference('saldo'),
  goalsFor('golsPro'),
  headToHead('confronto'),
  fewestGoalsAgainst('menosGolsContra');

  final String key;

  const StandingsCriterion(this.key);

  /// Sem `desempate` no campeonato: vitórias, saldo e gols pró.
  static const List<StandingsCriterion> defaults = [wins, goalDifference, goalsFor];

  static StandingsCriterion? fromKey(String key) {
    for (final criterion in values) {
      if (criterion.key == key) return criterion;
    }
    return null;
  }

  /// Critérios válidos da lista gravada, sem repetidos (vazio = vazio).
  static List<StandingsCriterion> fromKeys(Object? value) {
    final list = <StandingsCriterion>[];
    for (final item in value is List ? value : const []) {
      final criterion = fromKey(item.toString());
      if (criterion != null && !list.contains(criterion)) list.add(criterion);
    }
    return list;
  }

  /// Os que valem: os escolhidos ou, sem nenhum, o padrão.
  static List<StandingsCriterion> effective(List<StandingsCriterion> chosen) => chosen.isEmpty ? defaults : chosen;
}
