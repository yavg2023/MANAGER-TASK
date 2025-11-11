import '../../models/security/user.dart';

/// Implementación stub del servicio de autenticación.
///
/// Retorna valores por defecto sin persistencia real.
class AuthService {
  Future<User?> login(String email, String password) async => null;

  Future<User?> getCurrentUser() async => null;

  Future<void> logout() async {}
}
