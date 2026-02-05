import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class UpdateEmailService {
  static const String baseUrl =
      'https://backend-production-bc8d.up.railway.app/admins/atualizar-email';

  static Future<Map<String, dynamic>> atualizarEmail({
    required String email,
    required String codigoVerificacao,
  }) async {
    final token = await UserTokenSaving.getToken();

    if (token == null) {
      throw Exception('Token não encontrado');
    }

    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'email': email,
        'codigoVerificacao': codigoVerificacao,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 400) {
      throw Exception('Código de verificação inválido ou expirado');
    } else if (response.statusCode == 401) {
      throw Exception('Não autorizado. Faça login novamente.');
    } else {
      throw Exception('Erro ao atualizar e-mail: ${response.statusCode}');
    }
  }
}
