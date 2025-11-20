import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterRestaurantService {
  static const String baseUrl =
      "https://backend-production-9aaf.up.railway.app/restaurantes";

  static Future<Map<String, dynamic>> registerRestaurant({
    required String name,
    required String description,
    required bool isActive,
    required List<String> foodTypes,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "nome": name,
        "descricao": description,
        "ativo": isActive,
        "tipoComida": foodTypes.join(", "),
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Erro ao criar restaurante: ${response.statusCode} - ${response.body}",
      );
    }
  }
}

