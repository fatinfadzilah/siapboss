import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siapbos/api/userAuthApi.dart';

class AuthState extends ChangeNotifier {
  String? token;
  String? role;
  String? username;
  String? name;
  bool loading = true;
  int? userId;

  AuthState() {
    _checkAuth(); 
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    role = prefs.getString('role');
    username = prefs.getString('username');
    name = prefs.getString('name');
    userId = prefs.getInt('userId');

    loading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    loading = true;
    notifyListeners();

    try {
      final data = await UserAuthApi.login(email, password);
      token = data['token'];
      role = data['user']['role'];
      username = data['user']['username'];
      name = data['user']['name'];
      userId = data['user']['id'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token!);
      await prefs.setString('role', role!);
      await prefs.setString('username', username!);
      await prefs.setString('name', name!);
      await prefs.setInt('userId', userId!);
    } catch (e) {
      throw Exception(e.toString());
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    token = null;
    role = null;
    username = null;
    name = null;
    userId = null;

    notifyListeners();
  }
}
