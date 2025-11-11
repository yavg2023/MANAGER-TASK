import 'package:sqflite/sqflite.dart';
import '../logger.dart';
import 'migration.dart';

/// Migración versión 4: Agregar columna userId a tabla tasks.
///
/// Esta migración agrega la columna `userId` a la tabla `tasks` para
/// integrar con el módulo `security` y permitir el aislamiento de datos por usuario.
/// La columna es nullable para mantener compatibilidad con tareas existentes
/// que fueron creadas antes de implementar el módulo de seguridad.
class Migration4AddUserIdToTasks extends Migration {
  @override
  int get version => 4;

  @override
  String get description =>
      'Agregar columna userId a tabla tasks para integración con security';

  @override
  Future<void> up(Database db) async {
    try {
      AppLogger.info('Migración a versión $version: $description');

      // Verificar si la columna ya existe
      final columns = await db.rawQuery('PRAGMA table_info(tasks)');
      final hasUserId = columns.any((col) => col['name'] == 'userId');

      if (!hasUserId) {
        // Agregar columna userId (nullable para compatibilidad con tareas existentes)
        await db.execute(
          'ALTER TABLE tasks ADD COLUMN userId INTEGER',
        );
        AppLogger.info('Columna userId agregada a tabla tasks');

        // Agregar índice en userId para mejorar performance en queries
        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON tasks(userId)',
        );
        AppLogger.info('Índice idx_tasks_user_id creado en columna userId');

        AppLogger.info('Migración a versión $version completada exitosamente');
      } else {
        AppLogger.info(
            'Columna userId ya existe, saltando agregado de columna');
      }
    } catch (e) {
      AppLogger.error('Error en migración a versión $version', e);
      rethrow;
    }
  }

  @override
  Future<void> createSchema(Database db) async {
    // Esta migración solo agrega una columna.
    // El schema inicial completo lo crea Migration1Initial.
    // Si esta fuera la versión inicial, aquí se crearía el schema completo.
    throw UnimplementedError(
      'Esta migración no crea schema inicial completo. '
      'Usar Migration1Initial para crear schema base.',
    );
  }
}
