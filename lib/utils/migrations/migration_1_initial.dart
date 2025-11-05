import 'package:sqflite/sqflite.dart';
import '../logger.dart';
import 'migration.dart';

/// Migración versión 1: Schema inicial de la base de datos.
///
/// Esta es la migración base que crea todas las tablas iniciales.
/// Define la estructura fundamental de la base de datos.
class Migration1Initial extends Migration {
  @override
  int get version => 1;

  @override
  String get description => 'Schema inicial de la base de datos';

  @override
  Future<void> up(Database db) async {
    // Esta migración solo se ejecuta si la BD se crea desde cero
    // La lógica está en createSchema()
    await createSchema(db);
  }

  @override
  Future<void> createSchema(Database db) async {
    AppLogger.info(
        'Creando schema inicial de base de datos (versión $version)...');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        completed INTEGER NOT NULL
      )
    ''');

    AppLogger.info('Schema inicial creado exitosamente: tabla tasks');
  }
}
