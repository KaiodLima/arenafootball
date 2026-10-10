/// Temporadas antigas ficam em coleções com o ano como sufixo
/// (`partidas2023`, `times2022`...). A temporada do ano corrente usa o nome
/// sem sufixo.
///
/// Use sempre este helper em vez de montar o nome na mão.
class SeasonCollection {
  /// Anos disponíveis no seletor de temporada.
  static const List<String> seasons = ['2022', '2023'];

  /// Temporada pré-selecionada quando o usuário ainda não escolheu nenhuma.
  static const String defaultSeason = '2023';

  static String get currentYear => DateTime.now().year.toString();

  static String name(String base, String? season) {
    if (season == null || season.isEmpty || season == currentYear) return base;
    return '$base$season';
  }
}
