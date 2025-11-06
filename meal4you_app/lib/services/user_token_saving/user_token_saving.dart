import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserTokenSaving {
  static const String _tokenKey = 'user_token';
  static const String _userDataKey = 'user_data';
  static const String _restaurantDataKey = 'restaurant_data';

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

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userDataKey);
    if (data == null) return null;
    return jsonDecode(data);
  }

  static Future<void> saveRestaurantData(Map<String, dynamic> restaurantData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_restaurantDataKey, jsonEncode(restaurantData));
  }

  static Future<Map<String, dynamic>?> getRestaurantData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_restaurantDataKey);
    if (data == null) return null;
    return jsonDecode(data);
  }

  static Future<void> clearRestaurantData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_restaurantDataKey);
  }

  static Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_restaurantDataKey);
  }
}
