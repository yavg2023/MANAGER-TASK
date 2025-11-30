/// Utilidades para gestión de roles y autorización.
class AuthUtils {
  /// Email del administrador único del sistema.
  static const String adminEmail = 'admin@task-manager.com';

  /// Determina si el email corresponde a un administrador.
  /// 
  /// En esta versión inicial, el admin está quemado en el código.
  /// En el futuro, se podría obtener del backend como parte de la respuesta de login.
  static bool isAdmin(String email) {
    return email == adminEmail;
  }

  /// Retorna la ruta de navegación según el rol del usuario.
  static String getHomeRouteForEmail(String email) {
    if (isAdmin(email)) {
      return '/admin-dashboard';
    }
    return '/tasks';
  }


  static int? _userId;

  static void setUserId(int id) => _userId = id;
  static int? get userId => _userId;


}
