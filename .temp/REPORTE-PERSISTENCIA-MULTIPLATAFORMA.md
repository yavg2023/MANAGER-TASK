# Reporte: Alineación de Persistencia Multiplataforma con Usuarios Reales

## 📋 Resumen Ejecutivo

Este reporte analiza el problema de alineación entre el uso de **SharedPreferences (Web)** vs **SQLite (Mobile/Desktop)** cuando el sistema implemente usuarios reales con login, según los requerimientos de `app-scope.mdc` y el análisis de gaps funcionales.

**Fecha**: 2024-11-03  
**Estado**: ⚠️ Requiere acción

---

## 🔍 Análisis del Problema Actual

### Estado Actual de Implementación

1. **Sistema de Servicios Condicionales**:
   - ✅ Usa conditional exports (`task_service.dart`) para seleccionar implementación según plataforma
   - ✅ Web: `task_service_web.dart` → SharedPreferences (clave única `tasks_v1`)
   - ✅ Mobile/Desktop: `task_service_io.dart` → SQLite (tabla `tasks`)
   - ✅ Provider usa abstracción `TaskService` sin conocer la implementación

2. **Problema Identificado**:
   - ❌ **SharedPreferences en Web almacena datos globales del navegador**, no por usuario
   - ❌ Actualmente todos los usuarios en web compartirían las mismas tareas (clave `tasks_v1` es única)
   - ❌ No hay mecanismo para aislar datos por usuario en web
   - ⚠️ SQLite en mobile/desktop permite filtrar por `userId` (cuando se implemente), pero web no

### Requerimientos según app-scope.mdc

Según el documento de alcance:

1. **Módulo Security**:
   - Existe entidad `User` con `email`, `password`, `role`
   - Roles: `user` (acceso a módulo tasks), `admin` (acceso a backoffice)
   - Login autentica usuario y redirige a `/home`

2. **Módulo Tasks**:
   - **NOTA sobre comportamiento inicial**: "Mientras el módulo `security` no esté implementado, el `HomeScreen` muestra el dashboard de tareas con todas las tareas disponibles (sin filtrado por usuario)."
   - **Implementación futura**: "Una vez implementado el módulo `security`, el `HomeScreen` debe filtrar las tareas por el usuario autenticado según el rol."

3. **Filtrado por Usuario**:
   - Las tareas deben filtrarse por el usuario autenticado (rol `user`)
   - Solo el rol `admin` puede ver todas las tareas (módulo backoffice)

### Gaps Identificados en GAP-ANALISIS-MODULO-TASKS.md

El gap #10 menciona:
- ⚠️ Comportamiento temporal correcto: muestra todas las tareas (sin filtrado)
- ❌ No hay preparación para integrar filtrado por usuario cuando exista el módulo `security`
- **Implementación futura**: Filtrar tareas por usuario autenticado en el servicio

---

## 🎯 Problema Central

### Escenario Post-Implementación de Security

**Situación esperada**:
- Usuario A hace login → ve solo sus tareas
- Usuario B hace login → ve solo sus tareas
- Admin hace login → ve todas las tareas (backoffice)

**Problema con SharedPreferences actual**:
```
Web (SharedPreferences):
- Clave única: 'tasks_v1'
- Valor: JSON array con TODAS las tareas
- ❌ No hay aislamiento por usuario
- ❌ Usuario A puede ver/modificar tareas de Usuario B
- ❌ Si usuario A y B usan el mismo navegador, comparten datos
```

**SQLite (Mobile/Desktop) - Futuro**:
```
SQLite:
- Tabla: tasks (id, title, description, completed, createdAt, userId)
- Consulta: SELECT * FROM tasks WHERE userId = ? AND ...
- ✅ Aislamiento por usuario con WHERE clause
- ✅ Cada usuario ve solo sus tareas
```

### Riesgos Identificados

1. **Seguridad**:
   - 🔴 **ALTO**: Usuarios pueden ver/modificar tareas de otros usuarios
   - 🔴 Violación de privacidad de datos
   - 🔴 No cumple principio de mínima exposición

2. **Funcionalidad**:
   - 🔴 No se puede filtrar por usuario en web
   - 🔴 Backoffice no puede funcionar correctamente en web (vería todas las tareas mezcladas)

3. **Experiencia de Usuario**:
   - 🟡 Usuarios confundidos al ver tareas que no son suyas
   - 🟡 Imposibilidad de usar múltiples cuentas en el mismo navegador

---

## 💡 Soluciones Propuestas

### Opción 1: IndexedDB con Claves por Usuario (Recomendada) ⭐

**Descripción**: Migrar de SharedPreferences a IndexedDB usando claves basadas en userId.

**Implementación**:
- Usar `package:shared_preferences` NO es adecuado (solo clave-valor global)
- Usar `package:indexed_db` o implementación custom con IndexedDB nativo
- Estructura: `tasks_user_${userId}` como clave
- O mejor: IndexedDB con objeto store que tenga índice `userId`

**Ventajas**:
- ✅ Aislamiento real por usuario
- ✅ Permite múltiples usuarios en el mismo navegador
- ✅ Compatible con arquitectura actual (cambiar solo `task_service_web.dart`)
- ✅ IndexedDB es más robusto que SharedPreferences para datos estructurados
- ✅ Permite consultas/filtrados más eficientes

**Desventajas**:
- ⚠️ Requiere cambio de librería (migrar de SharedPreferences)
- ⚠️ IndexedDB tiene API más compleja que SharedPreferences

**Archivos afectados**:
- `lib/services/tasks/task_service_web.dart` - Reescritura completa usando IndexedDB
- Posible nueva dependencia: `package:indexed_db` o implementación manual

**Esfuerzo**: 🟡 MEDIO - Requiere reescribir servicio web pero mantiene abstracción

---

### Opción 2: SharedPreferences con Claves Dinámicas por Usuario

**Descripción**: Mantener SharedPreferences pero usar claves dinámicas basadas en userId.

**Implementación**:
- Cambiar clave de `tasks_v1` a `tasks_user_${userId}_v1`
- Obtener `userId` del sistema de autenticación (cuando exista)
- Cada usuario tiene su propia clave en SharedPreferences

**Ventajas**:
- ✅ Aislamiento por usuario
- ✅ No requiere cambiar librería
- ✅ Cambios mínimos en código actual
- ✅ Compatible con arquitectura actual

**Desventajas**:
- ⚠️ SharedPreferences sigue siendo limitado (solo strings, no relaciones)
- ⚠️ No permite consultas complejas eficientes
- ⚠️ Limitado a almacenamiento de strings (JSON serializado)
- ⚠️ Puede tener problemas de rendimiento con muchas tareas por usuario

**Archivos afectados**:
- `lib/services/tasks/task_service_web.dart` - Modificar para usar clave dinámica
- Provider o servicio de autenticación debe proveer `userId` al servicio

**Esfuerzo**: 🟢 BAJO - Cambios mínimos, solo modificar clave

---

### Opción 3: Backend API con Base de Datos Remota (No recomendada para este alcance)

**Descripción**: Crear backend API que maneje persistencia centralizada.

**Ventajas**:
- ✅ Datos sincronizados entre dispositivos
- ✅ Aislamiento perfecto por usuario
- ✅ Escalabilidad

**Desventajas**:
- ❌ Fuera del alcance actual (solo local storage)
- ❌ Requiere servidor backend
- ❌ Complejidad adicional significativa
- ❌ No alineado con requerimientos actuales (app local)

**Esfuerzo**: 🔴 ALTO - Requiere arquitectura completamente nueva

---

## 🎯 Recomendación Final

### Recomendación: **Opción 2 (SharedPreferences con Claves Dinámicas)** - Corto Plazo

**Para implementación inmediata**:
1. Modificar `task_service_web.dart` para usar claves dinámicas basadas en userId
2. Agregar parámetro `userId` a métodos del servicio (o obtenerlo de contexto de autenticación)
3. Cambiar clave de `'tasks_v1'` a `'tasks_user_${userId}_v1'`

**Razón**: 
- Esfuerzo mínimo para resolver el problema de seguridad
- Compatible con arquitectura actual
- Permite avanzar con implementación de security sin bloqueos

### Recomendación: **Opción 1 (IndexedDB)** - Mediano Plazo

**Para evolución futura**:
1. Cuando se requieran funcionalidades más avanzadas (búsquedas complejas, índices)
2. Migrar a IndexedDB manteniendo la misma abstracción `TaskService`
3. IndexedDB es más apropiado para datos estructurados con relaciones

**Razón**:
- Mejor rendimiento para grandes volúmenes de datos
- Permite consultas más eficientes
- Más robusto para estructuras complejas

---

## 📝 Plan de Implementación Recomendado

### Fase 1: Preparación Inmediata (Con Security Module)

**Objetivo**: Aislar datos por usuario usando SharedPreferences con claves dinámicas.

**Pasos**:
1. **Modificar TaskService Web para recibir userId**:
   ```dart
   // task_service_web.dart
   class TaskService {
     final int? userId; // Agregar campo
     
     TaskService({this.userId}); // Constructor
     
     String get _key => 'tasks_user_${userId ?? 'guest'}_v1'; // Clave dinámica
   }
   ```

2. **Modificar Provider para pasar userId**:
   ```dart
   // task_provider.dart
   class TaskProvider {
     final TaskService _taskService;
     
     TaskProvider({int? userId}) 
       : _taskService = TaskService(userId: userId);
   }
   ```

3. **Obtener userId del contexto de autenticación**:
   - Cuando exista `AuthProvider` o similar
   - Pasar `userId` del usuario autenticado al `TaskProvider`
   - Si no hay usuario (guest), usar `null` o `'guest'`

**Archivos a modificar**:
- `lib/services/tasks/task_service_web.dart`
- `lib/providers/tasks/task_provider.dart`
- `lib/main.dart` o donde se inicialice `TaskProvider` (cuando exista AuthProvider)

**Consideraciones**:
- ⚠️ Requiere que el módulo `security` esté implementado para obtener `userId`
- ⚠️ Para pruebas sin security, usar `userId: null` o `userId: 0`

### Fase 2: Actualización de SQLite (Paralelo)

**Objetivo**: Preparar SQLite para filtrar por userId cuando se implemente security.

**Pasos**:
1. **Agregar columna `userId` a tabla `tasks`**:
   - Crear migración: `migration_3_add_user_id.dart`
   - Agregar columna `userId INTEGER` a tabla tasks
   - Para tareas existentes, asignar `userId = NULL` (o usuario por defecto)

2. **Modificar queries para filtrar por userId**:
   ```dart
   // task_service_io.dart
   Future<List<Task>> loadTasks({int? userId}) async {
     return await DatabaseHelper.withDatabase((db) async {
       final where = userId != null ? 'userId = ?' : null;
       final whereArgs = userId != null ? [userId] : null;
       final res = await db.query('tasks', 
         where: where, 
         whereArgs: whereArgs,
         orderBy: 'id DESC'
       );
       return res.map((r) => Task.fromMap(r)).toList();
     });
   }
   ```

3. **Agregar userId al crear tareas**:
   ```dart
   Future<Task> createTask(String title, String description, {int? userId}) async {
     // ... validaciones ...
     final id = await db.insert('tasks', {
       'title': title.trim(),
       'description': description.trim(),
       'completed': 0,
       'userId': userId, // Agregar userId
       // ... otros campos
     });
   }
   ```

**Archivos a modificar**:
- `lib/models/tasks/task.dart` - Agregar campo `userId` (opcional)
- `lib/utils/migrations/migration_3_add_user_id.dart` - Nueva migración
- `lib/services/tasks/task_service_io.dart` - Filtrar por userId
- `lib/providers/tasks/task_provider.dart` - Pasar userId al servicio

### Fase 3: Migración Futura a IndexedDB (Opcional)

**Cuando sea necesario**:
- Si SharedPreferences muestra limitaciones de rendimiento
- Si se requieren consultas más complejas
- Si se necesita sincronización offline más robusta

**Implementación**:
- Mantener abstracción `TaskService`
- Reescribir solo `task_service_web.dart` usando IndexedDB
- El provider no requiere cambios (misma interfaz)

---

## ✅ Criterios de Aceptación

### Para Fase 1 (SharedPreferences con Claves Dinámicas)

- [ ] `task_service_web.dart` usa claves dinámicas basadas en userId
- [ ] Cada usuario en web tiene sus tareas aisladas
- [ ] Múltiples usuarios pueden usar la misma aplicación web sin conflictos
- [ ] El provider recibe userId del contexto de autenticación
- [ ] Si no hay usuario autenticado, usa clave 'guest' o similar

### Para Fase 2 (SQLite con userId)

- [ ] Tabla `tasks` tiene columna `userId INTEGER`
- [ ] Migración automática agrega columna a BD existente
- [ ] Queries filtran por userId cuando está disponible
- [ ] Tareas se crean con userId del usuario autenticado
- [ ] Backoffice puede consultar todas las tareas (sin filtro userId para admin)

---

## 🔄 Compatibilidad con Requerimientos

### Alineación con app-scope.mdc

- ✅ **Filtrado por usuario**: Implementado con userId en clave (web) y WHERE clause (SQLite)
- ✅ **Rol user**: Ve solo sus tareas (filtro por userId)
- ✅ **Rol admin**: Ve todas las tareas (sin filtro userId en backoffice)
- ✅ **Comportamiento temporal**: Si no hay userId, mostrar todas las tareas (compatibilidad hacia atrás)

### Alineación con GAP-ANALISIS-MODULO-TASKS.md

- ✅ **Gap #10**: Resuelto - Preparación para filtrado por usuario implementada
- ✅ **Comportamiento inicial**: Documentado - Muestra todas las tareas hasta que exista userId
- ✅ **Implementación futura**: Estructura lista para integrar con módulo security

---

## 📊 Resumen de Impacto

| Aspecto | Estado Actual | Después de Fase 1 | Después de Fase 2 |
|---------|---------------|-------------------|-------------------|
| **Aislamiento por usuario (Web)** | ❌ No | ✅ Sí (claves dinámicas) | ✅ Sí |
| **Aislamiento por usuario (Mobile)** | ⚠️ N/A (sin security) | ⚠️ N/A (sin security) | ✅ Sí (WHERE userId) |
| **Seguridad de datos** | 🔴 Vulnerable | 🟢 Seguro | 🟢 Seguro |
| **Backoffice funcional (Web)** | ❌ No | ✅ Sí | ✅ Sí |
| **Compatibilidad hacia atrás** | - | ✅ Sí | ✅ Sí (migración automática) |
| **Esfuerzo de implementación** | - | 🟢 Bajo | 🟡 Medio |

---

## 🎯 Conclusión

**Problema identificado**: SharedPreferences con clave única no permite aislamiento por usuario, violando seguridad cuando se implemente login real.

**Solución recomendada**: 
1. **Corto plazo**: Modificar `task_service_web.dart` para usar claves dinámicas `tasks_user_${userId}_v1`
2. **Mediano plazo**: Agregar columna `userId` a SQLite y filtrar en queries
3. **Futuro**: Considerar migración a IndexedDB si se requieren funcionalidades avanzadas

**Prioridad**: 🔴 ALTA - Debe implementarse junto con el módulo `security` para garantizar seguridad de datos.

---

**Fecha de creación**: 2024-11-03  
**Última actualización**: 2024-11-03  
**Versión**: 1.0

