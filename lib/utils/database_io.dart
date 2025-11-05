import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'logger.dart';
import 'migrations/migration_registry.dart';
import 'platform_helper.dart';
// ignore: unnecessary_import
import 'package:sqflite/sqflite.dart';

/// Maneja conexión y migraciones SQLite en móvil / escritorio.
/// En web no hace nada (usa DatabaseWeb).
class DatabaseIO {
  static Database? _database;
  static bool _initialized = false;

  static int get _databaseVersion => MigrationRegistry.getLatestVersion();

  /// Inicializa SQLite dependiendo de la plataforma.
  static Future<bool> initializeDatabase() async {
    if (PlatformHelper.isWeb) {
      AppLogger.info('🌐 Plataforma Web - No se inicializa SQLite (usa DatabaseWeb)');
      return true;
    }

    if (_initialized) {
      AppLogger.info('✅ Base de datos ya inicializada');
      return true;
    }

    try {
      AppLogger.info('🗄️ Inicializando base de datos y ejecutando migraciones...');

      // 🔧 Inicializar motor según plataforma
      String path;
      if (PlatformHelper.isDesktop) {
        AppLogger.info('💻 Plataforma Desktop - Usando sqflite_common_ffi');
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi; // 🔥 Necesario ANTES de getDatabasesPath()
        final dbPath = await databaseFactory.getDatabasesPath();
        path = join(dbPath, 'tasks.db');
      } else {
        AppLogger.info('📱 Plataforma Móvil - Usando sqflite estándar');
        final dbPath = await getDatabasesPath();
        path = join(dbPath, 'tasks.db');
      }

      // Abrir base de datos
      _database = await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: _databaseVersion,
          onCreate: (db, version) async {
            AppLogger.info('📦 Creando nueva BD (versión $version)...');
            await _createSchema(db, version);
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            AppLogger.info('📈 Migrando BD de $oldVersion → $newVersion');
            await _migrateDatabase(db, oldVersion, newVersion);
          },
        ),
      );

      final currentVersion = await _database!.getVersion();
      AppLogger.info('✅ BD lista [versión $currentVersion / esperada $_databaseVersion]');
      _initialized = true;
      return true;
    } catch (e, st) {
      AppLogger.error('❌ Error al inicializar la base de datos', e, st);
      return false;
    }
  }

  static Future<Database> getDatabase() async {
    if (PlatformHelper.isWeb) {
      throw UnsupportedError('DatabaseIO no debe usarse en web.');
    }
    if (!_initialized || _database == null) {
      throw StateError('BD no inicializada. Llama a initializeDatabase() primero.');
    }
    return _database!;
  }

  static Future<void> _createSchema(Database db, int version) async {
    AppLogger.info('🧩 Creando schema inicial...');
    final allMigrations = MigrationRegistry.getAllMigrations();
    if (allMigrations.isEmpty) {
      throw Exception('No hay migraciones registradas (debe existir Migration1Initial).');
    }

    for (final migration in allMigrations) {
      AppLogger.info('➡ Ejecutando migración ${migration.version}: ${migration.description}');
      try {
        await migration.createSchema(db);
      } on UnimplementedError {
        AppLogger.warning('Migración ${migration.version} usa up() en lugar de createSchema');
        await migration.up(db);
      }
    }
    AppLogger.info('✅ Schema creado correctamente.');
  }

  static Future<void> _migrateDatabase(Database db, int oldVersion, int newVersion) async {
    final migrations = MigrationRegistry.getMigrationsForRange(oldVersion, newVersion);
    if (migrations.isEmpty) {
      AppLogger.info('🔸 No hay migraciones necesarias.');
      return;
    }

    for (final migration in migrations) {
      AppLogger.info('🚀 Aplicando migración ${migration.version}: ${migration.description}');
      try {
        await migration.up(db);
        AppLogger.info('✅ Migración ${migration.version} aplicada.');
      } catch (e, st) {
        AppLogger.error('❌ Error aplicando migración ${migration.version}', e, st);
        rethrow;
      }
    }
  }

  static Future<T> withDatabase<T>(Future<T> Function(Database db) op) async {
    try {
      final db = await getDatabase();
      return await op(db);
    } catch (e, st) {
      AppLogger.error('⚠️ Error en operación de base de datos', e, st);
      rethrow;
    }
  }

  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      AppLogger.info('📕 Base de datos cerrada correctamente.');
    }
  }
}


