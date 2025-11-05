import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/security/user.dart';
import '../../services/security/auth_service.dart';
import '../../exceptions/app_exception.dart';
import '../../exceptions/security/auth_exceptions.dart';
import '../../utils/logger.dart';

/// Provider de autenticación que gestiona el estado de autenticación de la aplicación.
///
/// Mantiene el estado del usuario autenticado y proporciona métodos para login,
/// logout y verificación de sesión.
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _loading = false;
  String? _error;

  /// Usuario actualmente autenticado (null si no hay sesión).
  User? get currentUser => _currentUser;

  /// Indica si hay un usuario autenticado.
  bool get isAuthenticated => _currentUser != null;

  /// Rol del usuario autenticado ('user' o 'admin'), null si no hay sesión.
  String? get role => _currentUser?.role;

  /// Indica si hay una operación en curso (loading).
  bool get loading => _loading;

  /// Mensaje de error actual (null si no hay error).
  String? get error => _error;

  /// Indica si hay un error actual.
  bool get hasError => _error != null;

  /// Limpia el mensaje de error actual.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Maneja errores y establece el mensaje apropiado.
  void _handleError(dynamic e) {
    if (e is AppException) {
      // AppException y todas sus subclases tienen mensaje en español
      _error = e.toString();
    } else {
      _error =
          'Ha ocurrido un error inesperado. Por favor, inténtalo de nuevo.';
    }
    AppLogger.error('Error en AuthProvider', e);
    notifyListeners();
  }

  /// Autentica un usuario con email y contraseña.
  ///
  /// [email] - Email del usuario
  /// [password] - Contraseña del usuario
  ///
  /// Retorna `true` si el login fue exitoso, `false` si falló.
  /// Los errores se exponen a través de `error` y `hasError`.
  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);

      if (user == null) {
        _error = 'Credenciales incorrectas';
        _loading = false;
        notifyListeners();
        return false;
      }

      // Guardar usuario autenticado
      _currentUser = user;

      // Guardar sesión persistentemente
      await _saveSession(user);

      _loading = false;
      notifyListeners();

      AppLogger.info('Login exitoso: ${user.email}');
      return true;
    } catch (e) {
      // Manejar excepciones específicas
      if (e is UserNotFoundException || e is InvalidCredentialsException) {
        // Estas excepciones ya tienen mensajes apropiados en español
        _error = e.toString();
      } else if (e is AppException) {
        _error = e.toString();
      } else {
        _error =
            'Ha ocurrido un error inesperado. Por favor, inténtalo de nuevo.';
      }

      _loading = false;
      _handleError(e);
      return false;
    }
  }

  /// Guarda la sesión del usuario en SharedPreferences.
  ///
  /// [user] - Usuario autenticado a guardar
  ///
  /// Nota: AuthService ya guarda la sesión en login() usando 'current_user_session'.
  /// Este método limpia la clave antigua 'current_user_email' para mantener consistencia.
  Future<void> _saveSession(User user) async {
    try {
      // AuthService ya guarda la sesión en 'current_user_session' durante login()
      // Limpiar clave antigua 'current_user_email' para mantener consistencia
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_email');
      AppLogger.info(
          'Sesión guardada para usuario: ${user.email} (por AuthService)');
    } catch (e) {
      AppLogger.error('Error al limpiar sesión antigua', e);
      // No relanzar error, la sesión puede continuar sin persistencia
    }
  }

  /// Limpia la sesión guardada en SharedPreferences.
  ///
  /// Limpia tanto 'current_user_session' (usado por AuthService) como
  /// 'current_user_email' (clave antigua) para compatibilidad.
  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Limpiar ambas claves para compatibilidad
      await prefs.remove('current_user_email');
      await prefs.remove('current_user_session');
      AppLogger.info('Sesión limpiada');
    } catch (e) {
      AppLogger.error('Error al limpiar sesión', e);
      // No relanzar error
    }
  }

  /// Carga el usuario actual desde la sesión persistida.
  ///
  /// Usa AuthService.getCurrentUser() que lee desde 'current_user_session'.
  /// Si el usuario existe, establece `_currentUser`.
  /// Si no existe o no hay sesión guardada, establece `_currentUser = null`.
  Future<void> loadCurrentUser() async {
    try {
      // Usar AuthService.getCurrentUser() que lee desde 'current_user_session'
      // (el sistema de sesión unificado usado por AuthService)
      final user = await _authService.getCurrentUser();

      if (user == null) {
        // No hay sesión válida, limpiar estado
        _currentUser = null;
        notifyListeners();
        return;
      }

      // Usuario encontrado, establecer como usuario actual
      _currentUser = user;
      notifyListeners();

      AppLogger.info('Usuario actual cargado: ${user.email}');
    } catch (e) {
      AppLogger.error('Error al cargar usuario actual', e);
      // En caso de error, limpiar sesión y establecer null
      await _clearSession();
      _currentUser = null;
      notifyListeners();
    }
  }

  /// Cierra la sesión del usuario actual.
  ///
  /// Limpia el estado de autenticación y la sesión persistida.
  /// La redirección a `/login` debe manejarse en la UI que llama a este método.
  Future<void> logout() async {
    _loading = true;
    notifyListeners();

    try {
      // Llamar a AuthService para logout (limpiar sesión en servicio)
      await _authService.logout();

      // Limpiar sesión persistida localmente
      await _clearSession();

      // Limpiar estado
      _currentUser = null;
      _error = null;

      _loading = false;
      notifyListeners();

      AppLogger.info('Logout exitoso');
    } catch (e) {
      AppLogger.error('Error en logout', e);
      // Incluso si hay error, limpiar estado local
      _currentUser = null;
      _error = null;
      _loading = false;
      notifyListeners();
    }
  }
}
