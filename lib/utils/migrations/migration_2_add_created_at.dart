import 'package:sqflite/sqflite.dart';
import '../logger.dart';
import 'migration.dart';

/// Migración versión 2: Agregar columna createdAt a tabla tasks.
///
/// Esta migración agrega la columna `createdAt` a la tabla `tasks`
/// para almacenar la fecha de creación de cada tarea en formato UTC (timestamp).
class Migration2AddCreatedAt extends Migration {
  @override
  int get version => 2;

  @override
  String get description => 'Agregar columna createdAt a tabla tasks';

  @override
  Future<void> up(Database db) async {
    try {
      AppLogger.info('Migración a versión $version: $description');

      // Verificar si la columna ya existe
      final columns = await db.rawQuery('PRAGMA table_info(tasks)');
      final hasCreatedAt = columns.any((col) => col['name'] == 'createdAt');

      if (!hasCreatedAt) {
        // Agregar columna createdAt
        await db.execute(
          'ALTER TABLE tasks ADD COLUMN createdAt INTEGER NOT NULL DEFAULT 0',
        );
        AppLogger.info('Columna createdAt agregada a tabla tasks');

        // Actualizar registros existentes con timestamp actual (UTC)
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        final updated = await db.update(
          'tasks',
          {'createdAt': now},
          where: 'createdAt = 0 OR createdAt IS NULL',
        );
        AppLogger.info(
            'Migración completada: $updated registros actualizados con timestamp actual');

        AppLogger.info('Migración a versión $version completada exitosamente');
      } else {
        AppLogger.info(
            'Columna createdAt ya existe, saltando agregado de columna');
      }
    } catch (e) {
      AppLogger.error('Error en migración a versión $version', e);
      rethrow;
    }
  }

  @override
  Future<void> createSchema(Database db) async {
    // Esta migración solo modifica una tabla existente, no crea schema inicial completo
    // El schema inicial lo crea Migration1Initial
    throw UnimplementedError(
      'Esta migración no crea schema inicial. Usar Migration1Initial para crear schema base.',
    );
  }
}
