import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// Utilidad centralizada para logging en toda la aplicación.
/// 
/// Siempre usar esta clase en lugar de `print()` o `debugPrint()` directamente.
class AppLogger {
  static const _reset = '\x1B[0m';
  static const _red = '\x1B[31m';
  static const _yellow = '\x1B[33m';
  static const _green = '\x1B[32m';
  static const _blue = '\x1B[34m';

  /// Imprime un mensaje en consola y en el registro de developer.
  static void _log(String message, {String color = _reset}) {
    final timestamp = DateTime.now().toIso8601String();
    final formatted = '$color[$timestamp] $message$_reset';
    debugPrint(formatted);
    developer.log(message, name: 'AppLogger');
  }

  /// Log de un mensaje informativo.
  static void info(String message) {
    _log('[INFO] $message', color: _blue);
  }

  /// Log de advertencia.
  static void warning(String message) {
    _log('[WARN] $message', color: _yellow);
  }

  /// Log de un error con mensaje, error opcional y stack trace opcional.
  ///
  /// Compatible con llamadas de 2 o 3 parámetros:
  /// ```dart
  /// AppLogger.error("Mensaje", e);
  /// AppLogger.error("Mensaje", e, st);
  /// ```
  static void error(String message, [Object? error, StackTrace? stack]) {
    final errorMessage = '$message${error != null ? ": $error" : ""}';
    _log('[ERROR] $errorMessage', color: _red);

    if (stack != null) {
      debugPrint('$_red$stack$_reset');
    }
  }

  /// Log de debug para desarrollo.
  static void debug(String message) {
    _log('[DEBUG] $message', color: _green);
  }
}
