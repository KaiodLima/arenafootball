/// Nome da conta: de [min] a [max] caracteres, sem espaços nas pontas
/// (as mesmas medidas das regras do Firestore em `usuarios`).
enum ProfileNameError { tooShort, tooLong }

abstract final class ProfileName {
  static const min = 3;
  static const max = 40;

  static ProfileNameError? validate(String name) {
    final value = name.trim();
    if (value.length < min) return ProfileNameError.tooShort;
    if (value.length > max) return ProfileNameError.tooLong;
    return null;
  }
}
