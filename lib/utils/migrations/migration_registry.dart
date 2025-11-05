import 'migration.dart';
import 'migration_1_initial.dart';
import 'migration_2_add_created_at.dart';
import 'migration_3_add_users_table.dart';
import 'migration_4_add_user_id_to_tasks.dart';

/// Registro centralizado de todas las migraciones disponibles.
///
/// Este registro permite a `DatabaseIO` descubrir y ejecutar
/// migraciones automáticamente sin necesidad de conocerlas explícitamente.
///
/// **Uso**:
/// - Agregar nuevas migraciones a la lista `_migrations` cuando se crean
/// - Las migraciones se ejecutan automáticamente en orden según su versión
class MigrationRegistry {
  /// Lista de todas las migraciones disponibles, ordenadas por versión.
  ///
  /// **IMPORTANTE**: Las migraciones deben estar ordenadas secuencialmente (1, 2, 3...)
  /// y deben agregarse aquí cuando se crean nuevas migraciones.
  static final List<Migration> _migrations = [
    Migration1Initial(),
    Migration2AddCreatedAt(),
    Migration3AddUsersTable(),
    Migration4AddUserIdToTasks(),
    // Agregar nuevas migraciones aquí:
  ];

  /// Obtiene todas las migraciones disponibles, ordenadas por versión.
  ///
  /// Retorna una copia de la lista ordenada por versión (menor a mayor).
  static List<Migration> getAllMigrations() {
    return List.from(_migrations)
      ..sort((a, b) => a.version.compareTo(b.version));
  }

  /// Obtiene las migraciones que deben ejecutarse para pasar de [fromVersion] a [toVersion].
  ///
  /// Retorna todas las migraciones cuya versión está en el rango
  /// (fromVersion < version <= toVersion), ordenadas por versión.
  ///
  /// [fromVersion] - Versión actual de la base de datos
  /// [toVersion] - Versión objetivo a la que migrar
  static List<Migration> getMigrationsForRange(int fromVersion, int toVersion) {
    return _migrations
        .where((m) => m.version > fromVersion && m.version <= toVersion)
        .toList()
      ..sort((a, b) => a.version.compareTo(b.version));
  }

  /// Obtiene la migración más reciente (mayor versión).
  ///
  /// Se usa para crear el schema inicial cuando la BD se crea por primera vez.
  /// Retorna `null` si no hay migraciones registradas.
  static Migration? getLatestMigration() {
    if (_migrations.isEmpty) return null;
    return _migrations.reduce((a, b) => a.version > b.version ? a : b);
  }

  /// Obtiene la versión más reciente disponible.
  ///
  /// Retorna el número de versión de la migración más reciente, o `1` si no hay migraciones.
  /// Se usa para determinar la versión actual de la base de datos.
  static int getLatestVersion() {
    final latest = getLatestMigration();
    return latest?.version ?? 1;
  }
}
