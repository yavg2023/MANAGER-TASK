import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Utilidad centralizada para verificaciones de plataforma.
/// Abstraye las verificaciones de web vs mobile/desktop.
class PlatformHelper {
  /// Verifica si la aplicación está ejecutándose en web.
  static bool get isWeb => kIsWeb;

  /// Verifica si la aplicación está ejecutándose en mobile o desktop (NO web).
  static bool get isMobileOrDesktop => !kIsWeb;

  /// Verifica si la aplicación está ejecutándose en mobile (Android o iOS).
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Verifica si la aplicación está ejecutándose en desktop (macOS, Linux, Windows).
  static bool get isDesktop =>
      !kIsWeb &&
      !Platform.isAndroid &&
      !Platform.isIOS &&
      (Platform.isMacOS || Platform.isLinux || Platform.isWindows);
}
