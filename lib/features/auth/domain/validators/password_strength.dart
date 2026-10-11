/// Força da senha exibida no cadastro. Não bloqueia o envio: o único mínimo
/// obrigatório é [PasswordStrength.minLength] caracteres.
enum PasswordStrength {
  weak,
  medium,
  strong;

  static const int minLength = 8;

  /// Pontua comprimento, mistura de maiúsculas/minúsculas, dígitos e símbolos.
  static PasswordStrength evaluate(String password) {
    var score = 0;
    if (password.length >= minLength) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp('[a-z]')) && password.contains(RegExp('[A-Z]'))) score++;
    if (password.contains(RegExp(r'\d'))) score++;
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) score++;

    if (password.length < minLength || score < 2) return PasswordStrength.weak;
    if (score < 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }
}
