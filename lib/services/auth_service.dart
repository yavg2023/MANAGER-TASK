import 'package:flutter/material.dart';
import 'api.dart';

class AuthService extends ChangeNotifier {
  String? _token;

  String? get token => _token;

  Future<bool> login(String email, String password) async {
    final res = await Api.login(email, password);
    if (res != null && res['token'] != null) {
      _token = res['token'];
      notifyListeners();
      return true;
    }
    return false;
  }
}
