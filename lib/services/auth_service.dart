import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _kUserKey = 'shandev_user';

  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  User? _user;

  User? get currentUser => _user;

  bool get isLoggedIn => _user != null;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final u = prefs.getString(_kUserKey);
    final access = await _secure.read(key: 'access_token');
    final refresh = await _secure.read(key: 'refresh_token');
    if (u != null && access != null) {
      try {
        _user = User.fromJson(jsonDecode(u) as Map<String, dynamic>);
        ApiClient.instance.setAccessToken(access);
        ApiClient.instance.setRefreshToken(refresh);
      } catch (_) {
        await clear();
      }
    }
  }

  Future<void> init() {
    ApiClient.instance.onRefreshToken = _refreshAccessToken;
    ApiClient.instance.onUnauthorized = _forceLogout;
    return _load();
  }

  Future<User> login(String username, String password) async {
    final res = await ApiClient.instance.post(
      '/auth/login',
      {'username': username, 'password': password},
      allowRefresh: false,
    );
    final data = res['data'] as Map<String, dynamic>;
    final user = User.fromJson(data['user'] as Map<String, dynamic>);
    _user = user;

    final access = data['access_token'] as String;
    final refresh = data['refresh_token'] as String;
    ApiClient.instance.setAccessToken(access);
    ApiClient.instance.setRefreshToken(refresh);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserKey, jsonEncode(user.toJson()));
    await _secure.write(key: 'access_token', value: access);
    await _secure.write(key: 'refresh_token', value: refresh);

    return user;
  }

  Future<bool> _refreshAccessToken() async {
    final refresh = await _secure.read(key: 'refresh_token');
    if (refresh == null) return false;
    try {
      final res = await ApiClient.instance.post(
        '/auth/refresh',
        {'refresh_token': refresh},
        allowRefresh: false,
      );
      final newAccess = res['data']['access_token'] as String;
      ApiClient.instance.setAccessToken(newAccess);
      await _secure.write(key: 'access_token', value: newAccess);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _forceLogout() {
    clear();
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
    ApiClient.instance.setAccessToken(null);
    ApiClient.instance.setRefreshToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserKey);
    await _secure.delete(key: 'access_token');
    await _secure.delete(key: 'refresh_token');
  }
}