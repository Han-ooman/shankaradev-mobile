import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _kUserKey = 'shandev_user';
  static const _kSessionKey = 'shandev_session';

  User? _user;

  User? get currentUser => _user;

  bool get isLoggedIn => _user != null;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final u = prefs.getString(_kUserKey);
    final s = prefs.getString(_kSessionKey);
    if (u != null && s != null) {
      try {
        _user = User.fromJson(jsonDecode(u) as Map<String, dynamic>);
        ApiClient.instance.setSessionCookie(s);
      } catch (_) {
        await clear();
      }
    }
  }

  Future<void> init() => _load();

  Future<User> login(String username, String password) async {
    final res = await ApiClient.instance.post(
      '/auth/login',
      {'username': username, 'password': password},
      captureSession: true,
    );
    final data = res['data'] as Map<String, dynamic>;
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserKey, jsonEncode(user.toJson()));
    await prefs.setString(_kSessionKey, ApiClient.instance.sessionCookie ?? '');
    return user;
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.post('/auth/logout', {});
    } catch (_) {
      // tetap lanjut hapus sesi lokal
    }
    await clear();
  }

  Future<void> clear() async {
    _user = null;
    ApiClient.instance.setSessionCookie(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserKey);
    await prefs.remove(_kSessionKey);
  }
}