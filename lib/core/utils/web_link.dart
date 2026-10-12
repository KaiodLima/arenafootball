/// Link como será gravado: sem esquema, ganha "https://" (ex.: "loja.com.br").
String normalizeWebLink(String link) {
  final value = link.trim();
  if (value.isEmpty || value.contains('://')) return value;
  return 'https://$value';
}

/// Vazio conta como válido (link é opcional); preenchido precisa ser um
/// endereço web com domínio (ex.: "abc" não é).
bool isValidWebLink(String link) {
  final value = normalizeWebLink(link);
  if (value.isEmpty) return true;
  final uri = Uri.tryParse(value);
  return uri != null && uri.hasScheme && uri.host.contains('.');
}
