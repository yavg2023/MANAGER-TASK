import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Api {
  static const baseUrl = 'https://tu-api-aqui.com/api';
  static const cacheKey = 'cached_tasks_v1';

  static bool offline = false;

  // -------------------------------
  // 🔹 GUARDAR CACHE LOCAL
  // -------------------------------
  static Future<void> _saveCache(List data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(cacheKey, jsonEncode(data));
  }

  // -------------------------------
  // 🔹 LEER CACHE LOCAL
  // -------------------------------
  static Future<List?> _readCache() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(cacheKey);
    if (s == null) return null;

    try {
      final decoded = jsonDecode(s);
      if (decoded is List) return decoded;
    } catch (e) {
      debugPrint('cache decode error: $e');
    }

    return null;
  }

  // ==========================================================
  // 🔵 LOGIN
  // ==========================================================
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl/login');

      final response = await http.post(
        url,
        body: {
          'email': email,
          'password': password,
        },
      );

      print("🔵 STATUS API LOGIN: ${response.statusCode}");
      print("🟢 BODY API LOGIN: ${response.body}");

      final data = json.decode(response.body);

      // guardar token si existe
      if (data is Map && data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
      }

      return data;

    } catch (e) {
      print("🔴 ERROR EN Api.login(): $e");
      return {"error": "exception", "message": "$e"};
    }
  }

  // ==========================================================
  // 🔵 OBTENER TAREAS
  // ==========================================================
  static Future<List?> fetchTasks(String token) async {
    final url = Uri.parse('$baseUrl/tasks');

    try {
      final res = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      print("🔵 STATUS GET TASKS: ${res.statusCode}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List list;

        if (data is List) {
          list = data;
        } else if (data is Map && data['tasks'] != null) {
          list = List.from(data['tasks']);
        } else {
          list = [];
        }

        await _saveCache(list);
        offline = false;
        return list;
      }
    } catch (e) {
      debugPrint('fetchTasks error, return cache: $e');
      offline = true;
      return await _readCache();
    }

    return await _readCache();
  }

  // ==========================================================
  // 🔵 CREAR TAREA
  // ==========================================================
  static Future<Map?> createTask(Map body) async {
    final url = Uri.parse('$baseUrl/tasks');

    try {
      final token = await getStoredToken();

      final res = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = jsonDecode(res.body);

        final cache = await _readCache() ?? [];
        cache.insert(0, data);
        await _saveCache(cache);

        offline = false;
        return data;
      }
    } catch (e) {
      // modo offline
      final cache = await _readCache() ?? [];
      final tempId = const Uuid().v4();
      final pending = {...body, 'id': tempId, 'pending': true};

      cache.insert(0, pending);
      await _saveCache(cache);

      offline = true;
      return pending;
    }

    return null;
  }

  // ==========================================================
  // 🔵 ACTUALIZAR TAREA
  // ==========================================================
  static Future<Map?> updateTask(String id, Map body) async {
    final url = Uri.parse('$baseUrl/tasks/$id');

    try {
      final token = await getStoredToken();

      final res = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        final cache = await _readCache() ?? [];
        final idx = cache.indexWhere((e) => e['id'].toString() == id);

        if (idx != -1) {
          cache[idx] = data;
          await _saveCache(cache);
        }

        offline = false;
        return data;
      }
    } catch (e) {
      final cache = await _readCache() ?? [];
      final idx = cache.indexWhere((e) => e['id'].toString() == id);

      if (idx != -1) {
        cache[idx] = {...cache[idx], ...body};
        await _saveCache(cache);
      }

      offline = true;
      return cache[idx];
    }

    return null;
  }

  // ==========================================================
  // 🔵 ELIMINAR TAREA
  // ==========================================================
  static Future<bool> deleteTask(String id) async {
    final url = Uri.parse('$baseUrl/tasks/$id');

    try {
      final token = await getStoredToken();

      final res = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200 || res.statusCode == 204) {
        final cache = await _readCache() ?? [];
        cache.removeWhere((e) => e['id'].toString() == id);
        await _saveCache(cache);

        offline = false;
        return true;
      }
    } catch (e) {
      final cache = await _readCache() ?? [];
      cache.removeWhere((e) => e['id'].toString() == id);
      await _saveCache(cache);

      offline = true;
      return true;
    }

    return false;
  }

  // ==========================================================
  // 🔵 OBTENER TOKEN GUARDADO
  // ==========================================================
  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
