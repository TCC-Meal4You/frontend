import 'package:shared_preferences/shared_preferences.dart';

class ClientPrefs {
  static const String _clientTokenKey = 'client_token';
  static const String _clientKey = 'client';

  static Future<String?> getAuthorizationHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_clientTokenKey);
    if (token == null) return null;
    return 'Bearer $token';
    
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_clientTokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clientTokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clientTokenKey);
  }

  static Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clientTokenKey);
    await prefs.remove(_clientKey);
  }
}
