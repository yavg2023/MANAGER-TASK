/// Clase base transversal para todas las excepciones personalizadas de la aplicación.
///
/// Todas las excepciones personalizadas deben extender de esta clase.
/// Proporciona un campo `message` con el mensaje de error en español para el usuario final.
///
/// Esta clase puede instanciarse directamente para errores genéricos.
/// Para errores específicos del dominio, crear clases que extiendan de esta.
class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}
