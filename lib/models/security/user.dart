/// Modelo de usuario para el módulo security.
///
/// Representa un usuario del sistema con sus credenciales y rol.
/// La contraseña se almacena como hash (bcrypt), nunca en texto plano.
class User {
  final int? id;
  final String email;
  final String password; // Hash bcrypt, nunca texto plano
  final String role; // 'user' o 'admin'

  User({
    this.id,
    required this.email,
    required this.password,
    required this.role,
  });

  /// Serializa el usuario a un Map para almacenamiento en base de datos.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'email': email,
      'password': password,
      'role': role,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  /// Crea un usuario desde un Map (deserialización desde base de datos).
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      email: map['email'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
    );
  }

  /// Serializa el usuario a JSON para compatibilidad.
  Map<String, dynamic> toJson() => toMap();

  /// Crea un usuario desde JSON (para SharedPreferences en web).
  factory User.fromJson(Map<String, dynamic> json) => User.fromMap(json);

  /// Crea una copia del usuario con campos opcionalmente modificados.
  User copyWith({
    int? id,
    String? email,
    String? password,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }
}
