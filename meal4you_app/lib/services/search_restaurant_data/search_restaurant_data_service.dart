import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchRestaurantDataService {
  static const String baseUrl =
      "https://backend-production-7a83.up.railway.app/restaurantes";

  static Future<Map<String, dynamic>?> searchMyRestaurant(String token) async {
    final url = Uri.parse("$baseUrl/meu-restaurante");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception("Erro ${response.statusCode}: ${response.body}");
    }
  }
}
