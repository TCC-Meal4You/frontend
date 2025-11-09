import 'package:flutter/material.dart';
import 'package:meal4you_app/services/search_restaurant_data/search_restaurant_data_service.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdmLoginService {
  static const String baseUrl =
      'https://backend-production-7a83.up.railway.app/admins/login';

  static Future<Map<String, dynamic>> loginAdm({
    required String email,
    required String senha,
  }) async {
    final url = Uri.parse(baseUrl);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ${response.statusCode}: ${response.body}');
    }
  }

  static Future<void> handleLogin(
      BuildContext context, String email, String senha) async {
    try {
      final response = await loginAdm(email: email, senha: senha);

      final token = response['token'] ?? response['accessToken'];
      if (token == null) {
        throw Exception('Token não retornado pelo servidor.');
      }

      await UserTokenSaving.saveToken(token);
      await UserTokenSaving.saveUserData(response);

      final restaurantData =
          await SearchRestaurantDataService.searchMyRestaurant(token);

      if (restaurantData != null && restaurantData.isNotEmpty) {
        await UserTokenSaving.saveRestaurantDataForUser(email, restaurantData);

        Navigator.of(context).pushNamedAndRemoveUntil(
          '/admRestaurantHome',
          (route) => false,
        );
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/createAdmRestaurant',
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao fazer login: $e')),
      );
    }
  }
}
