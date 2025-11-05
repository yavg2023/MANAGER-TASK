import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'logger.dart';
import 'platform_helper.dart';
import '../models/security/user.dart';

/// Utilidad para manejo de SharedPreferences en web.
/// Crea el usuario admin por defecto si no existe.
class DatabaseWeb {
  static const String _usersKey = 'users_v1';
  static const String _adminEmail = 'admin@task-manager.com';
  static const String _adminPassword = 'TaskManager1990*';
  static bool _initialized = false;

  /// Inicializa SharedPreferences creando el usuario admin por defecto si no existe.
  /// Solo funciona en web. En mobile/desktop retorna true sin hacer nada.
  ///
  /// Retorna `true` si la inicialización fue exitosa, `false` si hubo error.
  static Future<bool> initializeDatabase() async {
    if (!PlatformHelper.isWeb) {
      AppLogger.info('Plataforma: No web - No se inicializa SharedPreferences');
      return true;
    }

    if (_initialized) {
      AppLogger.info('SharedPreferences ya inicializado');
      return true;
    }

    try {
      AppLogger.info('Inicializando SharedPreferences (web)...');

      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      List<User> users = [];
      if (usersJson != null) {
        try {
          final List<dynamic> decoded = json.decode(usersJson) as List;
          users = decoded
              .map((e) => User.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        } catch (e) {
          AppLogger.error('Error al decodificar usuarios', e);
        }
      }

      // Verificar si el usuario admin ya existe
      final adminExists = users.any(
        (user) => user.email.toLowerCase() == _adminEmail.toLowerCase(),
      );

      if (adminExists) {
        AppLogger.info('Usuario administrador ya existe en SharedPreferences');
        _initialized = true;
        return true;
      }

      // Crear usuario admin por defecto
      final passwordHash = BCrypt.hashpw(_adminPassword, BCrypt.gensalt());
      final adminUser = User(
        id: DateTime.now().millisecondsSinceEpoch,
        email: _adminEmail,
        password: passwordHash,
        role: 'admin',
      );

      users.add(adminUser);

      // Guardar lista actualizada
      final updatedJson = json.encode(users.map((user) => user.toMap()).toList());
      await prefs.setString(_usersKey, updatedJson);

      AppLogger.info(
        'Usuario administrador creado en SharedPreferences: $_adminEmail',
      );

      _initialized = true;
      return true;
    } catch (e) {
      AppLogger.error('Error al inicializar SharedPreferences (web)', e);
      return false;
    }
  }
}

