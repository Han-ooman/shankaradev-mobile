import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String _kBaseUrl = 'base_url';

  static String baseUrl = 'http://10.10.10.100/shandev/api';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString(_kBaseUrl) ?? baseUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kBaseUrl, url);
  }
}