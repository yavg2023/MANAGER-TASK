<<<<<<< HEAD
# Gestión de Tareas - Multiplataforma

Aplicación Flutter multiplataforma para gestión de tareas con autenticación y roles. Soporta SQLite en Android/iOS/Desktop y SharedPreferences en web. Incluye módulos de seguridad (autenticación y autorización), gestión de tareas para usuarios regulares, y dashboard administrativo para administradores.

## Estado de Implementación

La aplicación cuenta con 3 módulos principales:

- ✅ **security**: Módulo de autenticación y autorización (login, registro) - **Implementado**
- ✅ **tasks**: Gestión de tareas para usuarios regulares (CRUD de tareas) - **Implementado**
- ⚠️ **backoffice**: Dashboard administrativo para administradores - **Pendiente de implementación**

### Módulo Backoffice (Pendiente)

El módulo `backoffice` es un dashboard administrativo accesible solo para usuarios con rol `admin`. Su propósito es permitir la gestión y visualización de todas las tareas de todos los usuarios del sistema.

**Funcionalidades planificadas**:
- Dashboard con tabla paginada de todas las tareas (10, 25, 50 registros por página)
- Filtrado por ID de tarea, título, usuario (email) y fecha de creación
- Visualización de detalle completo de tareas en modal (solo lectura, sin edición)
- Ordenamiento por fecha de creación (ascendente por defecto)
- Paginación a nivel de base de datos (server-side)

**Nota**: Actualmente, aunque existe la pantalla base `admin_dashboard_screen.dart`, las funcionalidades de filtrado, paginación y visualización de detalles aún están pendientes de implementación.

## Configuración del Ambiente Local

### Requisitos Previos

- Flutter SDK (versión estable recomendada)
- Dart SDK (incluido con Flutter)
- Git

### Instalación Inicial

1. **Clonar el repositorio** (si aplica):
   ```bash
   git clone <url-del-repositorio>
   cd task_manager_full_sqlite
   ```

2. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

3. **Verificar dispositivos disponibles**:
   ```bash
   flutter devices
   ```

### Compilación y Construcción

- **Compilar para desarrollo**: La aplicación se compila automáticamente al ejecutar `flutter run`
- **Construir release**:
  ```bash
  flutter build macos    # macOS
  flutter build linux    # Linux
  flutter build web      # Web
  ```

### Ejecución

**Ejecutar en dispositivo específico**:
```bash
flutter run -d macos      # macOS Desktop
flutter run -d linux      # Linux Desktop
flutter run -d chrome     # Web (Chrome)
flutter run -d windows    # Windows Desktop
```

**Ejecutar en dispositivo por defecto**:
```bash
flutter run
```

**Ejecutar con hot reload**: La aplicación se ejecuta con hot reload habilitado por defecto. Presiona `r` en la terminal para recargar, `R` para recargar completamente, o `q` para salir.

## Usuario Administrador por Defecto

El sistema incluye un usuario administrador creado automáticamente al inicializar la base de datos:

- **Email**: `admin@task-manager.com`
- **Contraseña**: `TaskManager1990*`
- **Rol**: `admin`

Este usuario proporciona acceso completo al módulo `backoffice` (dashboard administrativo). La contraseña se almacena hasheada con **bcrypt** y nunca se guarda en texto plano.

⚠️ **IMPORTANTE**: Cambia la contraseña por defecto en un entorno de producción.

## Desarrollo con IA Generativa

Este proyecto incluye reglas e instrucciones en `.cursor/rules/` para guiar a asistentes de IA (Cursor, GitHub Copilot) en el desarrollo de funcionalidades.

### Rules Disponibles

- **`app-scope.mdc`**: Define el alcance funcional mínimo de la aplicación y los módulos del sistema (security, tasks, backoffice).
- **`feature-structure.mdc`**: Establece el marco de trabajo para implementar features, incluyendo estructura de archivos modular, principios de desarrollo (DRY, KISS, YAGNI), y patrones de implementación.
- **`database-versioning.mdc`**: Define el estándar para manejar versionamiento y migraciones de base de datos SQLite.

### Uso con Cursor o GitHub Copilot

1. **Referenciar las rules**: Al solicitar funcionalidades, menciona las rules relevantes usando `@rules` o `@feature-structure.mdc`.
2. **Seguir la estructura**: Las rules definen dónde ubicar código según el módulo (security, tasks, backoffice) y el tipo de componente (models, services, providers, screens, widgets).
3. **Mantener consistencia**: Las rules garantizan que el código generado siga los estándares del proyecto (estructura modular, manejo de errores, validaciones, etc.).

Las rules están configuradas para aplicarse automáticamente en Cursor. Para GitHub Copilot, referencia las rules explícitamente en tus prompts.

## Estructura de la Aplicación

La aplicación sigue una arquitectura modular organizada por módulos funcionales (security, tasks, backoffice) y componentes transversales.

### Organización por Módulos

Cada módulo (`security`, `tasks`, `backoffice`) organiza sus componentes en subdirectorios:

- **`models/`**: Modelos de datos (User, Task)
- **`services/`**: Lógica de negocio y persistencia (auth_service, task_service)
- **`providers/`**: Gestión de estado (auth_provider, task_provider)
- **`screens/`**: Pantallas completas (login_screen, task_dashboard_screen)
- **`widgets/`**: Widgets reutilizables específicos del módulo

### Componentes Transversales

- **`exceptions/`**: Excepciones personalizadas (transversales y específicas por módulo)
- **`navigation/`**: Configuración de rutas (`app_router.dart`)
- **`theme/`**: Temas y estilos globales (`app_theme.dart`)
- **`utils/`**: Utilidades transversales:
  - `database_io.dart`: Manejo de conexión SQLite para mobile/desktop
  - `database_web.dart`: Inicialización SharedPreferences para web
  - `platform_helper.dart`: Verificación de plataforma (web vs mobile/desktop)
  - `logger.dart`: Logging centralizado
  - `migrations/`: Sistema de migraciones de base de datos (solo SQLite)
  - `validators/`: Validadores de datos (task_validator, user_validator)

### Flujo de Datos

1. **UI** (screens/widgets) → **Providers** (estado) → **Services** (lógica de negocio) → **Persistencia** (SQLite/SharedPreferences)
2. **Models**: Definen la estructura de datos compartida entre capas
3. **Exceptions**: Manejan errores de negocio y técnicos
4. **Validators**: Validan datos antes de persistir

### Persistencia Multiplataforma

- **Mobile/Desktop**: SQLite mediante `DatabaseIO` (inicialización en `SplashScreen`), usado por `task_service_io.dart` y `user_service_io.dart`
- **Web**: SharedPreferences mediante `DatabaseWeb` (inicialización en `SplashScreen`), usado por `task_service_web.dart` y `user_service_web.dart`
- Los servicios abstractos (`task_service.dart`, `auth_service.dart`) determinan qué implementación usar según la plataforma
- **Verificación de plataforma**: Centralizada en `PlatformHelper` para evitar dispersión de verificaciones
=======
# Task Manager - Flutter complete migration prototype

Esta plantilla migra la UI de tu app de tareas a **Flutter** y añade:
- CRUD completo (create, read, update, delete)
- Toggle de completado (update PUT)
- Pantalla de creación/edición reutilizable
- Sincronización offline básica mediante cache en SharedPreferences
- Mecanismo simple: si una operación falla por red, se persiste en cache local
- Colores corporativos (azul #2563EB, verde #10B981)

IMPORTANTE: Ajusta la URL `https://tu-api-aqui.com/api` en `lib/services/api.dart` a tu backend.

## Uso
1. Reemplaza logo en `assets/logo.png`.
2. `flutter pub get`
3. `flutter run`

>>>>>>> cbe15e97e9cfd517c18122b48ef1ad78029d4720
