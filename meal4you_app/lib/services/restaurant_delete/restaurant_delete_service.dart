import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class RestaurantDeleteService {
  static const String baseUrl =
      "https://backend-production-38906.up.railway.app/restaurantes";

  static Future<void> deleteRestaurant({
    required int restaurantId,
    required String nomeConfirmacao,
  }) async {
    try {
      final token = await UserTokenSaving.getToken();
      if (token == null) {
        throw Exception("Token não encontrado. Faça login novamente.");
      }

      final uri = Uri.parse(
        "$baseUrl/$restaurantId?nomeConfirmacao=$nomeConfirmacao",
      );
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Restaurante deletado com sucesso!");
      } else if (response.statusCode == 400) {
        throw Exception("Nome de confirmação incorreto.");
      } else if (response.statusCode == 401) {
        throw Exception("Administrador não autenticado.");
      } else if (response.statusCode == 403) {
        throw Exception(
          "Você não pode deletar restaurante de outro administrador.",
        );
      } else if (response.statusCode == 404) {
        throw Exception("Restaurante não encontrado.");
      } else {
        throw Exception("Erro ao deletar restaurante: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Erro no DeleteRestaurantService: $e");
      rethrow;
    }
  }
}
