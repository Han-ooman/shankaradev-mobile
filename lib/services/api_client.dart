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

  String? _sessionCookie;
  http.Client get _client => http.Client();

  bool get hasSession => _sessionCookie != null;

  void setSessionCookie(String? cookie) {
    _sessionCookie = cookie;
  }

  String? get sessionCookie => _sessionCookie;

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
    if (_sessionCookie != null) h['Cookie'] = _sessionCookie!;
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

  Future<Map<String, dynamic>> get(String path, [Map<String, dynamic>? query]) async {
    try {
      final res = await _client.get(_uri(path, query), headers: _headers());
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
      {bool captureSession = false}) async {
    try {
      final res = await _client.post(
        _uri(path),
        headers: _headers(json: true),
        body: jsonEncode(data),
      );
      if (captureSession) {
        final setCookie = res.headers['set-cookie'];
        if (setCookie != null && setCookie.contains('PHPSESSID')) {
          _sessionCookie = setCookie.split(';').first;
        }
      }
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
      final res = await _client.put(
        _uri(path),
        headers: _headers(json: true),
        body: jsonEncode(data),
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