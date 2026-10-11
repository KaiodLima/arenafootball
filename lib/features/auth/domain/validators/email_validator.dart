/// Validação de formato de e-mail (a existência real fica com o FirebaseAuth).
class EmailValidator {
  static final RegExp _pattern = RegExp(r"^[\w.!#$%&'*+/=?^`{|}~-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}$");

  static bool isValid(String email) => _pattern.hasMatch(email.trim());
}
