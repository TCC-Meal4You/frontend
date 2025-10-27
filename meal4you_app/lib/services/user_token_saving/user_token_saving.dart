import 'package:shared_preferences/shared_preferences.dart';

class UserTokenSaving {
  static const String _tokenKey = 'user_token';
  static const String _userDataKey = 'user_data';

  static Future<String?> getAuthorizationHeader() async {
    final token = await getToken();
    if (token == null) return null;
    return 'Bearer $token';
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
  }

  static Future<void> saveUserData(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, data);
  }

  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userDataKey);
  }
}
