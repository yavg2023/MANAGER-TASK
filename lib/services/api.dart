import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class Api {
  static const baseUrl = 'https://tu-api-aqui.com/api';
  static const cacheKey = 'cached_tasks_v1';

  static Future<void> _saveCache(List data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(cacheKey, jsonEncode(data));
  }

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

  static Future<Map?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final res = await http.post(url, body: {'email': email, 'password': password});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final token = data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        return data;
      }
    } catch (e) {
      debugPrint('login error: $e');
      // Si estamos en modo desarrollo (baseUrl por defecto), crear un token falso
      try {
        if (baseUrl.contains('tu-api-aqui.com')) {
          if (kDebugMode) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', 'dev-token');
            return {'token': 'dev-token'};
          }
        }
      } catch (err) {
        debugPrint('dev-token fallback failed: $err');
      }
    }
    return null;
  }

  static Future<List?> fetchTasks(String token) async {
    final url = Uri.parse('$baseUrl/tasks');
    try {
      final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
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
        return list;
      }
    } catch (e) {
      debugPrint('fetchTasks error, returning cache: $e');
      return await _readCache();
    }
    return await _readCache();
  }

  static Future<Map?> createTask(Map body) async {
    final url = Uri.parse('$baseUrl/tasks');
    try {
      final token = await getStoredToken();
      final res = await http.post(url, headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}, body: jsonEncode(body));
      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final cache = await _readCache() ?? [];
        cache.insert(0, data);
        await _saveCache(cache);
        return data;
      }
    } catch (e) {
      final cache = await _readCache() ?? [];
      final tempId = const Uuid().v4();
      final pending = {...body, 'id': tempId, 'pending': true};
      cache.insert(0, pending);
      await _saveCache(cache);
      return pending;
    }
    return null;
  }

  static Future<Map?> updateTask(String id, Map body) async {
    final url = Uri.parse('$baseUrl/tasks/$id');
    try {
      final token = await getStoredToken();
      final res = await http.put(url, headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}, body: jsonEncode(body));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final cache = await _readCache() ?? [];
        final idx = cache.indexWhere((e) => e['id'].toString() == id.toString());
        if (idx != -1) {
          cache[idx] = data;
          await _saveCache(cache);
        }
        return data;
      }
    } catch (e) {
      final cache = await _readCache() ?? [];
      final idx = cache.indexWhere((e) => e['id'].toString() == id.toString());
      if (idx != -1) {
        cache[idx] = {...cache[idx], ...body};
        await _saveCache(cache);
        return cache[idx];
      }
    }
    return null;
  }

  static Future<bool> deleteTask(String id) async {
    final url = Uri.parse('$baseUrl/tasks/$id');
    try {
      final token = await getStoredToken();
      final res = await http.delete(url, headers: {'Authorization': 'Bearer $token'});
      if (res.statusCode == 200 || res.statusCode == 204) {
        final cache = await _readCache() ?? [];
        cache.removeWhere((e) => e['id'].toString() == id.toString());
        await _saveCache(cache);
        return true;
      }
    } catch (e) {
      final cache = await _readCache() ?? [];
      cache.removeWhere((e) => e['id'].toString() == id.toString());
      await _saveCache(cache);
      return true;
    }
    return false;
  }

  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
