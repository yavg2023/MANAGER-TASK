import 'task_validator.dart';

/// Validador para la entidad User del módulo security.
///
/// Proporciona métodos estáticos para validar email, contraseña y coincidencia de contraseñas.
/// Todas las validaciones retornan mensajes de error en español.
class UserValidator {
  /// Longitud mínima para la contraseña.
  static const int minPasswordLength = 8;

  /// Longitud máxima para la contraseña.
  static const int maxPasswordLength = 32;

  /// Caracteres permitidos en la contraseña.
  ///
  /// Incluye: números (0-9), letras (a-z, A-Z) y caracteres especiales permitidos.
  /// Caracteres especiales: !@#\$%^&*()_+-=[]{}|;:,.<>?
  static const String allowedPasswordChars =
      r'[a-zA-Z0-9!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]';

  /// Patrón de expresión regular para validar formato de email (RFC 5322 básico).
  ///
  /// Valida formato básico: usuario@dominio.extensión
  /// No valida el RFC completo, solo formato básico suficiente para uso común.
  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Patrón de expresión regular para validar caracteres permitidos en contraseña.
  static final RegExp _passwordPattern = RegExp(
    r'^[a-zA-Z0-9!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]*$',
  );

  /// Valida el formato de un email.
  ///
  /// Reglas:
  /// - El email es requerido (no puede ser null, vacío o solo espacios).
  /// - Debe cumplir con formato RFC 5322 básico (usuario@dominio.extensión).
  ///
  /// Retorna `ValidationResult` con `isValid: true` si es válido,
  /// o `isValid: false` con un mensaje de error en español.
  static ValidationResult validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return const ValidationResult(
        isValid: false,
        error: 'El email es requerido',
      );
    }

    final trimmed = email.trim();

    // Validación básica: debe contener @
    if (!trimmed.contains('@')) {
      return const ValidationResult(
        isValid: false,
        error: 'El formato del email no es válido',
      );
    }

    // Validación de formato usando RegExp
    if (!_emailPattern.hasMatch(trimmed)) {
      return const ValidationResult(
        isValid: false,
        error: 'El formato del email no es válido',
      );
    }

    return const ValidationResult(isValid: true);
  }

  /// Valida una contraseña.
  ///
  /// Reglas:
  /// - La contraseña es requerida (no puede ser null, vacía o solo espacios).
  /// - Debe tener entre 8 y 32 caracteres.
  /// - Solo puede contener: números (0-9), letras (a-z, A-Z) y caracteres especiales:
  ///   !@#\$%^&*()_+-=[]{}|;:,.<>?
  ///
  /// Retorna `ValidationResult` con `isValid: true` si es válido,
  /// o `isValid: false` con un mensaje de error en español.
  static ValidationResult validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return const ValidationResult(
        isValid: false,
        error: 'La contraseña es requerida',
      );
    }

    // Validar longitud mínima
    if (password.length < minPasswordLength) {
      return const ValidationResult(
        isValid: false,
        error: 'La contraseña debe tener al menos 8 caracteres',
      );
    }

    // Validar longitud máxima
    if (password.length > maxPasswordLength) {
      return const ValidationResult(
        isValid: false,
        error: 'La contraseña no puede exceder 32 caracteres',
      );
    }

    // Validar caracteres permitidos
    if (!_passwordPattern.hasMatch(password)) {
      return const ValidationResult(
        isValid: false,
        error:
            'La contraseña solo puede contener números, letras y los siguientes caracteres especiales: !@#\$%^&*()_+-=[]{}|;:,.<>?',
      );
    }

    return const ValidationResult(isValid: true);
  }

  /// Valida que dos contraseñas coincidan.
  ///
  /// Reglas:
  /// - Ambas contraseñas son requeridas (no pueden ser null o vacías).
  /// - Deben ser idénticas.
  ///
  /// Retorna `ValidationResult` con `isValid: true` si coinciden,
  /// o `isValid: false` con un mensaje de error en español.
  static ValidationResult validatePasswordConfirmation(
    String? password,
    String? confirmPassword,
  ) {
    if (password == null || password.isEmpty) {
      return const ValidationResult(
        isValid: false,
        error: 'La contraseña es requerida',
      );
    }

    if (confirmPassword == null || confirmPassword.isEmpty) {
      return const ValidationResult(
        isValid: false,
        error: 'La confirmación de contraseña es requerida',
      );
    }

    if (password != confirmPassword) {
      return const ValidationResult(
        isValid: false,
        error: 'Las contraseñas no coinciden',
      );
    }

    return const ValidationResult(isValid: true);
  }

  /// Valida todos los campos para registro de usuario.
  ///
  /// Valida email, contraseña y coincidencia de contraseñas.
  /// Retorna un mapa con los errores encontrados.
  /// Las claves del mapa son: 'email', 'password', 'confirmPassword'.
  /// Si no hay errores, retorna un mapa vacío.
  ///
  /// Ejemplo de retorno con errores:
  /// ```dart
  /// {'email': 'El formato del email no es válido', 'password': 'La contraseña debe tener al menos 8 caracteres'}
  /// ```
  ///
  /// Ejemplo de retorno sin errores:
  /// ```dart
  /// {}
  /// ```
  static Map<String, String> validateRegistration({
    String? email,
    String? password,
    String? confirmPassword,
  }) {
    final errors = <String, String>{};

    // Validar email
    final emailResult = validateEmail(email);
    if (!emailResult.isValid) {
      errors['email'] = emailResult.error ?? 'Error de validación en email';
    }

    // Validar contraseña
    final passwordResult = validatePassword(password);
    if (!passwordResult.isValid) {
      errors['password'] =
          passwordResult.error ?? 'Error de validación en contraseña';
    }

    // Validar coincidencia de contraseñas (solo si ambas están presentes)
    if (password != null && confirmPassword != null) {
      final confirmResult =
          validatePasswordConfirmation(password, confirmPassword);
      if (!confirmResult.isValid) {
        errors['confirmPassword'] =
            confirmResult.error ?? 'Error de validación en confirmación';
      }
    }

    return errors;
  }
}
