class HardcodedUsers {
  static const _users = {
    "admin@example.com": {
      "password": "123456",
      "role": "admin"
    },
    "user@example.com": {
      "password": "123456",
      "role": "user"
    }
  };

  static bool userExists(String email) {
    return _users.containsKey(email);
  }

  static String? getRole(String email, String password) {
    final user = _users[email];

    if (user != null && user["password"] == password) {
      return user["role"];
    }

    return null;
  }
}

