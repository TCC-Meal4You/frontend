import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class SearchRestaurantDataService {
  static const String baseUrl =
      "https://backend-production-b24f.up.railway.app/restaurantes";

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

      debugPrint(
        '🔍 [SearchRestaurantDataService] Status code: ${response.statusCode}',
      );
      debugPrint('📦 [SearchRestaurantDataService] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ Restaurante encontrado: $data');
        return data;
      } else if (response.statusCode == 404) {
        debugPrint('⚠️ Nenhum restaurante encontrado para este admin.');
        return null;
      } else {
        debugPrint(
          '❌ Erro ao buscar restaurante (status ${response.statusCode}): ${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('💥 Erro ao buscar restaurante: $e');
      return null;
    }
  }
}
