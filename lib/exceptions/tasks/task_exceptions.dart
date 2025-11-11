import '../app_exception.dart';

/// Excepción lanzada cuando una tarea no se encuentra en la base de datos.
class TaskNotFoundException extends AppException {
  TaskNotFoundException(int id) : super('Tarea con ID $id no encontrada');
}

/// Excepción lanzada cuando falla la validación de datos de una tarea.
///
/// Ejemplo de uso:
/// ```dart
/// TaskValidationException('El título es requerido')
/// ```
class TaskValidationException extends AppException {
  TaskValidationException(super.message);
}
