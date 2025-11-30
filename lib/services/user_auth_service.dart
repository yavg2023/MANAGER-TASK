import 'dart:convert';
import 'package:http/http.dart' as http;

class UserAuthService {
  // URL de la tabla users
  static const String _url = 'https://fveddcrqhbqojaokjwar.supabase.co/rest/v1/users';

  // Headers necesarios
  static const Map<String, String> _headers = {
    'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ2ZWRkY3JxaGJxb2phb2tqd2FyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4MzI5MzQsImV4cCI6MjA3OTQwODkzNH0.BIIo4F2x4xzzLvTCQv4Ng8cW9jgJqiM0ZpYLd2hA3EY',
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ2ZWRkY3JxaGJxb2phb2tqd2FyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4MzI5MzQsImV4cCI6MjA3OTQwODkzNH0.BIIo4F2x4xzzLvTCQv4Ng8cW9jgJqiM0ZpYLd2hA3EY',
    'Content-Type': 'application/json',
  };

  // Login usando email + password
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Filtrar por email
      final uri = Uri.parse('$_url?email=eq.$email');
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode == 200) {
        final List users = json.decode(res.body);

        if (users.isEmpty) {
          return {'error': 'email_not_found', 'message': 'Este correo no existe'};
        }

        final user = users.first;

        if (user['password'] != password) {
          return {'error': 'wrong_password', 'message': 'Contraseña incorrecta'};
        }

        return {
          'success': true,
          'user': {
            'id': user['id'],
            'email': user['email'],
            'role': user['role'],
            'nombre': user['nombre'],
          }
        };
      } else {
        return {'error': 'database_error', 'message': 'Error en la conexión'};
      }
    } catch (e) {
      return {'error': 'exception', 'message': e.toString()};
    }
  }
}
