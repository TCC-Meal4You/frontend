import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/providers/restaurant/restaurant_provider.dart';
import 'package:meal4you_app/services/search_restaurant_data/search_restaurant_data_service.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:provider/provider.dart';

class AdmLoginService {
  static const String baseUrl =
      'https://backend-production-bc8d.up.railway.app/admins/login';

  static Future<Map<String, dynamic>> loginAdm({
    required String email,
    required String senha,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
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
    BuildContext context,
    String email,
    String senha,
  ) async {
    try {
      await UserTokenSaving.clearAll();

      final response = await loginAdm(email: email, senha: senha);

      final token = response['token'] ?? response['accessToken'];
      if (token == null) throw Exception('Token não retornado.');

      await UserTokenSaving.saveCurrentUserEmail(email);
      await UserTokenSaving.saveToken(token);
      await UserTokenSaving.saveUserPassword(senha);

      final userData = <String, dynamic>{
        ...Map<String, dynamic>.from(response),
        'email': email,
        'userType': 'adm',
        'isAdm': true,
      };
      await UserTokenSaving.saveUserData(userData);

      final savedEmail = await UserTokenSaving.getUserEmail();
      if (savedEmail == null)
        throw Exception('Email não encontrado após salvar.');

      final provider = Provider.of<RestaurantProvider>(context, listen: false);

      provider.clearRestaurant();

      final restaurantData =
          await SearchRestaurantDataService.searchMyRestaurant(token);

      if (restaurantData == null || restaurantData.isEmpty) {
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/createAdmRestaurant',
            (_) => false,
          );
        }
        return;
      }

      final rawId =
          restaurantData['idRestaurante'] ??
          restaurantData['id'] ??
          restaurantData['id_restaurante'];

      final id = rawId is int ? rawId : int.tryParse(rawId.toString()) ?? -1;

      if (id <= 0) throw Exception('ID inválido.');

      await UserTokenSaving.saveRestaurantId(id);
      await UserTokenSaving.saveRestaurantDataForUser(
        savedEmail,
        restaurantData,
      );

      provider.updateRestaurant(
        id: id,
        name: restaurantData['nome'] ?? '',
        description: restaurantData['descricao'] ?? '',
        isActive: restaurantData['ativo'] ?? false,
        foodTypes: (restaurantData['tipoComida'] is String)
            ? restaurantData['tipoComida']
                  .split(',')
                  .map((e) => e.trim())
                  .toList()
            : (restaurantData['tipoComida'] as List? ?? [])
                  .map((e) => e.toString())
                  .toList(),
      );

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/admRestaurantHome',
          (_) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao logar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }
}
