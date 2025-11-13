import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/providers/restaurant_provider.dart';
import 'package:meal4you_app/services/search_restaurant_data/search_restaurant_data_service.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';
import 'package:provider/provider.dart';

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
    BuildContext context,
    String email,
    String senha,
  ) async {
    try {
      await UserTokenSaving.clearAll();

      final response = await loginAdm(email: email, senha: senha);

      final token = response['token'] ?? response['accessToken'];
      if (token == null) throw Exception('Token não retornado pelo servidor.');

      await UserTokenSaving.saveToken(token);

      await UserTokenSaving.saveUserData(response);

      final savedEmail = await UserTokenSaving.getUserEmail();
      if (savedEmail == null)
        throw Exception('Email do usuário não encontrado no login.');

      final provider = Provider.of<RestaurantProvider>(context, listen: false);
      provider.clearRestaurant();

      final restaurantData =
          await SearchRestaurantDataService.searchMyRestaurant(token);

      if (restaurantData != null && restaurantData.isNotEmpty) {
        dynamic rawId =
            restaurantData['idRestaurante'] ??
            restaurantData['id'] ??
            restaurantData['id_restaurante'];

        final int id = rawId is int
            ? rawId
            : int.tryParse(rawId?.toString() ?? '') ?? -1;

        if (id <= 0) {
          throw Exception(
            'ID do restaurante inválido ou não encontrado (valor: $rawId)',
          );
        }

        debugPrint('✅ ID detectado corretamente: $id');

        provider.updateRestaurant(
          id: id,
          name: restaurantData['nome'] ?? '',
          description: restaurantData['descricao'] ?? '',
          location: restaurantData['localizacao'] ?? '',
          isActive: restaurantData['ativo'] ?? false,
          foodTypes: (restaurantData['tipoComida'] is String)
              ? (restaurantData['tipoComida'] as String)
                    .split(',')
                    .map((e) => e.trim())
                    .toList()
              : (restaurantData['tipoComida'] as List<dynamic>?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    [],
        );

        await UserTokenSaving.saveRestaurantId(id);
        await UserTokenSaving.saveRestaurantDataForUser(email, restaurantData);
        debugPrint('💾 Restaurante salvo (UserTokenSaving): id=$id');

        await Future.delayed(const Duration(milliseconds: 300));

        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/admRestaurantHome', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao fazer login: $e')));
    }
  }
}
