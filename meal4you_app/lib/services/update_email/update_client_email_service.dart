import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meal4you_app/services/user_token_saving/user_token_saving.dart';

class UpdateClientEmailService {
  static const String baseUrl =
      'https://backend-production-186a.up.railway.app/usuarios/atualizar-email';

  static Future<void> atualizarEmail({
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
      return;
    } else if (response.statusCode == 400) {
      throw Exception('Código de verificação inválido ou expirado');
    } else if (response.statusCode == 401) {
      throw Exception('Usuário não autenticado');
    } else {
      throw Exception('Erro ao atualizar e-mail: ${response.statusCode}');
    }
  }
}
