/// Temporadas antigas ficam em coleções com o ano como sufixo
/// (`partidas2022`, `times2022`...). A temporada corrente usa o nome sem sufixo.
///
/// A temporada corrente é a que está gravada nas coleções sem sufixo, e não o
/// ano do relógio: o app antigo comparava com `DateTime.now().year`, e a partir
/// de 2024 a temporada 2023 passou a apontar para `times2023` (vazia).
///
/// Ao abrir uma temporada nova: copiar as coleções sem sufixo para `<nome><ano>`,
/// limpar as sem sufixo e atualizar [currentSeason] e [seasons].
///
/// Use sempre este helper em vez de montar o nome na mão.
class SeasonCollection {
  /// Temporada gravada nas coleções sem sufixo.
  static const String currentSeason = '2023';

  /// Anos disponíveis no seletor de temporada.
  static const List<String> seasons = ['2022', currentSeason];

  /// Temporada pré-selecionada quando o usuário ainda não escolheu nenhuma.
  static const String defaultSeason = currentSeason;

  static String name(String base, String? season) {
    if (season == null || season.isEmpty || season == currentSeason) return base;
    return '$base$season';
  }
}
