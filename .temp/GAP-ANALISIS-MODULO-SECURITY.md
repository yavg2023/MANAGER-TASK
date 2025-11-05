# Análisis de Gap Funcional - Módulo Security

## Fecha del Análisis
Actualizado: 2024

## Objetivo
Identificar las funcionalidades faltantes en el módulo `security` según el alcance funcional definido en `app-scope.mdc`. Este documento servirá para construir los planes de trabajo necesarios para implementar completamente el módulo de autenticación y autorización.

---

## Estado Actual vs Requerimientos según app-scope.mdc

### ✅ Funcionalidades Parcialmente Implementadas

1. **Pantalla de Login (Mock)**:
   - ⚠️ Existe `lib/screens/login_screen.dart` pero es solo un mock
   - ⚠️ Tiene campos de email y contraseña, pero no realiza autenticación real
   - ⚠️ Simula login con delay y redirige a `/home` sin validación
   - ❌ No hay validación de credenciales
   - ❌ No hay manejo de errores de autenticación
   - ❌ No hay integración con base de datos o servicios

2. **Splash Screen**:
   - ✅ Existe `lib/screens/splash_screen.dart`
   - ✅ Se muestra antes del login (según `app-router.dart`)
   - ⚠️ No tiene lógica de verificación de sesión (no verifica si el usuario ya está autenticado)

---

## ❌ Gaps Funcionales Identificados

### 1. Modelo User No Implementado (🔴 ALTA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- `User`: Entidad de usuario con email, password y role.
- Roles: `user` y `admin`.

**Estado Actual**:
- ❌ No existe modelo `User` en `lib/models/security/user.dart`
- ❌ No existe estructura de datos para usuarios
- ❌ No hay serialización `toMap()` / `fromMap()` para persistencia
- ❌ No se puede almacenar información de usuarios en base de datos

**Campos requeridos del modelo**:
- `id`: Identificador único (autonumerado para SQLite, o UUID)
- `email`: String (único, requerido)
- `password`: String (hash bcrypt, requerido)
- `role`: Enum o String ('user' o 'admin', requerido)

**Archivos a crear**:
- `lib/models/security/user.dart` - Modelo User completo con serialización

**Impacto**: 🔴 ALTA - Base para todo el módulo security

---

### 2. Tabla de Usuarios en Base de Datos No Existe (🔴 ALTA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- Los usuarios deben almacenarse en base de datos (SQLite para mobile/desktop, SharedPreferences para web)
- Debe existir un usuario administrador por defecto: `admin@task-manager.com` / `TaskManager1990*`

**Estado Actual**:
- ❌ No existe tabla `users` en el schema de base de datos
- ❌ No hay migración para crear tabla `users`
- ❌ No hay usuario administrador por defecto (seed data)
- ❌ No hay soporte multiplataforma (solo SQLite, falta SharedPreferences para web)

**Implementación requerida**:
- Crear migración para tabla `users` con campos: `id`, `email`, `password`, `role`
- Agregar índice único en `email` para evitar duplicados
- Crear seed data con usuario administrador por defecto
- Implementar soporte para SharedPreferences en web (similar a como se hace con tasks)

**Archivos a crear**:
- `lib/utils/migrations/migration_X_add_users_table.dart` - Migración para crear tabla users
- Actualizar `lib/utils/migrations/migration_registry.dart` - Registrar nueva migración

**Archivos a modificar**:
- `lib/utils/database_helper.dart` - Puede necesitar actualizaciones si hay cambios en el sistema de migraciones

**Impacto**: 🔴 ALTA - Requerido para almacenar usuarios

---

### 3. Servicio de Autenticación No Implementado (🔴 ALTA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- `login`: Autenticación de usuario con email y contraseña. Feature pública.
- Al autenticarse exitosamente, redirige a `/home`.
- Verificar rol después de autenticación para control de acceso.

**Estado Actual**:
- ❌ No existe `lib/services/security/auth_service.dart`
- ❌ No hay método para autenticar usuarios
- ❌ No hay verificación de credenciales (email + password)
- ❌ No hay comparación de hash de contraseña (bcrypt)
- ❌ No hay generación de sesión o token de autenticación
- ❌ No hay almacenamiento de sesión de usuario autenticado
- ❌ No hay método de logout

**Funcionalidades requeridas**:
1. `Future<User?> login(String email, String password)`:
   - Buscar usuario por email en BD
   - Comparar password hash con bcrypt
   - Retornar `User` si las credenciales son correctas, `null` si no
   - Lanzar excepciones apropiadas (ej: `UserNotFoundException`, `InvalidCredentialsException`)

2. `Future<void> logout()`:
   - Limpiar sesión de usuario autenticado
   - Eliminar datos de sesión (SharedPreferences o similar)

3. `Future<User?> getCurrentUser()`:
   - Obtener usuario autenticado actual (si existe)
   - Retornar `null` si no hay sesión activa

**Consideraciones Multiplataforma**:
- **Mobile/Desktop (SQLite)**: Query a tabla `users` en SQLite
- **Web (SharedPreferences)**: Almacenar usuarios en SharedPreferences con clave `users_v1` (JSON serializado)
- Ambas plataformas deben usar bcrypt para hash de contraseñas

**Archivos a crear**:
- `lib/services/security/auth_service.dart` - Servicio de autenticación
- `lib/services/security/auth_service_io.dart` - Implementación para SQLite
- `lib/services/security/auth_service_web.dart` - Implementación para SharedPreferences
- `lib/services/security/auth_service_stub.dart` - Stub para conditional exports
- `lib/services/security/auth_service.dart` - Export condicional (similar a `task_service.dart`)

**Dependencias requeridas**:
- `package:bcrypt` - Para hash de contraseñas (preferencia del usuario según app-scope.mdc)

**Impacto**: 🔴 ALTA - Core del módulo de autenticación

---

### 4. Servicio de Usuarios No Implementado (🔴 ALTA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- `register`: Registro de nuevo usuario. Feature pública.
- Solo se permite registrar usuarios con rol `user`.
- Validar email (RFC 5322 básico).
- Validar contraseña (8-32 caracteres, números, alfabéticos, especiales).
- Almacenar contraseña con hash bcrypt.

**Estado Actual**:
- ❌ No existe `lib/services/security/user_service.dart`
- ❌ No hay método para crear usuarios (registro)
- ❌ No hay validación de email
- ❌ No hay validación de contraseña
- ❌ No hay hash de contraseña con bcrypt
- ❌ No hay verificación de email único (no duplicados)

**Funcionalidades requeridas**:
1. `Future<User> createUser(String email, String password, String role = 'user')`:
   - Validar formato de email (RFC 5322 básico)
   - Validar formato de contraseña (8-32 caracteres, caracteres permitidos)
   - Verificar que email no exista ya (único)
   - Hashear contraseña con bcrypt
   - Guardar usuario en BD con rol `user` (siempre, no permitir `admin` desde registro)
   - Retornar `User` creado (sin password)
   - Lanzar excepciones apropiadas (ej: `EmailAlreadyExistsException`, `InvalidEmailException`, `InvalidPasswordException`)

2. `Future<bool> emailExists(String email)`:
   - Verificar si un email ya está registrado
   - Retornar `true` si existe, `false` si no

**Consideraciones Multiplataforma**:
- **Mobile/Desktop (SQLite)**: Insert en tabla `users`
- **Web (SharedPreferences)**: Agregar usuario a lista JSON en SharedPreferences

**Archivos a crear**:
- `lib/services/security/user_service.dart` - Servicio de usuarios
- `lib/services/security/user_service_io.dart` - Implementación para SQLite
- `lib/services/security/user_service_web.dart` - Implementación para SharedPreferences
- `lib/services/security/user_service_stub.dart` - Stub para conditional exports
- `lib/services/security/user_service.dart` - Export condicional

**Dependencias requeridas**:
- `package:bcrypt` - Para hash de contraseñas

**Impacto**: 🔴 ALTA - Requerido para registro de usuarios

---

### 5. Validaciones de Email y Contraseña No Implementadas (🔴 ALTA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- **Email**: Formato RFC 5322 básico. Usar validación estándar de Flutter/Dart.
- **Contraseña**:
  - Caracteres permitidos: Números (0-9), alfabéticos (a-z, A-Z), especiales (`!@#$%^&*()_+-=[]{}|;:,.<>?`)
  - Longitud mínima: 8 caracteres
  - Longitud máxima: 32 caracteres
  - Validación de coincidencia: password y confirmPassword deben ser idénticas

**Estado Actual**:
- ❌ No existe `lib/utils/validators/user_validator.dart` o similar
- ❌ No hay validación de formato de email
- ❌ No hay validación de formato de contraseña
- ❌ No hay validación de coincidencia de contraseñas
- ❌ No hay mensajes de error descriptivos en español

**Implementación requerida**:
- Crear validador centralizado similar a `TaskValidator`
- Métodos estáticos para validar:
  - `ValidationResult validateEmail(String email)`
  - `ValidationResult validatePassword(String password)`
  - `ValidationResult validatePasswordConfirmation(String password, String confirmPassword)`

**Archivos a crear**:
- `lib/utils/validators/user_validator.dart` - Validador de usuarios

**Impacto**: 🔴 ALTA - Requerido para registro y validación de datos

---

### 6. Provider de Autenticación No Implementado (🔴 ALTA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- Mantener estado de usuario autenticado
- Manejar flujo de login/logout
- Proporcionar información de usuario y rol para control de acceso

**Estado Actual**:
- ❌ No existe `lib/providers/security/auth_provider.dart`
- ❌ No hay estado de usuario autenticado
- ❌ No hay gestión de sesión
- ❌ No hay notificación de cambios de estado de autenticación

**Funcionalidades requeridas**:
1. Estado privado:
   - `User? _currentUser` - Usuario autenticado actual
   - `bool _loading` - Estado de carga
   - `String? _error` - Mensaje de error

2. Getters públicos:
   - `User? get currentUser => _currentUser`
   - `bool get isAuthenticated => _currentUser != null`
   - `String? get role => _currentUser?.role`
   - `bool get loading => _loading`
   - `String? get error => _error`

3. Métodos públicos:
   - `Future<bool> login(String email, String password)` - Autenticar usuario
   - `Future<void> logout()` - Cerrar sesión
   - `Future<void> loadCurrentUser()` - Cargar usuario desde sesión persistida
   - `void clearError()` - Limpiar error

**Archivos a crear**:
- `lib/providers/security/auth_provider.dart` - Provider de autenticación

**Impacto**: 🔴 ALTA - Requerido para gestión de estado de autenticación

---

### 7. Pantalla de Login Funcional No Implementada (🔴 ALTA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- Ventana de login con dos campos:
  - Campo de texto para **email** (input de tipo email)
  - Campo de texto para **contraseña** (input de tipo password con ocultación)
- Al autenticarse exitosamente, redirige a `/home`.
- Mostrar errores de autenticación al usuario.

**Estado Actual**:
- ⚠️ Existe `lib/screens/login_screen.dart` pero es solo un mock
- ❌ No se conecta con `AuthProvider` o `AuthService`
- ❌ No hay validación de campos antes de enviar
- ❌ No hay manejo de errores de autenticación
- ❌ No hay indicadores de carga
- ❌ No hay redirección basada en rol después de login
- ❌ No hay CTA para navegar a registro

**Implementación requerida**:
- Conectar con `AuthProvider` para realizar login
- Validar campos (email válido, contraseña no vacía) antes de enviar
- Mostrar `CircularProgressIndicator` durante autenticación
- Mostrar errores de autenticación usando `SnackBar` o similar
- Redirigir a `/home` después de login exitoso
- Agregar enlace o botón "Registrarse" que navega a pantalla de registro
- Manejar estados de loading y error

**Archivos a modificar**:
- `lib/screens/login_screen.dart` - Implementar funcionalidad completa

**Impacto**: 🔴 ALTA - Feature principal de autenticación

---

### 8. Pantalla de Registro No Implementada (🔴 ALTA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- **Acceso desde UI**: La ventana de login debe incluir un CTA (enlace o botón "Registrarse" o "Crear cuenta") que navega a la pantalla de registro.
- Formulario de registro con campos:
  - Campo de texto para **email** (input de tipo email)
  - Campo de texto para **contraseña** (input de tipo password con ocultación)
  - Campo de texto para **confirmar contraseña** (input de tipo password con ocultación)
- Validaciones:
  - Email: formato RFC 5322 básico
  - Contraseña: 8-32 caracteres, caracteres permitidos, coincidencia con confirmación
- Restricción de Rol: Solo registrar usuarios con rol `user` (no `admin`).

**Estado Actual**:
- ❌ No existe `lib/screens/security/register_screen.dart`
- ❌ No hay pantalla de registro
- ❌ No hay formulario de registro
- ❌ No hay navegación desde login a registro

**Implementación requerida**:
- Crear pantalla de registro con tres campos (email, password, confirmPassword)
- Validar campos en tiempo real usando `UserValidator`
- Mostrar mensajes de error de validación debajo de cada campo
- Conectar con `AuthProvider` o `UserService` para crear usuario
- Después de registro exitoso, redirigir a login o autenticar automáticamente
- Mostrar errores si el email ya existe o si hay problemas al crear usuario

**Archivos a crear**:
- `lib/screens/security/register_screen.dart` - Pantalla de registro

**Archivos a modificar**:
- `lib/navigation/app_router.dart` - Agregar ruta `/register`
- `lib/screens/login_screen.dart` - Agregar CTA "Registrarse" que navega a `/register`

**Impacto**: 🔴 ALTA - Feature principal de registro

---

### 9. Control de Acceso por Rol No Implementado (🔴 ALTA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- Verificar rol después de autenticación y dar acceso solo al módulo correspondiente.
- **Rol `user`**: Acceso al módulo `tasks`.
- **Rol `admin`**: Acceso al módulo `backoffice`.
- `HomeScreen` debe mostrar dashboard según rol.

**Estado Actual**:
- ❌ No hay verificación de rol después de login
- ❌ `HomeScreen` no tiene lógica para determinar qué dashboard mostrar según rol
- ❌ No hay protección de rutas basada en rol
- ❌ No hay redirección según rol después de login

**Implementación requerida**:
1. En `AuthProvider.login()`: Retornar usuario con rol
2. En `HomeScreen`: Verificar rol del usuario autenticado
   - Si rol es `user`: Mostrar dashboard de tareas
   - Si rol es `admin`: Mostrar dashboard backoffice
3. En `AppRouter`: Agregar guard/middleware para proteger rutas (opcional)
4. Después de login exitoso: Verificar rol y redirigir apropiadamente

**Archivos a modificar**:
- `lib/screens/home_screen.dart` - Agregar lógica de routing según rol
- `lib/screens/login_screen.dart` - Redirigir según rol después de login
- `lib/providers/security/auth_provider.dart` - Proporcionar información de rol

**Impacto**: 🔴 ALTA - Control de acceso requerido

---

### 10. Sesión de Usuario No Persistida (🟡 MEDIA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- El usuario debe permanecer autenticado después de cerrar la app (si aplica).
- Al abrir la app, debe verificar si hay sesión activa y redirigir apropiadamente.

**Estado Actual**:
- ❌ No hay persistencia de sesión de usuario
- ❌ No hay verificación de sesión al iniciar la app
- ❌ El usuario debe loguearse cada vez que abre la app

**Implementación requerida**:
- Al hacer login exitoso: Guardar información de usuario en SharedPreferences (clave: `current_user_session` o similar)
- Al iniciar app: Verificar si hay sesión guardada y autenticar automáticamente
- Al hacer logout: Eliminar sesión guardada
- En `main.dart` o `SplashScreen`: Verificar sesión antes de mostrar login

**Archivos a modificar**:
- `lib/providers/security/auth_provider.dart` - Agregar persistencia de sesión
- `lib/screens/splash_screen.dart` - Verificar sesión al iniciar
- `lib/main.dart` - Verificar sesión antes de mostrar login (si aplica)

**Impacto**: 🟡 MEDIA - Mejora UX pero no bloqueante

---

### 11. Usuario Administrador por Defecto No Creado (🔴 ALTA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- Crear un usuario administrador por defecto para el sistema, como semilla en la base de datos.
- Email: `admin@task-manager.com`
- Contraseña: `TaskManager1990*`
- Rol: `admin`

**Estado Actual**:
- ❌ No hay usuario administrador por defecto
- ❌ No hay seed data para usuarios

**Implementación requerida**:
- Crear seed data en migración inicial o en primera ejecución
- Crear usuario `admin@task-manager.com` con contraseña hasheada `TaskManager1990*`
- Verificar si el usuario ya existe antes de crearlo (evitar duplicados)
- Ejecutar seed data automáticamente al inicializar la base de datos

**Archivos a modificar**:
- `lib/utils/migrations/migration_X_add_users_table.dart` - Agregar seed data de usuario admin
- O crear `lib/utils/seed_data.dart` - Utilidad para seed data
- `README.md` - Agregar sección con información del usuario administrador por defecto para referencia del desarrollador

**Contenido sugerido para README.md**:
```markdown
## Usuario Administrador por Defecto

El sistema incluye un usuario administrador creado automáticamente:

- **Email**: `admin@task-manager.com`
- **Contraseña**: `TaskManager1990*`
- **Rol**: `admin`

Este usuario se crea automáticamente al inicializar la base de datos por primera vez.
```

**Impacto**: 🔴 ALTA - Requerido según alcance funcional

---

### 12. Excepciones de Security No Implementadas (🟡 MEDIA PRIORIDAD)

**Requerimiento según feature-structure.mdc**:
- Excepciones específicas de módulo deben organizarse en `lib/exceptions/security/`

**Estado Actual**:
- ❌ No existe `lib/exceptions/security/`
- ❌ No hay excepciones específicas del módulo security
- ❌ El servicio usará excepciones genéricas o no lanzará excepciones apropiadas

**Excepciones requeridas**:
- `UserNotFoundException` - Usuario no encontrado por email
- `InvalidCredentialsException` - Credenciales incorrectas (email o password)
- `EmailAlreadyExistsException` - Email ya registrado
- `InvalidEmailException` - Email con formato inválido
- `InvalidPasswordException` - Contraseña con formato inválido

**Archivos a crear**:
- `lib/exceptions/security/auth_exceptions.dart` - Excepciones de autenticación y registro

**Impacto**: 🟡 MEDIA - Mejora manejo de errores pero no bloqueante (puede usar `AppException` genérico inicialmente)

---

### 13. Integración con Módulo Tasks No Implementada (🔴 ALTA PRIORIDAD)

**Requerimiento según app-scope.mdc**:
- Una vez implementado el módulo `security`, el `HomeScreen` debe filtrar las tareas por el usuario autenticado según el rol.
- Para rol `user`: Solo mostrar tareas del usuario autenticado.
- Para rol `admin`: No cargar tareas aquí (el admin ve backoffice).

**Estado Actual**:
- ⚠️ `HomeScreen` tiene TODOs indicando que falta lógica de autorización
- ⚠️ `TaskProvider.loadTasks()` tiene TODOs para recibir `userId`
- ❌ No hay filtrado por usuario en `TaskService`
- ❌ No hay columna `userId` en tabla `tasks`

**Implementación requerida**:
1. **Migración de BD**: Agregar columna `userId` a tabla `tasks`
   - Crear migración `migration_X_add_user_id_to_tasks.dart`
   - Agregar columna `userId INTEGER` (nullable inicialmente para tareas existentes)
   - Agregar foreign key constraint si es posible (opcional)

2. **Modelo Task**: Agregar campo `userId` (int?)

3. **Servicios**: Modificar `loadTasks()` para aceptar `userId` opcional
   - Si `userId` es proporcionado: filtrar por `WHERE userId = ?`
   - Si `userId` es null (admin): cargar todas las tareas

4. **Provider**: Modificar `TaskProvider.loadTasks()` para aceptar `userId`
   - Obtener `userId` del usuario autenticado desde `AuthProvider`

5. **HomeScreen**: Integrar con `AuthProvider`
   - Obtener usuario autenticado
   - Verificar rol
   - Pasar `userId` a `TaskProvider` si rol es `user`

**Archivos a modificar**:
- `lib/models/tasks/task.dart` - Agregar campo `userId`
- `lib/utils/migrations/migration_X_add_user_id_to_tasks.dart` - Crear migración
- `lib/services/tasks/task_service_io.dart` - Filtrar por `userId`
- `lib/services/tasks/task_service_web.dart` - Filtrar por `userId`
- `lib/providers/tasks/task_provider.dart` - Aceptar `userId` en `loadTasks()`
- `lib/screens/home_screen.dart` - Integrar con `AuthProvider` y pasar `userId`

**Nota**: Este gap se relaciona con el módulo `tasks`, pero es crítico para la integración con `security`.

**Impacto**: 🔴 ALTA - Requerido para aislamiento de datos por usuario

---

## Resumen de Gaps por Prioridad

### 🔴 Alta Prioridad (Bloqueantes para cumplir alcance funcional)
1. **Modelo User completo** (campo email, password, role, serialización)
2. **Tabla de usuarios en BD** (migración, índice único en email, soporte multiplataforma)
3. **Servicio de autenticación** (login, logout, verificación de credenciales, bcrypt)
4. **Servicio de usuarios** (createUser, validación de email único, hash bcrypt)
5. **Validaciones de email y contraseña** (RFC 5322, longitud, caracteres permitidos)
6. **Provider de autenticación** (estado de usuario, login/logout, gestión de sesión)
7. **Pantalla de login funcional** (conexión con AuthProvider, validación, errores)
8. **Pantalla de registro** (formulario, validaciones, creación de usuario)
9. **Control de acceso por rol** (routing según rol en HomeScreen)
10. **Usuario administrador por defecto** (seed data: admin@task-manager.com)
11. **Integración con módulo tasks** (columna userId, filtrado por usuario)

### 🟡 Media Prioridad (Mejoras importantes)
12. **Persistencia de sesión** (guardar sesión, verificar al iniciar app)
13. **Excepciones específicas de security** (excepciones personalizadas para mejor UX)

---

## Notas Técnicas

- **Estructura modular**: Todos los archivos del módulo `security` deben seguir la estructura definida en `feature-structure.mdc`:
  - Modelos → `lib/models/security/`
  - Servicios → `lib/services/security/`
  - Providers → `lib/providers/security/`
  - Screens → `lib/screens/security/`
  - Widgets → `lib/widgets/security/` (si aplica)
  - Excepciones → `lib/exceptions/security/`

- **Multiplataforma**: El módulo debe funcionar en ambas plataformas:
  - **Mobile/Desktop (SQLite)**: Tabla `users` en SQLite
  - **Web (SharedPreferences)**: Almacenar usuarios en SharedPreferences como JSON

- **Hash de contraseñas**: Usar `package:bcrypt` según preferencia del usuario indicada en `app-scope.mdc`.

- **Validaciones**: Centralizar validaciones en `lib/utils/validators/user_validator.dart` similar a `TaskValidator`.

- **Sesión**: Para simplicidad, se puede usar SharedPreferences para guardar sesión (email del usuario autenticado) en ambas plataformas. Al iniciar la app, cargar usuario desde BD usando el email guardado.

- **Integración con Tasks**: Requiere agregar columna `userId` a tabla `tasks` y modificar servicios/providers para filtrar por usuario. Esto debe coordinarse con el módulo `tasks`.

- **Splash Screen**: Ya existe pero debe actualizarse para verificar sesión al iniciar la app y redirigir apropiadamente (login si no hay sesión, home si hay sesión).

---

## Dependencias Potenciales

### Librerías Requeridas
- `package:bcrypt` - Para hash de contraseñas (requerido según app-scope.mdc)

### Dependencias Opcionales
- `package:crypto` - Alternativa para hash (no recomendada, bcrypt es preferido)

---

## Próximos Pasos Recomendados

1. 🔴 **Crear modelo User y tabla en BD** (migración + modelo)
2. 🔴 **Implementar validaciones de email y contraseña** (UserValidator)
3. 🔴 **Crear servicio de usuarios** (createUser, emailExists, hash bcrypt)
4. 🔴 **Crear servicio de autenticación** (login, logout, getCurrentUser)
5. 🔴 **Crear provider de autenticación** (estado, métodos)
6. 🔴 **Implementar pantalla de login funcional** (conexión con provider)
7. 🔴 **Implementar pantalla de registro** (formulario, validaciones)
8. 🔴 **Implementar control de acceso por rol** (routing en HomeScreen)
9. 🔴 **Crear usuario administrador por defecto** (seed data + actualizar README.md)
10. 🔴 **Integrar con módulo tasks** (userId, filtrado)
11. 🟡 **Persistir sesión de usuario** (SharedPreferences)
12. 🟡 **Crear excepciones específicas de security** (mejor manejo de errores)

---

## Consideraciones de Implementación

### Orden Lógico Recomendado
1. Modelo y BD (base para todo)
2. Validaciones (requeridas por servicios)
3. Servicios (requeridos por providers)
4. Provider (requerido por screens)
5. Screens (UI final)
6. Integración con tasks (requiere módulo security completo)

### Testing Manual
- Probar login con credenciales válidas e inválidas
- Probar registro con emails válidos e inválidos
- Probar validaciones de contraseña
- Probar control de acceso según rol
- Probar persistencia de sesión
- Probar integración con tasks (filtrar por usuario)

