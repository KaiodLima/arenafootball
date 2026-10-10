import 'dart:developer' as developer;

class AppLogger {
  static void d(String message, {String name = 'arena'}) {
    developer.log(message, name: name);
  }

  static void e(
    String message, {
    String name = 'arena',
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(message, name: name, error: error, stackTrace: stackTrace);
  }
}
