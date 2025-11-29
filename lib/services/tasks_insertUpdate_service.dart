// api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {
  static const String _url = 'https://fveddcrqhbqojaokjwar.supabase.co/rest/v1/tasks';

  static const Map<String, String> _headers = {
    'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ2ZWRkY3JxaGJxb2phb2tqd2FyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4MzI5MzQsImV4cCI6MjA3OTQwODkzNH0.BIIo4F2x4xzzLvTCQv4Ng8cW9jgJqiM0ZpYLd2hA3EY',
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ2ZWRkY3JxaGJxb2phb2tqd2FyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4MzI5MzQsImV4cCI6MjA3OTQwODkzNH0.BIIo4F2x4xzzLvTCQv4Ng8cW9jgJqiM0ZpYLd2hA3EY',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };

  /// Crea una nueva tarea
  static Future<Map<String, dynamic>?> createTask(Map<String, dynamic> taskData) async {
    try {
      final uri = Uri.parse(_url);
      final res = await http.post(
        uri,
        headers: _headers,
        body: json.encode(taskData),
      );

      if (res.statusCode == 201) {
        // Supabase devuelve el objeto creado
        final List<dynamic> result = json.decode(res.body);
        return result.isNotEmpty ? result[0] : null;
      } else {
        print('Error al crear tarea: ${res.statusCode} ${res.body}');
        return null;
      }
    } catch (e) {
      print('Excepción al crear tarea: $e');
      return null;
    }
  }

  /// Actualiza una tarea existente
  static Future<Map<String, dynamic>?> updateTask(String id, Map<String, dynamic> taskData) async {
    try {
      final uri = Uri.parse('$_url?id=eq.$id');
      final res = await http.patch(
        uri,
        headers: _headers,
        body: json.encode(taskData),
      );

      if (res.statusCode == 200) {
        // Supabase devuelve el objeto actualizado
        final List<dynamic> result = json.decode(res.body);
        return result.isNotEmpty ? result[0] : null;
      } else {
        print('Error al actualizar tarea: ${res.statusCode} ${res.body}');
        return null;
      }
    } catch (e) {
      print('Excepción al actualizar tarea: $e');
      return null;
    }
  }
}
