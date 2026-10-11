import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class AppLogger {
  static void d(String message, {String name = 'arena'}) {
    developer.log(message, name: name);
    // `developer.log` só chega ao DevTools; em debug também vai para o logcat.
    if (kDebugMode) debugPrint('[$name] $message');
  }

  static void e(
    String message, {
    String name = 'arena',
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(message, name: name, error: error, stackTrace: stackTrace);
    if (kDebugMode) debugPrint('[$name] ERROR $message${error == null ? '' : ': $error'}');
  }
}
