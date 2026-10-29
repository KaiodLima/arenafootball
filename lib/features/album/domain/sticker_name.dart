/// Textos da figurinha no estilo Panini: o nome em duas linhas (primeiro nome
/// pequeno, sobrenome em destaque) e a sigla de 3 letras do time.
class StickerName {
  const StickerName._();

  static const _accents = {
    'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'é': 'e', 'ê': 'e', 'è': 'e', 'í': 'i', 'î': 'i', //
    'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ç': 'c', 'ñ': 'n',
  };

  /// Palavras que não entram na sigla ("Lava Jato FC" → LAV).
  static const _skip = {
    'fc', 'ec', 'sc', 'ac', 'cf', 'ce', 'esporte', 'clube', 'futebol', 'de', 'da', 'do', 'das', 'dos', 'e',
  };

  /// (primeiro nome, destaque): "Carlos Eduardo Silva" → ("Carlos", "Silva");
  /// nome único → ("", nome).
  static (String, String) split(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return ('', '');
    if (words.length == 1) return ('', words.first);
    return (words.first, words.last);
  }

  /// Sigla do time, em maiúsculas e sem acento: 3+ palavras = as iniciais;
  /// senão, as 3 primeiras letras da primeira.
  static String teamCode(String team) {
    final plain = team.toLowerCase().split('').map((c) => _accents[c] ?? c).join();
    final words = plain
        .split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.isNotEmpty && !_skip.contains(w))
        .toList();
    if (words.isEmpty) return '';
    final code = words.length >= 3 ? words.take(3).map((w) => w[0]).join() : words.first;
    return code.substring(0, code.length < 3 ? code.length : 3).toUpperCase();
  }
}
