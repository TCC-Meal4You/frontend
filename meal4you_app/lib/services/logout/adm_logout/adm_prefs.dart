import 'package:shared_preferences/shared_preferences.dart';

class AdmPrefs {
  static const String _admTokenKey = 'adm_token';
  static const String _admKey = 'adm';

  static Future<String?> getAuthorizationHeader() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_admTokenKey);
    if (token == null) return null;
    return 'Bearer $token';
    
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_admTokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_admTokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_admTokenKey);
  }

  static Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_admTokenKey);
    await prefs.remove(_admKey);
  }
}
