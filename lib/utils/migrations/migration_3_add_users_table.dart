import 'package:sqflite/sqflite.dart';
import 'package:bcrypt/bcrypt.dart';
import '../logger.dart';
import 'migration.dart';

/// Migración versión 3: Agregar tabla users para módulo security.
///
/// Crea la tabla `users` con los campos necesarios para almacenar usuarios
/// del sistema, incluyendo índice único en email para garantizar unicidad.
class Migration3AddUsersTable extends Migration {
  @override
  int get version => 3;

  @override
  String get description => 'Agregar tabla users para módulo security';

  @override
  Future<void> up(Database db) async {
    try {
      AppLogger.info('Aplicando migración versión $version: $description');

      // Crear tabla users
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          role TEXT NOT NULL
        )
      ''');

      // Crear índice único en email para garantizar unicidad
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email ON users(email)',
      );

      AppLogger.info('Tabla users creada exitosamente');

      // Crear usuario administrador por defecto si no existe
      await _createAdminUser(db);

      AppLogger.info('Migración versión $version completada exitosamente');
    } catch (e) {
      AppLogger.error('Error en migración versión $version', e);
      rethrow;
    }
  }

  @override
  Future<void> createSchema(Database db) async {
    try {
      AppLogger.info('Creando schema tabla users (versión $version)...');

      // Crear tabla users
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          role TEXT NOT NULL
        )
      ''');

      // Crear índice único en email
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email ON users(email)',
      );

      AppLogger.info('Tabla users creada exitosamente');

      // Crear usuario administrador por defecto si no existe
      await _createAdminUser(db);

      AppLogger.info('Schema tabla users creado exitosamente');
    } catch (e) {
      AppLogger.error('Error al crear schema tabla users', e);
      rethrow;
    }
  }

  /// Crea el usuario administrador por defecto si no existe.
  ///
  /// Email: admin@task-manager.com
  /// Password: TaskManager1990* (hasheada con bcrypt)
  /// Role: admin
  Future<void> _createAdminUser(Database db) async {
    try {
      // Verificar si el usuario admin ya existe
      final result = await db.rawQuery(
        "SELECT COUNT(*) as count FROM users WHERE email = 'admin@task-manager.com'",
      );
      final count = result.first['count'] as int;

      if (count > 0) {
        AppLogger.info('Usuario administrador ya existe, saltando creación');
        return;
      }

      // Hashear contraseña con bcrypt
      // La contraseña por defecto es: TaskManager1990*
      const plainPassword = 'TaskManager1990*';
      final passwordHash = BCrypt.hashpw(plainPassword, BCrypt.gensalt());

      await db.insert(
        'users',
        {
          'email': 'admin@task-manager.com',
          'password': passwordHash,
          'role': 'admin',
        },
      );

      AppLogger.info(
        'Usuario administrador creado: admin@task-manager.com',
      );
    } catch (e) {
      AppLogger.error('Error al crear usuario administrador', e);
      // No relanzar el error para no bloquear la migración
      // El usuario admin se puede crear manualmente después
    }
  }
}
