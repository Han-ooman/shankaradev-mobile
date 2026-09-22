import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? errors;

  ApiException(this.statusCode, this.message, [this.errors]);

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  String? _accessToken;
  String? _refreshToken;

  /// Dipanggil saat access token kedaluwarsa; harus me-refresh dan
  /// return true jika berhasil (token baru dipasang via setAccessToken).
  Future<bool> Function()? onRefreshToken;

  /// Dipanggil saat sesi benar-benar mati (refresh gagal) agar app logout.
  void Function()? onUnauthorized;

  final http.Client _client = http.Client();

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  void setRefreshToken(String? token) {
    _refreshToken = token;
  }

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  bool get hasSession => _accessToken != null;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = AppConfig.baseUrl;
    final q = query?.isEmpty == false ? query : null;
    var u = Uri.parse('$base$path');
    if (q != null) u = u.replace(queryParameters: q.map((k, v) => MapEntry(k, '$v')));
    return u;
  }

  Map<String, String> _headers({bool json = false}) {
    final h = <String, String>{
      'Accept': 'application/json',
    };
    if (json) h['Content-Type'] = 'application/json';
    if (_accessToken != null) h['Authorization'] = 'Bearer $_accessToken';
    return h;
  }

  Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(res.statusCode, 'Respon server tidak valid (kode ${res.statusCode})');
    }
    if (!(body['success'] == true)) {
      throw ApiException(
        res.statusCode,
        (body['message'] as String?) ?? 'Terjadi kesalahan',
        body['errors'] as Map<String, dynamic>?,
      );
    }
    return body;
  }

  /// Kirim request; jika 401 dan allowRefresh, coba refresh token sekali lalu ulangi.
  Future<http.Response> _sendWithRetry(
    Future<http.Response> Function(Map<String, String> headers) send, {
    bool allowRefresh = true,
  }) async {
    var res = await send(_headers());
    if (res.statusCode == 401 && allowRefresh && onRefreshToken != null) {
      try {
        final ok = await onRefreshToken!();
        if (ok) {
          res = await send(_headers());
        } else {
          onUnauthorized?.call();
        }
      } catch (_) {
        onUnauthorized?.call();
      }
    }
    return res;
  }

  Future<Map<String, dynamic>> get(String path, [Map<String, dynamic>? query]) async {
    try {
      final res = await _sendWithRetry((h) => _client.get(_uri(path, query), headers: h));
      return _decode(res);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException(0, 'Tidak dapat terhubung ke server. Periksa alamat server.');
    } on HttpException {
      throw ApiException(0, 'Koneksi gagal ke server.');
    } catch (_) {
      throw ApiException(0, 'Gagal terhubung ke server.');
    }
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data,
      {bool allowRefresh = true}) async {
    try {
      final res = await _sendWithRetry(
        (h) => _client.post(
          _uri(path),
          headers: {...h, 'Content-Type': 'application/json'},
          body: jsonEncode(data),
        ),
        allowRefresh: allowRefresh,
      );
      return _decode(res);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException(0, 'Tidak dapat terhubung ke server. Periksa alamat server.');
    } catch (_) {
      throw ApiException(0, 'Gagal terhubung ke server.');
    }
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> data) async {
    try {
      final res = await _sendWithRetry(
        (h) => _client.put(
          _uri(path),
          headers: {...h, 'Content-Type': 'application/json'},
          body: jsonEncode(data),
        ),
      );
      return _decode(res);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException(0, 'Tidak dapat terhubung ke server. Periksa alamat server.');
    } catch (_) {
      throw ApiException(0, 'Gagal terhubung ke server.');
    }
  }
}
