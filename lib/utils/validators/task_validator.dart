/// Resultado de una validación individual.
///
/// Indica si la validación fue exitosa y proporciona un mensaje de error si no lo fue.
class ValidationResult {
  final bool isValid;
  final String? error;

  const ValidationResult({required this.isValid, this.error});
}

/// Validador para la entidad Task del módulo tasks.
///
/// Proporciona métodos estáticos para validar título, descripción, ID y la tarea completa.
/// Todas las validaciones retornan mensajes de error en español.
class TaskValidator {
  /// Longitud mínima para el título (requerido: 1 carácter mínimo).
  static const int minTitleLength = 1;

  /// Longitud máxima para el título.
  static const int maxTitleLength = 100;

  /// Longitud máxima para la descripción.
  static const int maxDescriptionLength = 500;

  /// Valida el título de una tarea.
  ///
  /// Reglas:
  /// - El título es requerido (no puede ser null, vacío o solo espacios).
  /// - Debe tener entre 1 y 100 caracteres (después de trim).
  ///
  /// Retorna `ValidationResult` con `isValid: true` si es válido,
  /// o `isValid: false` con un mensaje de error en español.
  static ValidationResult validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return const ValidationResult(
        isValid: false,
        error: 'El título es requerido',
      );
    }
    final trimmed = title.trim();
    if (trimmed.length < minTitleLength) {
      return const ValidationResult(
        isValid: false,
        error: 'El título no puede estar vacío',
      );
    }
    if (trimmed.length > maxTitleLength) {
      // No se puede usar const porque el mensaje usa interpolación de strings ($maxTitleLength)
      // y las expresiones con interpolación no son constantes en tiempo de compilación
      // ignore: prefer_const_constructors
      return ValidationResult(
        isValid: false,
        error: 'El título no puede exceder $maxTitleLength caracteres',
      );
    }
    return const ValidationResult(isValid: true);
  }

  /// Valida la descripción de una tarea.
  ///
  /// Reglas:
  /// - La descripción es opcional (puede ser null, vacía o solo espacios).
  /// - Si tiene contenido, debe tener máximo 500 caracteres (después de trim).
  ///
  /// Retorna `ValidationResult` con `isValid: true` si es válido,
  /// o `isValid: false` con un mensaje de error en español.
  static ValidationResult validateDescription(String? description) {
    if (description == null || description.trim().isEmpty) {
      // Descripción es opcional, null o vacío es válido
      return const ValidationResult(isValid: true);
    }
    final trimmed = description.trim();
    if (trimmed.length > maxDescriptionLength) {
      // No se puede usar const porque el mensaje usa interpolación de strings ($maxDescriptionLength)
      // y las expresiones con interpolación no son constantes en tiempo de compilación
      // ignore: prefer_const_constructors
      return ValidationResult(
        isValid: false,
        error:
            'La descripción no puede exceder $maxDescriptionLength caracteres',
      );
    }
    return const ValidationResult(isValid: true);
  }

  /// Valida un ID de tarea.
  ///
  /// Reglas:
  /// - El ID debe ser un número positivo (mayor que 0).
  /// - null no es válido.
  ///
  /// Retorna `ValidationResult` con `isValid: true` si es válido,
  /// o `isValid: false` con un mensaje de error en español.
  static ValidationResult validateId(int? id) {
    if (id == null) {
      return const ValidationResult(
        isValid: false,
        error: 'El ID de la tarea es requerido',
      );
    }
    if (id <= 0) {
      return const ValidationResult(
        isValid: false,
        error: 'El ID de la tarea debe ser un número positivo',
      );
    }
    return const ValidationResult(isValid: true);
  }

  /// Valida una tarea completa (título y descripción).
  ///
  /// Valida ambos campos y retorna un mapa con los errores encontrados.
  /// Las claves del mapa son los nombres de los campos ('title', 'description').
  /// Si no hay errores, retorna un mapa vacío.
  ///
  /// Ejemplo de retorno con errores:
  /// ```dart
  /// {'title': 'El título es requerido', 'description': 'La descripción no puede exceder 500 caracteres'}
  /// ```
  ///
  /// Ejemplo de retorno sin errores:
  /// ```dart
  /// {}
  /// ```
  static Map<String, String> validateTask({
    String? title,
    String? description,
  }) {
    final errors = <String, String>{};

    final titleResult = validateTitle(title);
    if (!titleResult.isValid) {
      errors['title'] = titleResult.error ?? 'Error de validación en título';
    }

    final descriptionResult = validateDescription(description);
    if (!descriptionResult.isValid) {
      errors['description'] =
          descriptionResult.error ?? 'Error de validación en descripción';
    }

    return errors;
  }
}
