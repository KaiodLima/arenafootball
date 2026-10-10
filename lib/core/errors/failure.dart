class Failure implements Exception {}

class ErrorWithMessage implements Failure {
  final String message;

  /// Codigo do erro. Para erros do Firebase e o `code` da excecao
  /// (`permission-denied`, `wrong-password`, ...). Nulo para erros locais.
  /// Ramificar por ele, nunca pelo [message], que muda com o idioma.
  final String? code;

  ErrorWithMessage(this.message, {this.code});

  @override
  String toString() => message;
}
