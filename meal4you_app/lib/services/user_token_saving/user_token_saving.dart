import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserTokenSaving {
  static const String _tokenKey = 'user_token';
  static const String _userDataKey = 'user_data';
  static const String _userIdKey = 'user_id';
  static const String _restaurantIdKey = 'restaurant_id';

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

  static Future<String?> getUserEmail() async {
    final userData = await getUserData();
    if (userData == null) return null;

    if (userData.containsKey('email')) {
      return userData['email'];
    } else if (userData.containsKey('user') &&
        userData['user'] is Map &&
        userData['user']['email'] != null) {
      return userData['user']['email'];
    }
    return null;
  }

  static Future<void> saveUserId(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, email);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  static Future<void> saveRestaurantId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_restaurantIdKey, id);
  }

  static Future<int?> getRestaurantId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_restaurantIdKey);
  }

  static Future<void> clearRestaurantId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_restaurantIdKey);
  }

  static Future<void> saveRestaurantDataForUser(
      String email, Map<String, dynamic> restaurantData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('restaurant_data_$email', jsonEncode(restaurantData));

    // Se tiver ID no restaurante, salva também
    if (restaurantData.containsKey('id') && restaurantData['id'] != null) {
      await saveRestaurantId(restaurantData['id']);
    }
  }

  static Future<Map<String, dynamic>?> getRestaurantDataForUser(
      String email) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('restaurant_data_$email');
    if (data == null) return null;
    return jsonDecode(data);
  }

  static Future<void> clearRestaurantDataForUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('restaurant_data_$email');
  }

  static Future<Map<String, dynamic>?> getRestaurantDataForCurrentUser() async {
    final email = await getUserId();
    if (email == null) return null;
    return getRestaurantDataForUser(email);
  }

  static Future<void> saveRestaurantDataForCurrentUser(
      Map<String, dynamic> restaurantData) async {
    final email = await getUserId();
    if (email == null) return;
    await saveRestaurantDataForUser(email, restaurantData);
  }

  static Future<void> clearRestaurantDataForCurrentUser() async {
    final email = await getUserId();
    if (email == null) return;
    await clearRestaurantDataForUser(email);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_userIdKey);

    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_restaurantIdKey);

    if (email != null) {
      await prefs.remove('restaurant_data_$email');
    }
  }

  static Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
  }
}
