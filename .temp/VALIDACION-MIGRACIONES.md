# Guía de Validación - Sistema de Migraciones

## 📋 Objetivo
Este documento describe métodos prácticos para validar que el sistema de migraciones funciona correctamente después de implementar el Plan 0004.

## ✅ Validaciones Recomendadas

### Método 1: Validación por Logs (Recomendado para inicio rápido)

**Pasos**:
1. Ejecutar la aplicación: `flutter run`
2. Observar los logs en la consola al iniciar
3. Buscar los siguientes mensajes de `AppLogger`:

**Para BD nueva (primera vez)**:
```
[INFO] Inicializando base de datos...
[INFO] Creando schema de base de datos (versión 1)...
[INFO] Ejecutando createSchema de migración versión 1: Schema inicial de la base de datos
[INFO] Creando schema inicial de base de datos (versión 1)...
[INFO] Schema inicial creado exitosamente: tabla tasks
[INFO] Schema creado exitosamente
[INFO] Base de datos inicializada: [ruta] (versión 1)
```

**Para BD existente (sin cambios de versión)**:
```
[INFO] Inicializando base de datos...
[INFO] Base de datos inicializada: [ruta] (versión 1)
```

**Criterios de éxito**:
- ✅ No hay errores en los logs
- ✅ Aparece el mensaje "Schema inicial creado exitosamente" si es BD nueva
- ✅ La versión reportada es `1` (actual)

---

### Método 2: Validación por Consulta Directa a BD

**Pasos**:
1. Ejecutar la aplicación al menos una vez para crear la BD
2. Encontrar la ubicación de la BD:
   - Desktop: `getDatabasesPath()` generalmente retorna un directorio temporal
   - Buscar en logs el mensaje: `Base de datos inicializada: [ruta]`
3. Verificar schema usando SQLite:

**En terminal** (si tienes `sqlite3` instalado):
```bash
# Buscar el archivo tasks.db
# En macOS/Desktop suele estar en un directorio temporal
# Ejemplo: /var/folders/.../tasks.db

sqlite3 [ruta_a_tasks.db]

# Dentro de sqlite3:
.schema tasks
# Debe mostrar:
# CREATE TABLE tasks (
#   id INTEGER PRIMARY KEY AUTOINCREMENT,
#   title TEXT NOT NULL,
#   description TEXT NOT NULL,
#   completed INTEGER NOT NULL
# );

# Verificar versión de la BD:
PRAGMA user_version;
# Debe retornar: 1

# Verificar estructura de tabla:
PRAGMA table_info(tasks);
# Debe mostrar 4 columnas: id, title, description, completed
```

**Criterios de éxito**:
- ✅ Tabla `tasks` existe con la estructura correcta
- ✅ `PRAGMA user_version` retorna `1`
- ✅ Todas las columnas esperadas están presentes

---

### Método 3: Validación Funcional (CRUD Básico)

**Pasos**:
1. Ejecutar la aplicación: `flutter run`
2. Crear una tarea nueva desde la UI
3. Verificar que se guarda correctamente
4. Editar la tarea
5. Marcar como completada
6. Eliminar la tarea

**Criterios de éxito**:
- ✅ Todas las operaciones CRUD funcionan sin errores
- ✅ No aparecen errores relacionados con estructura de BD en los logs
- ✅ Los datos se persisten correctamente

---

### Método 4: Validación de Migración Automática (Simular Versión 2)

**Propósito**: Verificar que `onUpgrade` funciona cuando aumenta la versión.

**⚠️ Nota**: Este método requiere crear temporalmente una migración versión 2 de prueba.

**Pasos**:
1. Crear archivo `migration_2_test.dart` temporal:

```dart
// lib/utils/migrations/migration_2_test.dart
import 'package:sqflite/sqflite.dart';
import '../logger.dart';
import 'migration.dart';

/// Migración de prueba versión 2: Agregar columna de prueba.
class Migration2Test extends Migration {
  @override
  int get version => 2;
  
  @override
  String get description => 'Migración de prueba - Agregar columna test';
  
  @override
  Future<void> up(Database db) async {
    AppLogger.info('Migración de prueba versión 2 ejecutándose...');
    // No hacer cambios reales, solo loggear
    AppLogger.info('Migración de prueba completada');
  }
  
  @override
  Future<void> createSchema(Database db) async {
    throw UnimplementedError('Solo migración de prueba');
  }
}
```

2. Registrar temporalmente en `migration_registry.dart`:
```dart
static final List<Migration> _migrations = [
  Migration1Initial(),
  Migration2Test(), // Temporal
];
```

3. **Ejecutar app con BD existente** (versión 1):
   - La app debe detectar que la BD es versión 1 y necesita migrar a versión 2
   - Buscar en logs:
```
[INFO] Migrando base de datos de versión 1 a 2...
[INFO] Aplicando migración versión 2: Migración de prueba - Agregar columna test
[INFO] Migración de prueba versión 2 ejecutándose...
[INFO] Migración de prueba completada
[INFO] Migración versión 2 completada exitosamente
[INFO] Migración completada exitosamente (versión 1 → 2)
```

4. **Verificar versión actualizada**:
```sql
PRAGMA user_version;
-- Debe retornar: 2
```

5. **Limpiar**: Eliminar `Migration2Test` del registro y archivo

**Criterios de éxito**:
- ✅ `onUpgrade` se ejecuta automáticamente
- ✅ Los logs muestran el proceso de migración
- ✅ La versión de la BD se actualiza correctamente

---

### Método 5: Validación de Idempotencia

**Propósito**: Verificar que las migraciones son seguras si se ejecutan múltiples veces.

**Pasos**:
1. Crear una BD nueva
2. Ejecutar la app (se crea schema inicial)
3. Cerrar la app completamente
4. Volver a ejecutar la app
5. Verificar que no hay errores al intentar crear tablas que ya existen

**Criterios de éxito**:
- ✅ No hay errores al reabrir la app
- ✅ Los logs no muestran intentos de crear tablas duplicadas
- ✅ La BD mantiene sus datos

---

## 🔍 Verificaciones Específicas por Escenario

### Escenario A: Primera Instalación (BD Nueva)

**Qué validar**:
- [ ] BD se crea en la ubicación correcta
- [ ] Schema inicial se crea correctamente (tabla `tasks`)
- [ ] Versión de BD es `1`
- [ ] Logs muestran proceso de creación exitoso
- [ ] No hay errores de compilación o runtime

**Cómo validar**: Método 1 (Logs) + Método 2 (Consulta directa)

---

### Escenario B: BD Existente Sin Cambios

**Qué validar**:
- [ ] La app abre sin intentar crear schema
- [ ] No se ejecuta `onCreate` ni `onUpgrade`
- [ ] Los datos existentes se mantienen
- [ ] Logs muestran solo inicialización, no creación

**Cómo validar**: Método 1 (Logs) + Método 3 (CRUD)

---

### Escenario C: Migración Automática (Cuando exista versión 2)

**Qué validar**:
- [ ] `onUpgrade` se ejecuta automáticamente
- [ ] Migraciones se ejecutan en orden (1→2)
- [ ] Versión de BD se actualiza correctamente
- [ ] Datos existentes se preservan (si aplica)
- [ ] Logs muestran proceso completo de migración

**Cómo validar**: Método 4 (Migración de prueba) - **Solo cuando se implemente versión 2**

---

## 📝 Checklist Rápido de Validación

Para validación rápida después del Plan 0004:

- [ ] **Compilación**: `flutter analyze` no muestra errores en archivos de migraciones
- [ ] **Logs al iniciar**: Verificar mensajes de `AppLogger` sobre inicialización
- [ ] **CRUD funciona**: Crear, leer, actualizar y eliminar tareas desde la UI
- [ ] **Sin errores**: No aparecen excepciones relacionadas con BD al usar la app
- [ ] **Estructura correcta**: La tabla `tasks` tiene los campos esperados (id, title, description, completed)

---

## 🧪 Script de Validación Manual (Opcional)

Si deseas automatizar la validación básica, puedes crear un script Dart simple:

```dart
// scripts/validate_migrations.dart
import 'package:sqflite/sqflite.dart';
import '../lib/utils/database_helper.dart';
import '../lib/utils/migrations/migration_registry.dart';

Future<void> main() async {
  print('=== Validación de Sistema de Migraciones ===\n');
  
  // 1. Verificar versión actual
  final version = MigrationRegistry.getLatestVersion();
  print('✓ Versión actual del sistema: $version');
  
  // 2. Verificar migraciones registradas
  final migrations = MigrationRegistry.getAllMigrations();
  print('✓ Migraciones registradas: ${migrations.length}');
  for (final m in migrations) {
    print('  - Versión ${m.version}: ${m.description}');
  }
  
  // 3. Inicializar BD (esto ejecutará onCreate si es nueva)
  print('\nInicializando base de datos...');
  final db = await DatabaseHelper.getDatabase();
  
  // 4. Verificar versión de BD
  final dbVersion = await db.getVersion();
  print('✓ Versión de base de datos: $dbVersion');
  
  // 5. Verificar estructura de tabla
  final tableInfo = await db.rawQuery('PRAGMA table_info(tasks)');
  print('✓ Columnas en tabla tasks: ${tableInfo.length}');
  for (final col in tableInfo) {
    print('  - ${col['name']}: ${col['type']}');
  }
  
  // 6. Cerrar BD
  await DatabaseHelper.closeDatabase();
  
  print('\n=== Validación completada ===');
}
```

Ejecutar con:
```bash
dart run scripts/validate_migrations.dart
```

---

## ⚠️ Notas Importantes

1. **Ubicación de BD**: La BD se crea automáticamente en `getDatabasesPath()`, que varía según plataforma
2. **Logs**: Todos los mensajes importantes se loggean con `AppLogger`, buscar `[INFO]` y `[ERROR]`
3. **Versión**: La versión se almacena internamente en SQLite usando `PRAGMA user_version`
4. **Multiplataforma**: Validar en desktop Y móvil (si aplica) para asegurar compatibilidad
5. **Datos existentes**: Si tienes una BD antigua sin sistema de migraciones, elimínala manualmente para probar desde cero

---

## 🚀 Próximos Pasos después de Validar

Una vez validado que el sistema funciona:
1. Implementar Plan 0005: Agregar migración versión 2 para `createdAt`
2. Verificar que la migración de versión 1→2 se ejecuta automáticamente
3. Continuar con los siguientes planes

