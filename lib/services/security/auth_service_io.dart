import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';
import '../../models/security/user.dart';
import '../../exceptions/app_exception.dart';
import '../../exceptions/security/auth_exceptions.dart';
import 'user_service_io.dart';
import '../../utils/logger.dart';

/// Implementación del servicio de autenticación para plataformas IO (desktop y móvil).
///
/// Utiliza UserService para acceder a la base de datos SQLite.
class AuthService {
  final UserService _userService = UserService();
  static const String _sessionKey = 'current_user_session';

  /// Autentica un usuario con email y contraseña.
  ///
  /// [email] - Email del usuario
  /// [password] - Contraseña en texto plano
  ///
  /// Retorna el `User` autenticado si las credenciales son correctas.
  /// Lanza `UserNotFoundException` si el usuario no existe.
  /// Lanza `InvalidCredentialsException` si la contraseña es incorrecta.
  Future<User?> login(String email, String password) async {
    try {
      // Buscar usuario por email
      final user = await _userService.findUserByEmail(email);

      if (user == null) {
        throw UserNotFoundException(email);
      }

      // Verificar contraseña con bcrypt
      final isValidPassword = BCrypt.checkpw(password, user.password);

      if (!isValidPassword) {
        throw InvalidCredentialsException();
      }

      // Guardar sesión actual
      await _saveSession(user.email);

      AppLogger.info('Usuario autenticado exitosamente: ${user.email}');

      // Retornar usuario (sin password o según diseño)
      // Por seguridad, no exponer el hash de contraseña fuera del servicio
      return User(
        id: user.id,
        email: user.email,
        password: '', // No exponer hash fuera del servicio
        role: user.role,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      AppLogger.error('Error en autenticación', e);
      throw AppException(
        'No se pudo autenticar el usuario. Por favor, intenta nuevamente.',
      );
    }
  }

  /// Obtiene el usuario actualmente autenticado.
  ///
  /// Lee la sesión guardada desde SharedPreferences y busca el usuario.
  /// Retorna el `User` si hay sesión activa, `null` si no.
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final emailJson = prefs.getString(_sessionKey);

      if (emailJson == null) {
        return null;
      }

      final email = json.decode(emailJson) as String?;
      if (email == null || email.isEmpty) {
        return null;
      }

      // Buscar usuario por email
      final user = await _userService.findUserByEmail(email);
      if (user == null) {
        // Sesión inválida, limpiar
        await logout();
        return null;
      }

      // Retornar usuario (sin password)
      return User(
        id: user.id,
        email: user.email,
        password: '', // No exponer hash
        role: user.role,
      );
    } catch (e) {
      AppLogger.error('Error al obtener usuario actual', e);
      return null;
    }
  }

  /// Cierra la sesión del usuario actual.
  ///
  /// Elimina la sesión guardada en SharedPreferences.
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      AppLogger.info('Sesión cerrada exitosamente');
    } catch (e) {
      AppLogger.error('Error al cerrar sesión', e);
      // No relanzar error, solo loggear
    }
  }

  /// Guarda la sesión del usuario en SharedPreferences.
  ///
  /// [email] - Email del usuario autenticado
  Future<void> _saveSession(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, json.encode(email));
    } catch (e) {
      AppLogger.error('Error al guardar sesión', e);
      // No relanzar error, la autenticación puede continuar sin sesión guardada
    }
  }
}
