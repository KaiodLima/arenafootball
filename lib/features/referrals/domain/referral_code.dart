/// Regras do "Indique amigos" que o app aplica antes de gravar (as functions
/// conferem de novo em `functions/src/referrals.ts`).
class ReferralCode {
  ReferralCode._();

  /// Tamanho do código (o maior só se o de 8 já for de outra conta).
  static const int length = 8;
  static const int longLength = 10;

  /// Só vale indicação de conta criada há no máximo isto.
  static const int windowDays = 7;

  /// Pacotinhos extras guardados, no máximo.
  static const int maxExtraPacks = 5;

  static final RegExp _pattern = RegExp(r'^[A-Z0-9]{8,10}$');

  /// Código da conta [uid]: o começo do uid em maiúsculas (igual às regras).
  static String of(String uid, {int length = length}) =>
      (uid.length > length ? uid.substring(0, length) : uid).toUpperCase();

  /// Texto digitado → código (sem espaços, maiúsculo).
  static String normalize(String input) => input.replaceAll(RegExp(r'\s'), '').toUpperCase();

  static bool isValid(String code) => _pattern.hasMatch(code);

  /// [code] é da própria conta [uid].
  static bool isOwn(String uid, String code) => code.isNotEmpty && uid.toUpperCase().startsWith(code);

  /// Conta ainda pode dizer quem a indicou (criada há até [windowDays]).
  static bool isNewAccount(DateTime? createdAt, DateTime now) =>
      createdAt != null && now.difference(createdAt) <= const Duration(days: windowDays);
}
