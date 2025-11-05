import '../../models/security/user.dart';

/// Implementación stub del servicio de usuarios.
///
/// Retorna valores por defecto sin persistencia real.
class UserService {
  Future<User> createUser(
    String email,
    String password, {
    String role = 'user',
  }) async =>
      User(
        id: DateTime.now().millisecondsSinceEpoch,
        email: email,
        password: '',
        role: role,
      );

  Future<bool> emailExists(String email) async => false;

  Future<User?> findUserByEmail(String email) async => null;
}
