import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class RestaurantInfoService {
  static const String baseUrl =
      'https://backend-production-1e17.up.railway.app/restaurantes';

  static Future<Map<String, dynamic>?> getById(int id) async {
    final uri = Uri.parse('$baseUrl/$id');
    try {
      final token = await UserTokenSaving.getToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final resp = await http.get(uri, headers: headers);
      if (resp.statusCode == 200 && resp.body.trim().isNotEmpty) {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is List &&
            decoded.isNotEmpty &&
            decoded.first is Map<String, dynamic>) {
          return decoded.first as Map<String, dynamic>;
        }
      }
    } catch (_) {}
    return null;
  }
}
