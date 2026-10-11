import 'package:firebase_auth/firebase_auth.dart';
import 'package:arena_soccer/core/errors/failure.dart';

/// Converte qualquer excecao vinda do Firebase em [ErrorWithMessage],
/// preservando o `code` para quem precisar ramificar sem olhar o texto.
/// Papel equivalente ao `ApiError` do Relove.
ErrorWithMessage mapFirebaseError(Object error, {required String fallbackMessage}) {
  if (error is FirebaseAuthException) {
    return ErrorWithMessage(_authMessage(error.code) ?? fallbackMessage, code: error.code);
  }
  if (error is FirebaseException) {
    return ErrorWithMessage(fallbackMessage, code: error.code);
  }
  return ErrorWithMessage(fallbackMessage);
}

String? _authMessage(String code) {
  switch (code) {
    case 'user-not-found':
      return 'Nenhum usuário encontrado para esse e-mail.';
    case 'wrong-password':
    case 'invalid-credential':
      return 'E-mail ou senha incorretos.';
    case 'invalid-email':
      return 'E-mail inválido.';
    case 'email-already-in-use':
      return 'Já existe uma conta com esse e-mail.';
    case 'weak-password':
      return 'Senha muito fraca.';
    case 'too-many-requests':
      return 'Muitas tentativas. Aguarde alguns minutos e tente de novo.';
    case 'network-request-failed':
      return 'Sem conexão com a internet.';
    default:
      return null;
  }
}
