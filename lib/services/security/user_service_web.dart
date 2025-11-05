import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';
import '../../models/security/user.dart';
import '../../exceptions/app_exception.dart';
import '../../exceptions/security/auth_exceptions.dart';
import '../../utils/validators/user_validator.dart';
import '../../utils/logger.dart';

/// Implementación del servicio de usuarios para plataforma web.
///
/// Utiliza SharedPreferences para persistencia de datos.
class UserService {
  static const _key = 'users_v1';

  /// Carga la lista de usuarios desde SharedPreferences.
  Future<List<User>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_key);
    if (usersJson == null) return [];

    try {
      final List<dynamic> decoded = json.decode(usersJson) as List;
      return decoded
          .map((e) => User.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      AppLogger.error(
          'Error al decodificar usuarios desde SharedPreferences', e);
      return [];
    }
  }

  /// Guarda la lista de usuarios en SharedPreferences.
  Future<void> _saveUsers(List<User> users) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = json.encode(
        users.map((user) => user.toMap()).toList(),
      );
      await prefs.setString(_key, usersJson);
    } catch (e) {
      AppLogger.error('Error al guardar usuarios en SharedPreferences', e);
      throw AppException(
        'No se pudo guardar el usuario. Por favor, intenta nuevamente.',
      );
    }
  }

  /// Crea un nuevo usuario en SharedPreferences.
  ///
  /// Valida email y contraseña, verifica que el email no exista,
  /// hashea la contraseña con bcrypt e inserta el usuario.
  ///
  /// [email] - Email del usuario (debe ser único)
  /// [password] - Contraseña en texto plano (se hasheará antes de guardar)
  /// [role] - Rol del usuario: 'user' o 'admin' (default: 'user')
  ///
  /// Retorna el `User` creado (con password hasheada).
  /// Lanza excepciones si hay errores de validación o el email ya existe.
  Future<User> createUser(
    String email,
    String password, {
    String role = 'user',
  }) async {
    // Validar email
    final emailValidation = UserValidator.validateEmail(email);
    if (!emailValidation.isValid) {
      throw InvalidEmailException(email);
    }

    // Validar contraseña
    final passwordValidation = UserValidator.validatePassword(password);
    if (!passwordValidation.isValid) {
      throw InvalidPasswordException(
        passwordValidation.error ?? 'La contraseña no es válida',
      );
    }

    // Verificar que el email no exista
    final exists = await emailExists(email);
    if (exists) {
      throw EmailAlreadyExistsException(email);
    }

    try {
      // Hashear contraseña con bcrypt
      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

      // Obtener lista actual de usuarios
      final users = await _loadUsers();

      // Generar ID único (usar timestamp para simplicidad)
      final id = DateTime.now().millisecondsSinceEpoch;

      // Crear nuevo usuario
      final newUser = User(
        id: id,
        email: email.trim().toLowerCase(),
        password: passwordHash,
        role: role,
      );

      // Agregar a la lista
      users.add(newUser);

      // Guardar lista actualizada
      await _saveUsers(users);

      AppLogger.info('Usuario creado exitosamente: $email (ID: $id)');

      return newUser;
    } catch (e) {
      if (e is AppException) rethrow;
      AppLogger.error('Error al crear usuario en SharedPreferences', e);
      throw AppException(
        'No se pudo crear el usuario. Por favor, intenta nuevamente.',
      );
    }
  }

  /// Verifica si un email ya está registrado en SharedPreferences.
  ///
  /// [email] - Email a verificar
  /// Retorna `true` si el email existe, `false` si no.
  Future<bool> emailExists(String email) async {
    try {
      final users = await _loadUsers();
      final normalizedEmail = email.trim().toLowerCase();
      return users.any((user) => user.email == normalizedEmail);
    } catch (e) {
      AppLogger.error('Error al verificar existencia de email', e);
      throw AppException(
        'No se pudo verificar el email. Por favor, intenta nuevamente.',
      );
    }
  }

  /// Busca un usuario por su email.
  ///
  /// [email] - Email del usuario a buscar
  /// Retorna el `User` si existe, `null` si no existe.
  Future<User?> findUserByEmail(String email) async {
    try {
      final users = await _loadUsers();
      final normalizedEmail = email.trim().toLowerCase();
      try {
        return users.firstWhere(
          (user) => user.email == normalizedEmail,
        );
      } catch (e) {
        // firstWhere lanza excepción si no encuentra, retornar null
        return null;
      }
    } catch (e) {
      AppLogger.error('Error al buscar usuario por email', e);
      throw AppException(
        'No se pudo buscar el usuario. Por favor, intenta nuevamente.',
      );
    }
  }
}
