import 'package:bcrypt/bcrypt.dart';
import '../../models/security/user.dart';
import '../../utils/database_io.dart';
import '../../exceptions/app_exception.dart';
import '../../exceptions/security/auth_exceptions.dart';
import '../../utils/validators/user_validator.dart';
import '../../utils/logger.dart';

/// Implementación del servicio de usuarios para plataformas IO (desktop y móvil).
///
/// Utiliza SQLite a través de DatabaseIO para persistencia de datos.
class UserService {
  /// Crea un nuevo usuario en la base de datos.
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

      // Insertar usuario en la base de datos
      return await DatabaseIO.withDatabase((db) async {
        final id = await db.insert(
          'users',
          {
            'email': email.trim().toLowerCase(),
            'password': passwordHash,
            'role': role,
          },
        );

        AppLogger.info('Usuario creado exitosamente: $email (ID: $id)');

        // Retornar usuario creado (con password hasheada)
        return User(
          id: id,
          email: email.trim().toLowerCase(),
          password: passwordHash,
          role: role,
        );
      });
    } catch (e) {
      if (e is AppException) rethrow;
      AppLogger.error('Error al crear usuario en base de datos', e);
      throw AppException(
        'No se pudo crear el usuario. Por favor, intenta nuevamente.',
      );
    }
  }

  /// Verifica si un email ya está registrado en la base de datos.
  ///
  /// [email] - Email a verificar
  /// Retorna `true` si el email existe, `false` si no.
  Future<bool> emailExists(String email) async {
    try {
      return await DatabaseIO.withDatabase((db) async {
        final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM users WHERE email = ?',
          [email.trim().toLowerCase()],
        );
        final count = result.first['count'] as int;
        return count > 0;
      });
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
      return await DatabaseIO.withDatabase((db) async {
        final result = await db.query(
          'users',
          where: 'email = ?',
          whereArgs: [email.trim().toLowerCase()],
          limit: 1,
        );

        if (result.isEmpty) {
          return null;
        }

        return User.fromMap(result.first);
      });
    } catch (e) {
      AppLogger.error('Error al buscar usuario por email', e);
      throw AppException(
        'No se pudo buscar el usuario. Por favor, intenta nuevamente.',
      );
    }
  }
}
