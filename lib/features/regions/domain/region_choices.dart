import 'package:arena_soccer/core/utils/search_text.dart';

/// Escolha da região no seletor da home: busca sem acento e as recentes.
class RegionChoices {
  const RegionChoices._();

  /// Quantas recentes ficam guardadas (a atual entra também).
  static const int keep = 4;

  /// Quantas recentes a folha mostra (sem a atual).
  static const int shown = 3;

  /// [item] na frente, sem repetir, no máximo [keep].
  static List<String> push(List<String> recent, String item) =>
      [item, ...recent.where((r) => r != item)].take(keep).toList();

  /// Recentes para mostrar: as que ainda existem, sem a atual, até [shown].
  static List<String> recentToShow(List<String> recent, {required String selected, required List<String> regions}) =>
      recent.where((r) => r != selected && regions.contains(r)).take(shown).toList();

  /// Regiões em ordem alfabética, filtradas por [query] (sem acento e sem
  /// diferenciar maiúsculas).
  static List<String> search(List<String> regions, String query) {
    final key = foldForSearch(query.trim());
    final sorted = [...regions]..sort((a, b) => foldForSearch(a).compareTo(foldForSearch(b)));
    if (key.isEmpty) return sorted;
    return sorted.where((r) => foldForSearch(r).contains(key)).toList();
  }
}
