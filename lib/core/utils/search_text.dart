/// Texto para comparação em buscas: minúsculo e sem acentos ("João" → "joao").
String foldForSearch(String text) => text.toLowerCase().split('').map((char) => _accents[char] ?? char).join();

const _accents = {
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ã': 'a',
  'é': 'e',
  'ê': 'e',
  'í': 'i',
  'ó': 'o',
  'ô': 'o',
  'õ': 'o',
  'ú': 'u',
  'ü': 'u',
  'ç': 'c'
};
