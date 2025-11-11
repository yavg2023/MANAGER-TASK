import '../app_exception.dart';

/// Excepción lanzada cuando un usuario no se encuentra en la base de datos.
class UserNotFoundException extends AppException {
  UserNotFoundException(String email)
      : super('Usuario con email $email no encontrado');
}

/// Excepción lanzada cuando las credenciales de autenticación son incorrectas.
class InvalidCredentialsException extends AppException {
  InvalidCredentialsException() : super('Email o contraseña incorrectos');
}

/// Excepción lanzada cuando se intenta registrar un email que ya está en uso.
class EmailAlreadyExistsException extends AppException {
  EmailAlreadyExistsException(String email)
      : super('El email $email ya está registrado');
}

/// Excepción lanzada cuando el formato del email es inválido.
class InvalidEmailException extends AppException {
  InvalidEmailException(String email)
      : super('El formato del email $email no es válido');
}

/// Excepción lanzada cuando el formato de la contraseña es inválido.
///
/// Recibe un mensaje personalizado del validador que describe el error específico.
class InvalidPasswordException extends AppException {
  InvalidPasswordException(super.message);
}
