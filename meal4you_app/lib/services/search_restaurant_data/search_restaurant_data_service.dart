import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

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
      final restaurantData = jsonDecode(response.body);

      final email = await UserTokenSaving.getUserEmail();
      if (email != null) {
        await UserTokenSaving.saveRestaurantDataForUser(email, restaurantData);
      }

      return restaurantData;
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception("Erro ${response.statusCode}: ${response.body}");
    }
  }
}
