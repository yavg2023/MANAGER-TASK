# Análisis de Gap Funcional - Módulo Tasks

## Fecha del Análisis
Actualizado: 2024

## Objetivo
Identificar las funcionalidades faltantes en el módulo `tasks` según el alcance funcional definido en `app-scope.mdc` después del refactor estructural (Plan 0001).

---

## Estado Actual vs Requerimientos según app-scope.mdc

### ✅ Funcionalidades Implementadas

1. **CRUD Básico**:
   - ✅ Crear tarea (`createTask`)
   - ✅ Actualizar tarea (`updateTask`)
   - ✅ Eliminar tarea (`deleteTask`)
   - ✅ Cargar tareas (`loadTasks`)

2. **UI Básico**:
   - ✅ Pantalla de detalle (`TaskDetailScreen`) - Compartida para crear/editar
   - ✅ Acceso desde dashboard para crear (FloatingActionButton)
   - ✅ Campo título editable
   - ✅ Campo descripción editable
   - ✅ Checkbox para toggle de completed en dashboard

---

## ❌ Gaps Funcionales Identificados

### 1. Campo `createdAt` Faltante (🔴 ALTA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- Task debe tener campo `createdAt` (timestamp UTC)
- Debe almacenarse en UTC en base de datos
- Debe mostrarse traducido al locale del usuario en pantalla
- Es visible pero no editable

**Estado Actual**:
- ❌ Campo `createdAt` no existe en modelo `Task` (solo: id, title, description, completed)
- ❌ Columna `createdAt` no existe en schema de BD (`database_helper.dart`)
- ❌ No se guarda `createdAt` al crear tarea (`task_service_io.dart`)
- ❌ No se muestra `createdAt` en ninguna UI
- ❌ No hay migración para agregar columna a BD existente

**Archivos afectados**:
- `lib/models/tasks/task.dart` - Agregar campo `createdAt` (DateTime?)
- `lib/utils/database_helper.dart` - Agregar columna `createdAt INTEGER` al schema
- `lib/services/tasks/task_service_io.dart` - Guardar `createdAt` al crear
- `lib/services/tasks/task_service_web.dart` - Guardar `createdAt` al crear
- `lib/screens/tasks/task_detail_screen.dart` - Mostrar `createdAt` (solo lectura)
- `lib/screens/home_screen.dart` - Mostrar `createdAt` en tarjetas (opcional)

**Impacto**: 🔴 ALTA - Requerimiento explícito del alcance funcional

---

### 2. ~~Dashboard Tipo Kanban No Implementado~~ ✅ NO ES GAP

**Actualización**: Según decisión del usuario, el dashboard se mantiene como lista simple, no kanban. El `app-scope.mdc` ha sido actualizado para reflejar esto.

**Estado Actual**:
- ✅ Dashboard muestra lista simple (`ListView.builder` con `Card` y `ListTile`) - **Correcto según nuevo alcance**
- ✅ Vista de lista lineal en `home_screen.dart` - **Correcto según nuevo alcance**

**Nota**: Este gap ha sido eliminado del análisis ya que el comportamiento actual es el requerido.

---

### 3. Validación de Tarea Completada No Implementada (🔴 ALTA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- Una tarea con `completed = true` **NO puede ser actualizada**
- Para poder actualizar una tarea completada, primero se debe desmarcar el estado completado (cambiar a `completed = false`)

**Estado Actual**:
- ❌ No hay validación que impida editar tarea completada
- ❌ `TaskDetailScreen` permite editar tarea completada sin restricción
- ❌ No hay mensaje de advertencia o bloqueo cuando se intenta editar tarea completada
- ❌ El servicio `updateTask` no valida si la tarea está completada antes de permitir actualización
- ❌ El provider `updateTask` no valida antes de llamar al servicio

**Implementación requerida**:
- Validación en `TaskProvider.updateTask()`: verificar `completed == true` y bloquear
- Validación en `TaskService.updateTask()`: verificar `completed == true` y bloquear
- Bloqueo de UI en `TaskDetailScreen`: deshabilitar campos si `task.completed == true`
- Mostrar mensaje informativo si se intenta editar tarea completada

**Archivos afectados**:
- `lib/providers/tasks/task_provider.dart` - Validación antes de actualizar
- `lib/services/tasks/task_service_io.dart` - Validación en servicio
- `lib/services/tasks/task_service_web.dart` - Validación en servicio
- `lib/screens/tasks/task_detail_screen.dart` - Bloqueo de UI si completed

**Impacto**: 🔴 ALTA - Regla de negocio explícita

---

### 4. Campo `completed` No Editable en TaskDetailScreen (🟡 MEDIA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- `TaskDetailScreen` debe permitir editar título, descripción y **estado de completado** de la tarea

**Estado Actual**:
- ❌ `TaskDetailScreen` NO muestra campo para editar `completed`
- ❌ Solo permite editar título y descripción
- ❌ El estado completado solo se puede cambiar desde el dashboard (checkbox en `home_screen.dart`)
- ❌ No hay Checkbox o Switch para `completed` en `TaskDetailScreen`

**Implementación requerida**:
- Agregar Checkbox o Switch en `TaskDetailScreen` para campo `completed`
- Incluir `completed` en el `changes` Map cuando se actualiza
- Respetar validación: si `completed == true`, bloquear edición (ver gap #3)

**Archivos afectados**:
- `lib/screens/tasks/task_detail_screen.dart` - Agregar campo completed editable

**Impacto**: 🟡 MEDIA - Funcionalidad requerida para edición completa

---

### 5. Diálogo de Confirmación en Delete Faltante (🟡 MEDIA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- Al hacer clic en el icono de eliminar, se debe mostrar un **diálogo de confirmación** al usuario solicitando confirmación de la eliminación
- Solo después de confirmar, se realiza la eliminación física de la tarea en la base de datos

**Estado Actual**:
- ❌ Eliminación se ejecuta directamente sin confirmación
- ❌ No hay `showDialog` o similar para confirmar eliminación
- ❌ Usuario puede eliminar accidentalmente sin confirmar
- ❌ `deleteTask()` en `TaskProvider` llama directamente al servicio sin UI de confirmación
- ❌ `home_screen.dart` llama `provider.deleteTask()` directamente desde PopupMenuButton sin confirmación
- ❌ No hay validación que prevenga eliminaciones accidentales

**Implementación requerida**:
- Mostrar `showDialog` con confirmación antes de eliminar (cuando se implemente el icono de eliminar - ver gap #7)
- El diálogo debe tener botones "Cancelar" y "Eliminar" (o "Confirmar")
- El diálogo debe mostrar mensaje claro como "¿Está seguro de que desea eliminar esta tarea?"
- Solo después de confirmar, ejecutar `provider.deleteTask()`
- El diálogo debe implementarse donde se invoque la acción de eliminar (icono directo o donde corresponda)

**Archivos afectados**:
- `lib/screens/home_screen.dart` - Agregar `showDialog` antes de llamar `deleteTask()` (integrado con gap #7)
- `lib/widgets/tasks/task_list.dart` - Agregar `showDialog` si se usa este widget para eliminar

**Nota**: Este gap está relacionado con el gap #7 (icono de eliminar). El diálogo de confirmación debe implementarse junto con el icono directo de eliminar.

**Impacto**: 🟡 MEDIA - Requerimiento explícito según app-scope.mdc. Mejora UX y previene eliminaciones accidentales.

---

### 6. Acceso UPDATE No Cumple Requerimiento de UI (🟡 MEDIA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- **UPDATE**: Al hacer clic en una tarjeta de tarea en el dashboard (lista de tarjetas), se abre `TaskDetailScreen` con los datos precargados

**Estado Actual**:
- ❌ El clic en tarjeta NO abre `TaskDetailScreen` directamente
- ❌ Para editar, se debe abrir PopupMenuButton y seleccionar "Editar"
- ❌ No hay `onTap` en `ListTile` o `Card` que abra `TaskDetailScreen` directamente
- ❌ El flujo actual requiere: Clic en tarjeta → nada, luego PopupMenuButton → Editar → `TaskDetailScreen`
- ⚠️ El requerimiento indica que el clic directo en tarjeta debe abrir `TaskDetailScreen` para editar

**Implementación requerida**:
- Agregar `onTap` al `ListTile` o `Card` en `home_screen.dart` (o en el widget de lista si se usa `TaskList`)
- Al hacer tap en tarjeta, navegar a `TaskDetailScreen` con argumentos `{'task': t}`
- El PopupMenuButton puede mantenerse solo para DELETE o eliminarse si el icono de eliminar se implementa directamente (ver gap #7)

**Archivos afectados**:
- `lib/screens/home_screen.dart` - Agregar `onTap` a `ListTile` o `Card`
- `lib/widgets/tasks/task_list.dart` - Si se usa este widget, agregar `onTap` aquí también

**Impacto**: 🟡 MEDIA - Requerimiento explícito de UX según app-scope.mdc. Mejora la experiencia de usuario al permitir acceso directo a edición con un clic.

---

### 7. Acceso DELETE No Cumple Requerimiento de UI (🟡 MEDIA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- Cada tarjeta de tarea en el dashboard (lista de tarjetas) debe tener un **icono de eliminar** (normalmente un botón con icono de basura/papelera)
- Al hacer clic en este icono, se debe mostrar un diálogo de confirmación al usuario solicitando confirmación de la eliminación

**Estado Actual**:
- ❌ Eliminar está en menú contextual (PopupMenuButton) en lugar de icono directo
- ❌ No hay icono visible de eliminar directamente en la tarjeta
- ❌ El usuario debe abrir menú contextual (PopupMenuButton) para eliminar
- ❌ No hay diálogo de confirmación (ver también gap #5)

**Implementación requerida**:
- Agregar icono directo de eliminar (IconButton con Icons.delete) en `trailing` de `ListTile`
- El icono debe estar visible directamente en cada tarjeta, no oculto en menú
- Reemplazar o eliminar PopupMenuButton (si solo tenía eliminar) o mantenerlo solo para otras acciones futuras
- El icono debe mostrar diálogo de confirmación antes de eliminar (ver gap #5)
- Integrar el diálogo de confirmación con la acción de eliminar

**Archivos afectados**:
- `lib/screens/home_screen.dart` - Reemplazar PopupMenuButton con IconButton directo de eliminar
- `lib/widgets/tasks/task_list.dart` - Si se usa este widget, actualizar también aquí

**Impacto**: 🟡 MEDIA - Requerimiento explícito de UI según app-scope.mdc. El icono visible mejora la UX y previene confusiones.

---

### 8. Sistema de Migración Modular para Agregar Columnas (🔴 ALTA PRIORIDAD - si se implementa createdAt)

**Análisis del sistema actual**:
- `database_helper.dart` tiene `version: 1` definida pero **NO tiene `onUpgrade`**
- Si cambiamos el schema (ej: agregar `createdAt`), las BD existentes **NO se actualizarán automáticamente**
- Si aumentamos la versión sin `onUpgrade`, sqflite lanzará un error
- No existe estructura modular para organizar migraciones

**Impacto de agregar `createdAt`**:
- Al agregar columna `createdAt` a tabla existente, necesitamos migración automática
- Las tareas existentes necesitarán un `createdAt` por defecto (timestamp actual al momento de la migración)

**Decisión técnica**:
Dado que la BD es local y los datos son tolerables de perder, pero **necesitamos actualización automática**, se implementará un sistema modular de migraciones según la rule `database-versioning.mdc`:
- Crear estructura de directorios `lib/utils/migrations/` para organizar migraciones
- Crear clase base `Migration` en `migrations/migration.dart`
- Crear `MigrationRegistry` en `migrations/migration_registry.dart` para registro centralizado
- Crear `Migration1Initial` en `migrations/migration_1_initial.dart` para schema inicial
- Crear `Migration2AddCreatedAt` en `migrations/migration_2_add_created_at.dart` para agregar columna `createdAt`
- Actualizar `DatabaseHelper` para usar `MigrationRegistry` y ejecutar migraciones automáticamente

**Estado Actual**:
- ❌ No existe estructura de migraciones (`lib/utils/migrations/`)
- ❌ No hay clase base `Migration`
- ❌ No hay `MigrationRegistry`
- ❌ No hay `onUpgrade` callback en `database_helper.dart`
- ❌ Schema está fijo en versión 1 sin capacidad de migración automática
- ❌ Si se agrega `createdAt` sin migración, las tablas existentes no tendrán la columna y causará errores

**Implementación requerida** (según `database-versioning.mdc`):

1. **Crear estructura de directorios**:
   - `lib/utils/migrations/` - Carpeta para migraciones

2. **Crear clase base**:
   - `lib/utils/migrations/migration.dart` - Clase abstracta `Migration` con métodos `version`, `description`, `up()`, `createSchema()`

3. **Crear registro de migraciones**:
   - `lib/utils/migrations/migration_registry.dart` - Clase `MigrationRegistry` que registra todas las migraciones y permite obtenerlas por rango de versiones

4. **Crear migración inicial**:
   - `lib/utils/migrations/migration_1_initial.dart` - Clase `Migration1Initial` que extiende `Migration` y crea el schema base (tabla `tasks` sin `createdAt`)

5. **Crear migración para `createdAt`**:
   - `lib/utils/migrations/migration_2_add_created_at.dart` - Clase `Migration2AddCreatedAt` que extiende `Migration`:
     - `version = 2`
     - `description = 'Agregar columna createdAt a tabla tasks'`
     - `up()`: Agrega columna `createdAt INTEGER NOT NULL DEFAULT 0`, actualiza registros existentes con timestamp actual
     - `createSchema()`: Lanza `UnimplementedError` (no crea schema completo, solo modifica)

6. **Registrar migraciones**:
   - En `migration_registry.dart`, agregar ambas migraciones a la lista `_migrations`:
     ```dart
     static final List<Migration> _migrations = [
       Migration1Initial(),
       Migration2AddCreatedAt(),
     ];
     ```

7. **Actualizar DatabaseHelper**:
   - Agregar `onUpgrade` callback que use `MigrationRegistry.getMigrationsForRange()`
   - Actualizar `_createSchema()` para usar `MigrationRegistry.getLatestMigration()` y construir schema completo
   - La versión se obtiene automáticamente de `MigrationRegistry.getLatestVersion()` (no se define manualmente)

**Archivos a crear**:
- `lib/utils/migrations/migration.dart`
- `lib/utils/migrations/migration_registry.dart`
- `lib/utils/migrations/migration_1_initial.dart`
- `lib/utils/migrations/migration_2_add_created_at.dart`

**Archivos a modificar**:
- `lib/utils/database_helper.dart` - Actualizar para usar `MigrationRegistry` y agregar `onUpgrade` callback

**Impacto**: 🔴 ALTA - Necesario para que el sistema actualice automáticamente el schema sin requerir acción manual del usuario. La estructura modular facilita el mantenimiento y la adición de futuras migraciones.

**Nota**: Este sistema sigue la estructura modular definida en `database-versioning.mdc`, que separa cada migración en su propio archivo y las registra centralmente. Esto facilita el mantenimiento y la escalabilidad. Si la migración falla, el usuario puede eliminar la BD manualmente y se recreará con el nuevo schema.

---

### 9. Ordenamiento y Filtrado No Implementado (🔴 ALTA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- **Ordenamiento por defecto**: Las tareas deben mostrarse ordenadas descendentemente por fecha de creación (`createdAt DESC`)
- **Scroll infinito**: La lista debe usar scroll infinito para cargar más tareas, no paginación tradicional
- **Ordenamiento configurable**: El usuario debe poder ordenar por:
  - Título (ascendente o descendente)
  - Fecha de creación (ascendente o descendente)
- **Filtrado**:
  - Por título: Campo de búsqueda con filtro LIKE/fragmento de texto
  - Por estado completado: Filtro para mostrar solo completadas, solo pendientes, o todas

**Estado Actual**:
- ❌ No hay ordenamiento por fecha de creación (actualmente ordena por `id DESC`)
- ❌ No hay scroll infinito implementado
- ❌ No hay opciones de ordenamiento configurable por el usuario
- ❌ No hay filtrado por título
- ❌ No hay filtrado por estado completado
- ❌ El servicio `loadTasks()` no acepta parámetros de ordenamiento ni filtrado
- ❌ El provider no expone métodos para cambiar ordenamiento o filtros

**Implementación requerida**:
- Agregar parámetros de ordenamiento en servicio: `orderBy` (título o createdAt), `orderDirection` (ASC/DESC)
- Agregar parámetros de filtrado en servicio: `titleFilter` (LIKE), `completedFilter` (true/false/null para todas)
- Implementar scroll infinito en `HomeScreen` usando `ListView.builder` con detección de scroll al final
- Agregar UI para selector de ordenamiento (DropdownButton o similar)
- Agregar campo de búsqueda por título (TextField con debounce)
- Agregar selector de filtro por estado completado (DropdownButton o ToggleButtons)
- Actualizar provider para manejar estado de ordenamiento y filtros
- Cargar más tareas cuando el usuario llegue al final del scroll

**Archivos afectados**:
- `lib/services/tasks/task_service_io.dart` - Agregar parámetros de ordenamiento y filtrado a `loadTasks()`
- `lib/services/tasks/task_service_web.dart` - Agregar parámetros de ordenamiento y filtrado a `loadTasks()`
- `lib/providers/tasks/task_provider.dart` - Agregar estado y métodos para ordenamiento y filtrado
- `lib/screens/home_screen.dart` - Implementar UI de filtros, ordenamiento y scroll infinito

**Impacto**: 🔴 ALTA - Requerimientos explícitos del alcance funcional

---

### 10. Comportamiento Inicial de HomeScreen - Filtrado por Usuario (🟡 MEDIA PRIORIDAD - FUTURA IMPLEMENTACIÓN)

**Requerimiento según app-scope.mdc**:
- El `HomeScreen` debe mostrar el dashboard de tareas del usuario autenticado una vez implementado el módulo `security`
- Debe filtrar las tareas por el usuario autenticado según el rol

**Estado Actual**:
- ⚠️ No existe módulo `security`, por lo tanto no hay usuarios autenticados
- ✅ Comportamiento temporal correcto: muestra todas las tareas (sin filtrado)
- ❌ No hay comentarios TODO indicando que falta lógica de autorización
- ❌ No hay preparación para integrar filtrado por usuario cuando exista el módulo `security`

**Implementación requerida (TEMPORAL)**:
- Agregar comentarios TODO en `home_screen.dart` indicando que se debe implementar lógica de autorización cuando exista módulo `security`
- Documentar que por el momento se muestran todas las tareas como comportamiento inicial
- Preparar estructura para recibir usuario autenticado cuando exista `security`

**Implementación futura (cuando exista módulo security)**:
- Filtrar tareas por usuario autenticado en el servicio
- El provider debe recibir el ID del usuario autenticado
- Solo mostrar tareas del usuario logueado (para rol `user`)

**Archivos afectados**:
- `lib/screens/home_screen.dart` - Agregar comentarios TODO sobre autorización
- `lib/providers/tasks/task_provider.dart` - Preparar para recibir userId cuando exista security
- `lib/services/tasks/task_service_io.dart` - Preparar método para filtrar por userId (futuro)

**Impacto**: 🟡 MEDIA - Comportamiento temporal correcto, pero debe documentarse para futura implementación

---

## Resumen de Gaps por Prioridad

### 🔴 Alta Prioridad (Bloqueantes para cumplir alcance funcional)
1. **Campo `createdAt` completo** (modelo, BD, migración automática modular, UI)
2. **Validación que tarea completada no se pueda editar** (servicio, provider, UI)
3. **Sistema de migración modular** (estructura de directorios, clase base, registro, migraciones individuales según `database-versioning.mdc`)
4. **Ordenamiento y filtrado** (ordenamiento por defecto, scroll infinito, ordenamiento configurable, filtros por título y estado)

### 🟡 Media Prioridad (Funcionalidades requeridas explícitamente)
5. **Campo `completed` editable en `TaskDetailScreen`**
6. **Diálogo de confirmación en delete**
7. **Acceso UPDATE: clic en tarjeta abre TaskDetailScreen directamente**
8. **Icono de eliminar directo visible en tarjeta** (reemplazar menú contextual)
9. **Documentación TODO para filtrado por usuario** (comportamiento inicial mientras no existe security)

---

## Notas Técnicas

- El código actual está bien estructurado según la nueva arquitectura modular ✅
- Los gaps son principalmente de funcionalidad, no de estructura ✅
- **Dashboard**: El dashboard se mantiene como **lista de tarjetas simple** (ListView con Cards), NO como kanban con columnas. Esta es la implementación correcta según el alcance funcional. ✅
- **TaskList**: Es un widget reutilizable para mostrar lista de tareas. Puede mantenerse para reutilización o usarse directamente en el dashboard.
- **TaskDetailScreen**: Es la pantalla compartida para crear y editar tareas, funciona correctamente pero necesita completarse con campo `completed` editable y validación.
- **HomeScreen - Comportamiento Inicial**: Mientras no existe el módulo `security`, el `HomeScreen` muestra todas las tareas disponibles. Esto es correcto temporalmente, pero debe documentarse con TODOs para futura implementación de autorización.
- **Scroll Infinito**: Debe implementarse usando detección de scroll en `ListView.builder` o usando `ScrollController` para cargar más tareas cuando se llegue al final.
- **Ordenamiento y Filtrado**: Deben implementarse a nivel de servicio (SQLite) y provider (estado), no solo en UI.
- **Migraciones de BD**: El sistema actual tiene `version: 1` pero NO tiene `onUpgrade`. Se implementará un sistema modular según `database-versioning.mdc` con estructura de directorios `lib/utils/migrations/`, clase base `Migration`, registro centralizado `MigrationRegistry`, y migraciones individuales en archivos separados. Se ejecuta automáticamente al abrir la BD, adecuado para una BD local donde perder datos es tolerable.
- Para `createdAt`, necesitar agregar soporte de fechas con formato UTC y traducción a locale (posiblemente usar `intl` package)
- Las validaciones deben implementarse tanto en servicio como en provider y UI

---

## Dependencias Potenciales

### Para `createdAt`:
- Manejo de fechas: Dart `DateTime` (nativo) o `intl` package para formateo según locale
- Migración de BD: implementar `onUpgrade` en sqflite

### Para Validaciones:
- No requiere dependencias externas, usar lógica nativa

---

## Próximos Pasos Recomendados

1. 🔴 Implementar sistema de migración modular (estructura `migrations/`, clase base, registro, migraciones según `database-versioning.mdc`)
2. 🔴 Implementar campo `createdAt` (modelo + BD + migración versión 2 + UI)
3. 🔴 Agregar validación de tarea completada (bloqueo de edición)
4. 🔴 Implementar ordenamiento y filtrado (orden por defecto, scroll infinito, ordenamiento configurable, filtros)
5. 🟡 Agregar campo `completed` editable en `TaskDetailScreen`
6. 🟡 Agregar diálogo de confirmación en delete
7. 🟡 Agregar `onTap` en tarjeta para editar directamente
8. 🟡 Agregar icono de eliminar directo visible en tarjeta
9. 🟡 Agregar comentarios TODO sobre autorización y filtrado por usuario en `HomeScreen`
