import 'package:sqflite/sqflite.dart';

/// Clase base abstracta para todas las migraciones de base de datos.
///
/// Cada migración debe extender esta clase e implementar los métodos requeridos.
/// Las migraciones permiten actualizar el schema de la base de datos de forma
/// automática cuando se realizan cambios en la estructura de datos.
abstract class Migration {
  /// Versión de la base de datos después de aplicar esta migración.
  ///
  /// Cada migración debe tener un número de versión único y secuencial.
  /// La versión inicial es 1, y cada cambio de schema incrementa la versión en 1.
  int get version;

  /// Descripción breve de lo que hace esta migración.
  ///
  /// Debe describir claramente los cambios que realiza (ej: "Agregar columna createdAt a tabla tasks").
  String get description;

  /// Aplica la migración a la base de datos.
  ///
  /// Este método debe contener toda la lógica para modificar el schema o datos.
  /// Se ejecuta automáticamente cuando la versión de la BD existente es menor
  /// que la versión de esta migración.
  ///
  /// **Importante**: Las migraciones deben ser idempotentes. Deben verificar el
  /// estado actual antes de aplicar cambios (ej: verificar si una columna ya existe).
  ///
  /// [db] - Instancia de la base de datos sobre la cual aplicar la migración
  Future<void> up(Database db);

  /// Crea el schema inicial para esta versión.
  ///
  /// Se usa cuando la BD se crea por primera vez desde cero.
  /// Debe crear todas las tablas con la estructura correspondiente a esta versión.
  ///
  /// **Nota**: Para migraciones que solo modifican tablas existentes (ej: agregar columnas),
  /// este método puede lanzar `UnimplementedError` ya que el schema inicial lo crea
  /// la migración de versión 1.
  ///
  /// [db] - Instancia de la base de datos sobre la cual crear el schema
  Future<void> createSchema(Database db);
}
