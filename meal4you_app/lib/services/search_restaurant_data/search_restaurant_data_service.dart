import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchRestaurantDataService {
  static const String baseUrl =
      "https://backend-production-1e17.up.railway.app/restaurantes";
  static Future<Map<String, dynamic>?> searchMyRestaurant(String token) async {
    final url = Uri.parse("$baseUrl/meu-restaurante");
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
