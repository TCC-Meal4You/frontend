import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterRestaurantService {
  static const String baseUrl =
      "https://backend-production-7a83.up.railway.app/restaurantes";

  static Future<void> registerRestaurant({
    required String name,
    required String description,
    required List<String> foodTypes,
    required String token,
  }) async {
    final url = Uri.parse(baseUrl);

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "nome": name,
        "descricao": description,
        "tiposComida": foodTypes,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Erro ${response.statusCode}: ${response.body}");
    }
  }
}
