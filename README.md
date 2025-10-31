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

