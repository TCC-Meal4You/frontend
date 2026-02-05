import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class ValidateTokenService {
  static const String _baseUrl =
      'https://backend-production-bc8d.up.railway.app';

  static Future<bool> validateToken() async {
    try {
      final token = await UserTokenSaving.getToken();

      if (token == null || token.isEmpty) {
        return false;
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl/admins'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Timeout ao validar token');
            },
          );

      if (response.statusCode == 200) {
        return true;
      }

      if (response.statusCode == 401) {
        await UserTokenSaving.clearAll();
        return false;
      }

      return false;
    } catch (e) {
      print('❌ Erro ao validar token: $e');
      return false;
    }
  }
}
