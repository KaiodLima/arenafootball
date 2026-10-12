/// Nome das coleções por temporada.
///
/// - [legacySeason] (2023) é a única temporada gravada nas coleções **sem
///   sufixo** (`times`, `partidas`...), herança do app antigo.
/// - Todas as outras usam o ano como sufixo: `times2022`, `partidas2024`...
///
/// A temporada **atual** não é o ano do relógio nem uma constante: vem do
/// Firestore (`config/temporadas`, carregado pelo `RegionCubit` via
/// [configure]) e o admin troca pelo painel "Temporadas". Abrir uma temporada
/// nova não copia nem renomeia coleções: só passa a gravar nas do ano novo.
///
/// Use sempre este helper em vez de montar o nome na mão.
class SeasonCollection {
  /// Temporada gravada nas coleções sem sufixo.
  static const String legacySeason = '2023';

  /// Valores usados até a config do Firestore carregar (ou se ela não existir).
  static const String fallbackSeason = legacySeason;
  static const List<String> fallbackSeasons = ['2022', legacySeason];

  static String _current = fallbackSeason;
  static List<String> _seasons = fallbackSeasons;

  /// Temporada em andamento (onde caem os cadastros novos).
  static String get currentSeason => _current;

  /// Anos disponíveis no seletor de temporada, em ordem crescente.
  static List<String> get seasons => _seasons;

  /// Temporada pré-selecionada quando o usuário ainda não escolheu nenhuma.
  static String get defaultSeason => _current;

  /// Aplica a config do Firestore. A atual sempre entra na lista.
  static void configure({required String current, required List<String> seasons}) {
    if (current.isEmpty) return;
    _current = current;
    _seasons = ({...seasons, current}.where((s) => s.isNotEmpty).toList()..sort());
  }

  /// Volta aos valores padrão (testes).
  static void reset() {
    _current = fallbackSeason;
    _seasons = fallbackSeasons;
  }

  /// [season] nulo ou vazio = temporada atual.
  static String name(String base, String? season) {
    final value = (season == null || season.isEmpty) ? _current : season;
    return value == legacySeason ? base : '$base$value';
  }
}
