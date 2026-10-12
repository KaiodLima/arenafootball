/// Número da carteirinha: 8 caracteres derivados do uid, em dois blocos
/// ("4F2A·9C1B"). Só letras e números, sempre o mesmo para a mesma conta.
String fanCardNumber(String userId) {
  final clean = userId.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
  final code = clean.padRight(8, '0').substring(0, 8);
  return '${code.substring(0, 4)}·${code.substring(4)}';
}
