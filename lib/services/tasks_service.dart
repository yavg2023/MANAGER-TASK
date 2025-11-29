// tasks_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class TasksService {
  static const String _url = 'https://fveddcrqhbqojaokjwar.supabase.co/rest/v1/tasks';

   static const Map<String, String> _headers = {
    'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ2ZWRkY3JxaGJxb2phb2tqd2FyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4MzI5MzQsImV4cCI6MjA3OTQwODkzNH0.BIIo4F2x4xzzLvTCQv4Ng8cW9jgJqiM0ZpYLd2hA3EY',
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ2ZWRkY3JxaGJxb2phb2tqd2FyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4MzI5MzQsImV4cCI6MjA3OTQwODkzNH0.BIIo4F2x4xzzLvTCQv4Ng8cW9jgJqiM0ZpYLd2hA3EY',
    'Content-Type': 'application/json',
  };


  /// Trae todas las tareas de un usuario por su userId
  static Future<List<dynamic>> fetchTasksByUser(String userId) async {
    try {
      final uri = Uri.parse('$_url?user_id=eq.$userId');
      final res = await http.get(uri, headers: _headers);

      if (res.statusCode == 200) {
        return json.decode(res.body);
      } else {
        print('Error al cargar tareas: ${res.statusCode} ${res.body}');
        return [];
      }
    } catch (e) {
      print('Excepción al cargar tareas: $e');
      return [];
    }
  }

  /// Elimina una tarea por id
  static Future<bool> deleteTask(String id) async {
    try {
      final uri = Uri.parse('$_url?id=eq.$id');
      final res = await http.delete(uri, headers: _headers);

      if (res.statusCode == 204) {
        return true;
      } else {
        print('Error al eliminar tarea: ${res.statusCode} ${res.body}');
        return false;
      }
    } catch (e) {
      print('Excepción al eliminar tarea: $e');
      return false;
    }
  }
}