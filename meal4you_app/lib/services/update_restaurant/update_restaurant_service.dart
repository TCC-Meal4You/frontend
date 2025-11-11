import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/provider/restaurant_provider.dart';
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class UpdateRestaurantService {
  static const String baseUrl =
      "https://backend-production-7a83.up.railway.app/restaurantes";

  static Future<Map<String, dynamic>?> updateRestaurant({
    required int id,
    required RestaurantProvider provider,
  }) async {
    try {
      final token = await UserTokenSaving.getToken();
      if (token == null) {
        throw Exception("Token de autenticação não encontrado.");
      }

      final url = Uri.parse("$baseUrl/$id");

      final body = {
        "nome": provider.name,
        "descricao": provider.description,
        "localizacao": provider.location,
        "ativo": provider.isActive,
        'tipoComida': provider.foodTypes.join(', '),
      };

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await UserTokenSaving.saveRestaurantDataForCurrentUser(data);

        return data;
      } else {
        throw Exception(
          "Erro ao atualizar restaurante. Código: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Falha ao atualizar restaurante: $e");
    }
  }
}
