import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserTokenSaving {
  static const String _tokenKey = 'user_token';
  static const String _userDataKey = 'user_data';
  static const String _userEmailKey = 'user_email';
  static const String _userIdKey = 'user_id';
  static const String _restaurantIdKey = 'restaurant_id';

  static Future<String?> getAuthorizationHeader() async {
    final token = await getToken();
    return token == null ? null : 'Bearer $token';
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

    String? email;

    if (userData.containsKey('email')) {
      email = userData['email'];
    } else if (userData['user'] is Map && userData['user']['email'] != null) {
      email = userData['user']['email'];
    }

    if (email != null) {
      await prefs.setString(_userEmailKey, email);
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userDataKey);
    return raw == null ? null : jsonDecode(raw);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_userEmailKey);
    if (saved != null) return saved;

    final data = await getUserData();
    if (data == null) return null;

    if (data.containsKey('email')) return data['email'];

    if (data['user'] is Map && data['user']['email'] != null) {
      return data['user']['email'];
    }

    return null;
  }

  static Future<void> saveCurrentUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
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

  static Future<void> saveRestaurantId(int? id) async {
    if (id == null || id <= 0) return;
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
    String email,
    Map<String, dynamic> restaurantData,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final rawId =
          restaurantData['idRestaurante'] ??
          restaurantData['id'] ??
          restaurantData['id_restaurante'];

      final id = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? -1;

      if (id > 0) {
        await prefs.setInt(_restaurantIdKey, id);
        await prefs.setString(
          'restaurant_data_$email',
          jsonEncode(restaurantData),
        );
      }
    } catch (e) {
      debugPrint("Erro ao salvar restaurante: $e");
    }
  }

  static Future<Map<String, dynamic>?> getRestaurantDataForUser(
    String email,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('restaurant_data_$email');
    return raw == null ? null : jsonDecode(raw);
  }

  static Future<void> clearRestaurantDataForUser(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('restaurant_data_$email');
  }

  static Future<void> clearRestaurantDataForCurrentUser() async {
    final email = await getUserEmail();
    if (email != null) {
      await clearRestaurantDataForUser(email);
    }
  }

  static Future<void> saveRestaurantDataForCurrentUser(
    Map<String, dynamic> restaurantData,
  ) async {
    final email = await getUserEmail();
    if (email != null) {
      await saveRestaurantDataForUser(email, restaurantData);
    }
  }

  static Future<Map<String, dynamic>?> getRestaurantDataForCurrentUser() async {
    final email = await getUserEmail();
    if (email == null) return null;
    return getRestaurantDataForUser(email);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_userEmailKey);

    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_userEmailKey);
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
    await prefs.remove(_userEmailKey);
  }
}
